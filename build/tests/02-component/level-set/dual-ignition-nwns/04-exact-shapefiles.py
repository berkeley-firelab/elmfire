#!/usr/bin/env python3
import sys
import math
import os

R0_ms = float(sys.argv[1])      # m/s
Dt_s = int(sys.argv[2])
tstop_s = int(sys.argv[3])
x1, y1 = float(sys.argv[4]) - 2.5, float(sys.argv[5]) - 2.5
x2, y2 = float(sys.argv[6]) - 2.5, float(sys.argv[7]) - 2.5
outdir = sys.argv[8]

Npts = 720

def circle_coords(cx, cy, r):
    pts = []
    for i in range(Npts):
        theta = 2.0 * math.pi * i / (Npts - 1)
        pts.append((cx + r * math.cos(theta), cy + r * math.sin(theta)))
    return pts

t = 0
while t < tstop_s:
    t += Dt_s
    r = R0_ms * t
    c1 = circle_coords(x1, y1, r)
    c2 = circle_coords(x2, y2, r)

    # Build WKT correctly: MULTILINESTRING ((...),(...))
    def wkt_line(coords):
        return "(" + ", ".join(f"{x} {y}" for x, y in coords) + ")"

    wkt = f"MULTILINESTRING ({wkt_line(c1)}, {wkt_line(c2)})"

    fname = os.path.join(outdir, f"dual_{t}.csv")
    with open(fname, "w") as f:
        f.write("id,gm\n")
        f.write(f'0,"{wkt}"\n')
