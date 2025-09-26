#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from math import floor

def usage():
    return """Usage: run_all.py [OPTIONS]

Run all discovered cases' run_case.sh, with optional sharding for Cloud Run Jobs.

Options:
  -l, --list              List the resolved case scripts for THIS SHARD and exit
  -n, --dry-run           Show the commands without executing them
  -s, --slurm             Submit jobs via Slurm (sbatch run_case_slurm.sh)
  --shard-index N         Zero-based shard index for this worker (overrides env)
  --shard-count K         Total number of shards/workers (overrides env)
  -h, --help              Show this help message

Notes:
  - Sharding sources (highest priority first):
      1) --shard-index / --shard-count
      2) CLOUD_RUN_TASK_INDEX / CLOUD_RUN_TASK_COUNT
      3) TASK_COUNT (custom) with index=0
      4) default: index=0, count=1
  - Each case executes from its own directory so ELMFIRE sees inputs in CWD.
  - With --slurm, a run_case_slurm.sh wrapper is generated per case.
"""

def discover_cases(cases_dir):
    """Find all run_case.sh under cases_dir, excluding template."""
    scripts = []
    for dirpath, _, filenames in os.walk(cases_dir):
        if "case_template" in dirpath:
            continue
        if "run_case.sh" in filenames:
            scripts.append(os.path.join(dirpath, "run_case.sh"))
    scripts.sort()
    return scripts

def format_case(script, root_dir):
    """Pretty relative path like cases/Validation/tubbs_fire"""
    rel = os.path.relpath(script, root_dir)
    return rel.removesuffix("/run_case.sh")

