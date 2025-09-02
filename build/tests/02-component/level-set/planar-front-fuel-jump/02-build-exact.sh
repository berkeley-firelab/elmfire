#!/bin/bash

# 02-build-exact.sh
# Generates exact solution isochrones for 04-planar-front-fuel-jump
# Questions? Contact: adam.laird@berkeley.edu

set -euo pipefail

# Case parameters
X_MIN=-750.0                            # Left edge of computational domain (m)
X_MAX=750.0                             # Right edge of computational domain (m)
X_BOUNDARY=0.0                          # Fuel jump line (m)
X_IGN=-92.5                            # Initial planar front position (m)

SIMULATION_TSTOP=18000                  # Simulation stop time (s)
DTDUMP=1200                             # Output dump interval (s)

# Fuel 1 parameters
FBFM_f1=10
M1_f1=0.03
M10_f1=0.05
M100_f1=0.06
LHMC_f1=0.30
LWMC_f1=0.60

# Fuel 2 parameters
FBFM_f2=3
M1_f2=0.03
M10_f2=0.04
M100_f2=0.06
LHMC_f2=0.30
LWMC_f2=0.60

# Output dir
OUTDIR="./exact_lines"
rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# Calculate ROS (m/h) -> (m/s)
R0_mh_f1=$(./03-calc-spread-rate.py $M1_f1 $M10_f1 $M100_f1 $LHMC_f1 $LWMC_f1 0 $FBFM_f1 | grep "m/h" | awk '{print $3}')
R0_mh_f2=$(./03-calc-spread-rate.py $M1_f2 $M10_f2 $M100_f2 $LHMC_f2 $LWMC_f2 0 $FBFM_f2 | grep "m/h" | awk '{print $3}')

R0_ms_f1=$(python3 -c "print(${R0_mh_f1} / 3600.0)")
R0_ms_f2=$(python3 -c "print(${R0_mh_f2} / 3600.0)")

echo "Fuel 1 ROS: $R0_mh_f1 m/h ($R0_ms_f1 m/s)"
echo "Fuel 2 ROS: $R0_mh_f2 m/h ($R0_ms_f2 m/s)"

# Set up csv files containing linestring of circle surface
./04-exact-shapefiles.py "$R0_ms_f1" "$R0_ms_f2" "$DTDUMP" "$SIMULATION_TSTOP"  "$X_MIN" "$X_BOUNDARY" "$X_MAX" "$X_IGN" "$OUTDIR"

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