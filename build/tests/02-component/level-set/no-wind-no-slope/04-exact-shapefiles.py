#!/usr/bin/env python3
import sys
import math
import os

# Inputs
R0     = float(sys.argv[1])  # ROS in m/h
Dt     = int(sys.argv[2])    # time step (h)
tstop  = int(sys.argv[3])    # final time (h)
xign   = float(sys.argv[4])  # ignition x (m)
yign   = float(sys.argv[5])  # ignition y (m)
outdir = sys.argv[6]

CELL_SIZE = 5.0  # m

xign = xign - CELL_SIZE / 2.0
yign = yign - CELL_SIZE / 2.0

Npts = 720  # points around circle

t = 0
while t < tstop:
    t += Dt
    radius = R0 * t
    fname = os.path.join(outdir, f"circle_{t}.csv")
    with open(fname, 'w') as f:
        f.write("id,gm\n")
        coords = []
        for i in range(Npts):
            theta = 2.0 * math.pi * i / (Npts - 1)
            x = xign + radius * math.cos(theta)
            y = yign + radius * math.sin(theta)   
            coords.append(f"{x} {y}")
        line = f'0,"LINESTRING ({", ".join(coords)})"\n'
        f.write(line)