#!/usr/bin/env python3
import sys
import os

if len(sys.argv) != 10:
    print(f"Usage: {sys.argv[0]} R0_ms_f1 R0_ms_f2 Dt_s tstop_s X_min X_boundary X_max X_ign outdir")
    sys.exit(1)

R0_f1 = float(sys.argv[1])      # m/s in left fuel
R0_f2 = float(sys.argv[2])      # m/s in right fuel
Dt_s = int(sys.argv[3])         # dump interval in seconds
tstop_s = int(sys.argv[4])      # stop time in seconds
X_min = float(sys.argv[5])
X_boundary = float(sys.argv[6])
X_max = float(sys.argv[7])
X_ign = float(sys.argv[8])
outdir = sys.argv[9]

# Y extent for vertical lines
Y_min = -750.0
Y_max =  750.0

# Time to reach boundary from ignition (exact)
cellsize = 5.0  # m
offset_dist = 2.13773  # m observed partial-cell travel before ROS change
lag_s = offset_dist / R0_f1
t_boundary = (X_boundary - X_ign) / R0_f1 - lag_s if R0_f1 > 0 else float('inf')

os.makedirs(outdir, exist_ok=True)

t = 2.5/R0_f1
while t < tstop_s:
    t += Dt_s

    # --- Left front ---
    x_left = X_ign - R0_f1 * t
    x_left = max(x_left, X_min)

    # --- Right front ---
    if t <= t_boundary:
        # Entirely in fuel 1
        x_right = X_ign + R0_f1 * t
    else:
        if (t - Dt_s) < t_boundary <= t:
            # Crossing occurs in this interval -> fractional timestep
            dt_before = t_boundary - (t - Dt_s)
            dt_after = Dt_s - dt_before
            x_prev = X_ign + R0_f1 * (t - Dt_s)  # previous position
            x_right = x_prev + R0_f1 * dt_before + R0_f2 * dt_after
        else:
            # Already in fuel 2
            dist_f1 = R0_f1 * t_boundary
            dist_f2 = R0_f2 * (t - t_boundary)
            x_right = X_ign + dist_f1 + dist_f2

    x_right = min(x_right, X_max)

    # --- Write shapefile CSV ---
    fname = os.path.join(outdir, f"planar_{int(t-round(2.5/R0_f1))}.csv")
    with open(fname, "w") as f:
        f.write("id,gm\n")
        wkt = (
            f"MULTILINESTRING "
            f"(({x_left} {Y_min}, {x_left} {Y_max}),"
            f"({x_right} {Y_min}, {x_right} {Y_max}))"
        )
        f.write(f'0,"{wkt}"\n')