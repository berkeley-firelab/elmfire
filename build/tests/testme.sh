#!/usr/bin/env bash

# testme.sh — Unified Automated Testing Suite
# Updated: 2025-08-13
# Contact: adam.laird@berkeley.edu

set -euo pipefail

COMMAND=${1:-}
TARGET=${2:-}

BIN="bin"

# How deep to scan for directory-based cases under a group path (override as needed)
# Example: SCAN_DEPTH=2 ./testme.sh rund 02-component/numerics
SCAN_DEPTH="${SCAN_DEPTH:-2}"

# == Test suite hierarchy definition ==========================================
# Compiled-test roots (00–01). We search recursively when needed.
COMP_TEST_DIRS=(
  "00-unit-independent"
  "01-unit-dependent"
)

# Directory-test root folders (02–06)
DIR_TEST_DIRS=(
  "02-component"
  "03-integration"
  "04-regression"
  "05-performance"
  "06-validation"
)

# == Compiled (00/01) =========================================================
run_test() {
  # Run a single compiled test by its short name (without 'test_')
  local TEST_NAME="test_$1"
  local TEST_BIN="${BIN}/${TEST_NAME}"

  # Look for the source anywhere under the compiled roots
  local FOUND_SRC=""
  for dir in "${COMP_TEST_DIRS[@]}"; do
    FOUND_SRC=$(find "$dir" -type f -name "${TEST_NAME}.f90" -print -quit 2>/dev/null || true)
    [[ -n "$FOUND_SRC" ]] && break
  done

  if [[ -z "$FOUND_SRC" ]]; then
    echo "Not a compiled test: '$TEST_NAME' (source not found under ${COMP_TEST_DIRS[*]})"
    return 1
  fi

  make "$TEST_BIN"
  echo "Running $TEST_NAME..."
  "./$TEST_BIN"
}