def make_slurm_wrapper(case_dir, header_path):
    """Create run_case_slurm.sh by combining slurm_head.txt + run_case.sh."""
    wrapper = os.path.join(case_dir, "run_case_slurm.sh")
    run_case = os.path.join(case_dir, "run_case.sh")

    if not os.path.isfile(header_path):
        print(f"[ERROR] Missing Slurm header file: {header_path}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(run_case):
        print(f"[ERROR] Missing run_case.sh in {case_dir}", file=sys.stderr)
        sys.exit(1)

    with open(wrapper, "w") as f:
        f.write("#!/usr/bin/env bash\n\n")
        with open(header_path, "r") as hdr:
            f.write(hdr.read().rstrip() + "\n\n")
        with open(run_case, "r") as rc:
            f.write(rc.read().rstrip() + "\n")

    os.chmod(wrapper, 0o755)
    return wrapper

def resolve_shard_args(cli_index, cli_count):
    """
    Determine (shard_index, shard_count) using CLI > env > defaults.
    Recognized envs:
      - CLOUD_RUN_TASK_INDEX (0-based), CLOUD_RUN_TASK_COUNT
      - TASK_COUNT (fallback; index assumed 0)
    """
    # CLI wins
    if cli_index is not None and cli_count is not None:
        return cli_index, cli_count
    if (cli_index is None) ^ (cli_count is None):
        print("[ERROR] --shard-index and --shard-count must be provided together", file=sys.stderr)
        sys.exit(2)

    # Cloud Run Jobs envs
    env_idx = os.getenv("CLOUD_RUN_TASK_INDEX")
    env_cnt = os.getenv("CLOUD_RUN_TASK_COUNT")
    if env_idx is not None and env_cnt is not None:
        try:
            idx = int(env_idx)
            cnt = int(env_cnt)
            return idx, cnt
        except ValueError:
            print("[WARN] Invalid CLOUD_RUN_TASK_* values; falling back", file=sys.stderr)

    # Fallback custom
    env_cnt2 = os.getenv("TASK_COUNT")
    if env_cnt2 is not None:
        try:
            cnt = int(env_cnt2)
            return 0, cnt
        except ValueError:
            print("[WARN] Invalid TASK_COUNT; falling back", file=sys.stderr)

    # Default: single shard
    return 0, 1

def shard_slice(n_items, k_shards, i_index):
    """Contiguous sharding: [floor(i*n/k), floor((i+1)*n/k))"""
    if k_shards <= 0:
        return 0, n_items
    if i_index < 0 or i_index >= k_shards:
        return 0, 0
    start = floor(i_index * n_items / k_shards)
    end = floor((i_index + 1) * n_items / k_shards)
    return start, end

def main():
    parser = argparse.ArgumentParser(add_help=False, usage=usage())
    parser.add_argument("-l", "--list", action="store_true")
    parser.add_argument("-n", "--dry-run", action="store_true")
    parser.add_argument("-s", "--slurm", action="store_true")
    parser.add_argument("--shard-index", type=int, default=None)
    parser.add_argument("--shard-count", type=int, default=None)
    parser.add_argument("-h", "--help", action="store_true")
    args, extra = parser.parse_known_args()

    if args.help:
        print(usage())
        sys.exit(0)

    if extra:
        print(f"[ERROR] Unexpected argument: {extra[0]}", file=sys.stderr)
        print(usage(), file=sys.stderr)
        sys.exit(2)

    # Basic paths
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    cases_dir = os.path.join(root_dir, "cases")
    header_path = os.path.join(root_dir, "common", "slurm_head.txt")

    # Log context for Cloud Run logs
    commit_sha = os.getenv("COMMIT_SHA", "")
    results_bucket = os.getenv("RESULTS_BUCKET", "")
    if commit_sha:
        print(f"[INFO] COMMIT_SHA={commit_sha}")
    if results_bucket:
        print(f"[INFO] RESULTS_BUCKET={results_bucket}")

    if not os.path.isdir(cases_dir):
        print(f"[ERROR] Cases directory not found: {cases_dir}", file=sys.stderr)
        sys.exit(1)

    all_scripts = discover_cases(cases_dir)
    total_all = len(all_scripts)

    if total_all == 0:
        print(f"[WARN] No case scripts were discovered under {cases_dir}", file=sys.stderr)
        sys.exit(0)

    # Shard resolution
    shard_idx, shard_cnt = resolve_shard_args(args.shard_index, args.shard_count)
    s, e = shard_slice(total_all, shard_cnt, shard_idx)
    shard_scripts = all_scripts[s:e]
    total_shard = len(shard_scripts)

    print(f"[INFO] Sharding: total_cases={total_all}, shard_index={shard_idx}, shard_count={shard_cnt}, "
          f"assigned_range=[{s}:{e}) => shard_cases={total_shard}")

    if total_shard == 0:
        print("[OK] This shard has no assigned cases. Exiting.")
        sys.exit(0)

    # Listing / dry-run only shows THIS SHARD's plan
    if args.list:
        print(f"Discovered {total_shard} case(s) in this shard:")
        for script in shard_scripts:
            print(f"  - {format_case(script, root_dir)}")
        sys.exit(0)

    if args.dry_run:
        mode = "Slurm submission" if args.slurm else "local execution"
        print(f"[DRY-RUN] {total_shard} case(s) would be run with {mode}:")
        for script in shard_scripts:
            rel = format_case(script, root_dir)
            case_dir = os.path.dirname(script)
            if args.slurm:
                print(f"  - {rel} (cd {case_dir} && sbatch run_case_slurm.sh)")
            else:
                print(f"  - {rel} (cd {case_dir} && bash ./run_case.sh)")
        sys.exit(0)

    # Actual execution
    if args.slurm:
        print(f"[INFO] Preparing & submitting {total_shard} case(s) via Slurm ...")
    else:
        print(f"[INFO] Running {total_shard} case(s) sequentially in this shard ...")

    for idx, script in enumerate(shard_scripts, start=1):
        rel = format_case(script, root_dir)
        case_dir = os.path.dirname(script)
        print(f"\n[INFO] [{idx}/{total_shard}] {rel}")

        if not os.path.isdir(case_dir):
            print(f"[ERROR] Cannot cd into {case_dir}", file=sys.stderr)
            sys.exit(1)

        if args.slurm:
            wrapper = make_slurm_wrapper(case_dir, header_path)
            try:
                subprocess.run(["sbatch", wrapper], cwd=case_dir, check=True)
                print(f"[OK] Submitted {rel}")
            except subprocess.CalledProcessError as e:
                print(f"[ERROR] sbatch failed in {case_dir}", file=sys.stderr)
                sys.exit(e.returncode)
        else:
            try:
                # Prefer bash explicitly to avoid executable bit issues
                subprocess.run(["bash", "./run_case.sh"], cwd=case_dir, check=True)
                print(f"[OK] Completed {rel}")
            except subprocess.CalledProcessError as e:
                print(f"[ERROR] run_case.sh failed in {case_dir}", file=sys.stderr)
                sys.exit(e.returncode)

    if args.slurm:
        print(f"\n[OK] Submitted {total_shard} job(s) from this shard.")
    else:
        print(f"\n[OK] All {total_shard} case(s) in this shard completed successfully.")

if __name__ == "__main__":
    main()
