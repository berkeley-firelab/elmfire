#!/bin/bash

# 02-build-exact.sh
# Generates exact solution isochrones for 01-single-ignition-nwns
# Questions? Contact: adam.laird@berkeley.edu

set -euo pipefail

# Case parameters
IGN1_X=0.0                              # Ignition x (m)
IGN1_Y=0.0                              # Ignition y (m)

SIMULATION_TSTOP=7200                   # Simulation stop time (s)
DTDUMP=1200                             # Output dump interval (s)

M1=0.03                                 # 1-hr   dead moisture content
M10=0.05                                # 10-hr  dead moisture content
M100=0.06                               # 100-hr dead moisture content
LHMC=0.30                               # Live herb. moisture content
LWMC=0.60                               # Live woody moisture content

# Output dir
OUTDIR="./exact_circles"
rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# Calculate ROS (m/h) -> (m/s)
R0_mh=$(./03-calc-spread-rate.py $M1 $M10 $M100 $LHMC $LWMC | grep "m/h" | awk '{print $3}')
R0_ms=$(python3 -c "print(${R0_mh} / 3600.0)")
echo "ROS = $R0_mh m/h (${R0_ms} m/s)"

# Set up csv files containing linestring of circle surface
./04-exact-shapefiles.py "$R0_ms" "$DTDUMP" "$SIMULATION_TSTOP" "$IGN1_X" "$IGN1_Y" "$OUTDIR"

# Convert CSVs to shapefiles
for csv in "$OUTDIR"/*.csv; do
    base=$(basename "$csv" .csv)
    ogr2ogr -f "ESRI Shapefile" -a_srs "EPSG:32610" \
        "$OUTDIR/${base}.shp" \
        -dialect sqlite \
        -sql "SELECT id, GeomFromText(gm) FROM $base" "$csv"
done

echo "Exact isochrone shapefiles written to $OUTDIR"

exit 0