run_group_compiled() {
  # Run all compiled tests under a path (group or subgroup)
  local group=$1
  if [[ ! -d "$group" ]]; then
    echo "Compiled group path not found: $group"
    exit 1
  fi

  local TESTS
  TESTS=$(find "$group" -type f -name 'test_*.f90' | sort || true)
  if [[ -z "${TESTS}" ]]; then
    echo "No compiled tests found in group: $group"
    exit 1
  fi

  echo "Building object files..."
  make bin
  make build_objects

  for f in $TESTS; do
    local TEST_NAME
    TEST_NAME=$(basename "$f" .f90)
    make "bin/$TEST_NAME"
    echo "Running $TEST_NAME..."
    ./bin/$TEST_NAME
  done

  echo "Cleaning up object files..."
  rm -f bin/*.o bin/*.mod
}

run_all_compiled() {
  echo "Running all compiled tests (00–01)..."
  make run
}

# == Directory-based (02–06) ==================================================
run_dir_case_individual() {
  local case_dir=$1
  if [[ ! -d "$case_dir" ]]; then
    echo "Directory test '$case_dir' not found."
    exit 1
  fi
  if [[ ! -f "$case_dir/01-run.sh" ]]; then
    echo "Skipping '$case_dir' (no 01-run.sh)"
    exit 1
  fi
  echo "Running $case_dir..."
  ( cd "$case_dir" && bash ./01-run.sh )
}

run_dir_case_group() {
  local group=$1
  if [[ ! -d "$group" ]]; then
    echo "Directory group $group does not exist."
    exit 1
  fi

  # If the path itself is a runnable case, run it
  if [[ -f "$group/01-run.sh" ]]; then
    echo "Running $group..."
    ( cd "$group" && bash ./01-run.sh )
    return
  fi

  # Otherwise run its child case directories (depth configurable)
  local cases
  if [[ -n "$SCAN_DEPTH" && "$SCAN_DEPTH" -gt 0 ]]; then
    cases=$(find "$group" -mindepth 1 -maxdepth "$SCAN_DEPTH" -type d | sort || true)
  else
    cases=$(find "$group" -mindepth 1 -type d | sort || true)
  fi

  if [[ -z "$cases" ]]; then
    echo "No cases found in $group"
    return
  fi

  local found_any=0
  for case_dir in $cases; do
    if [[ -f "$case_dir/01-run.sh" ]]; then
      found_any=1
      echo "Running $case_dir..."
      ( cd "$case_dir" && bash ./01-run.sh )
    fi
  done

  if [[ "$found_any" -eq 0 ]]; then
    echo "No runnable cases (with 01-run.sh) found under $group"
  fi
}

run_all_dir_cases() {
  echo "Running all directory tests (02–06)..."
  for g in "${DIR_TEST_DIRS[@]}"; do
    run_dir_case_group "$g"
  done
}

# Resolve a single directory case by name or path
resolve_dir_case() {
  local want="$1"

  # Exact path to a runnable case
  if [[ -d "$want" && -f "$want/01-run.sh" ]]; then
    echo "$want"
    return 0
  fi

  # Search across DIR_TEST_DIRS (depth configurable)
  local search
  for base in "${DIR_TEST_DIRS[@]}"; do
    if [[ -n "$SCAN_DEPTH" && "$SCAN_DEPTH" -gt 0 ]]; then
      search=$(find "$base" -mindepth 1 -maxdepth "$SCAN_DEPTH" -type d 2>/dev/null || true)
    else
      search=$(find "$base" -mindepth 1 -type d 2>/dev/null || true)
    fi
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      if [[ -f "$d/01-run.sh" ]]; then
        local name
        name=$(basename "$d")
        if [[ "$name" == "$want" || "$d" == *"$want"* ]]; then
          echo "$d"
          return 0
        fi
      fi
    done <<< "$search"
  done
  return 1
}

# == Maintenance (clean/reset) ================================================
clean_scratch() {
  local total=0
  for root in "${DIR_TEST_DIRS[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r d; do
      echo "  - $d"
      rm -rf -- "$d"
      total=$((total+1))
    done < <(find "$root" -type d -name scratch 2>/dev/null)
  done
  echo "Removed $total scratch/ director$([[ $total -eq 1 ]] && echo 'y' || echo 'ies')."
}

reset_dir_trees() {
  local total=0
  for root in "${DIR_TEST_DIRS[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r d; do
      echo "  - $d"
      rm -rf -- "$d"
      total=$((total+1))
    done < <(find "$root" -type d \( -name inputs -o -name outputs -o -name scratch \) 2>/dev/null)
  done
  echo "Removed $total director$([[ $total -eq 1 ]] && echo 'y' || echo 'ies') named inputs/, outputs/, or scratch/."
}

# == Usage ====================================================================
usage() {
  cat <<EOF
Usage:
  ./testme.sh run all                                       # Run all tests

  ./testme.sh runc all                                      # Run all comp tests (00-01)
  ./testme.sh runc 00-unit-independent                      # Run compiled test group
  ./testme.sh runc 00-unit-independent/elmfire_spotting     # Run compiled test subgroup
  ./testme.sh runc calc_cfl                                 # Run individual comp test

  ./testme.sh rund all                                      # Run all dir tests (02-06)
  ./testme.sh rund 02-component                             # Run directory test group
  ./testme.sh rund 02-component/numerics                    # Run directory test subgroup
  ./testme.sh rund dual-ignition-nwns                       # Run individual dir test

  ./testme.sh clean                                         # Clean build artifacts
  ./testme.sh reset                                         # Remove all inputs/, outputs/, scratch/ directories
EOF
}

[[ -z "${COMMAND:-}" ]] && { usage; exit 1; }

case "$COMMAND" in
  # ===================== General (all) =======================================
  run)
    case "${TARGET:-}" in
      ""|"all")
        run_all_compiled
        run_all_dir_cases
        ;;
      *)
        usage; exit 1
        ;;
    esac
    ;;
  # ===================== Compiled-only =======================================
  runc)
    case "${TARGET:-}" in
      ""|"all")
        run_all_compiled
        ;;
      00-*|01-*)
        run_group_compiled "$TARGET"
        ;;
      *)
        if ! run_test "$TARGET"; then
          echo "Not a compiled test or group: '$TARGET'"
          usage; exit 1
        fi
        ;;
    esac
    ;;
  # ===================== Directory-only ======================================
  rund)
    case "${TARGET:-}" in
      ""|"all")
        run_all_dir_cases
        ;;
      02-*|03-*|04-*|05-*|06-*)
        run_dir_case_group "$TARGET"
        ;;
      *)
        if case_path=$(resolve_dir_case "$TARGET"); then
          run_dir_case_individual "$case_path"
        else
          echo "Not a directory test or group: '$TARGET'"
          usage; exit 1
        fi
        ;;
    esac
    ;;
  # ===================== Maintenance =========================================
  clean)
    echo "Cleaning up object files..."
    make clean || true
    echo "Cleaning scratch directories..."
    clean_scratch
    ;;
  reset)
    echo "Resetting testing environment (inputs/, outputs/, scratch/ under 02–06)..."
    reset_dir_trees
    ;;
  *)
    usage; exit 1
    ;;
esac