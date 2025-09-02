#!/bin/bash

# Run Name: no-wind-with-slope
# Questions? Contact: adam.laird@berkeley.edu

# Note: This test case matches the verification study provided in the original
# ELMFIRE paper (No wind with slope).
# http://dx.doi.org/10.1016/j.firesaf.2013.08.014

# =============================================================================
# CONFIGURATION
# =============================================================================

# Run name and paths
RUN_NAME="no-wind-with-slope"             # Run name
WORKDIR="."                               # Working directory path
INPUTS="$WORKDIR/inputs"                  # Inputs directory path
OUTPUTS="$WORKDIR/outputs"                # Outputs directory path
SCRATCH="$WORKDIR/scratch"                # Scratch directory path

# Computational domain
CELLSIZE=5.0                              # Grid size in meters
DOMAINSIZE=2000                           # Height and width of domain (m)
A_SRS="EPSG: 32610"                       # Spatial reference system

# Simulation timing
SIMULATION_TSTOP=7200.0                   # Simulation stop time (s)
DTDUMP=1200                               # Output dump interval (s)

# Fuel/Weather raster data
NUM_FLOAT_RASTERS=7
FLOAT_RASTER[1]=ws   ; FLOAT_VAL[1]=0.0   # Wind speed (mph)
FLOAT_RASTER[2]=wd   ; FLOAT_VAL[2]=0.0   # Wind direction (deg)
FLOAT_RASTER[3]=m1   ; FLOAT_VAL[3]=3.0   # 1-hr   dead moisture content (%)
FLOAT_RASTER[4]=m10  ; FLOAT_VAL[4]=5.0   # 10-hr  dead moisture content (%)
FLOAT_RASTER[5]=m100 ; FLOAT_VAL[5]=6.0   # 100-hr dead moisture content (%)
FLOAT_RASTER[6]=adj  ; FLOAT_VAL[6]=1.0   # Spread rate adjustment factor (-)
FLOAT_RASTER[7]=phi  ; FLOAT_VAL[7]=1.0   # Initial value of phi field (-)

NUM_INT_RASTERS=8
INT_RASTER[1]=slp     ; INT_VAL[1]=30     # Topographical slope (deg)
INT_RASTER[2]=asp     ; INT_VAL[2]=270    # Topographical aspect (deg)
INT_RASTER[3]=dem     ; INT_VAL[3]=0      # Elevation (m)
INT_RASTER[4]=fbfm40  ; INT_VAL[4]=10     # Fire behavior fuel model code (-)
INT_RASTER[5]=cc      ; INT_VAL[5]=70     # Canopy cover (%)
INT_RASTER[6]=ch      ; INT_VAL[6]=400    # Canopy height (10*m)
INT_RASTER[7]=cbh     ; INT_VAL[7]=20     # Canopy base height (10*m)
INT_RASTER[8]=cbd     ; INT_VAL[8]=15     # Canopy bulk density (100*kg/m3)

LH_MOISTURE_CONTENT=30.0                  # Live herb. moisture content (%)
LW_MOISTURE_CONTENT=60.0                  # Live woody moisture content (%)

# ELMFIRE executables
ELMFIRE_BASE_DIR=../../../../linux/bin
ELMFIRE_VER=${ELMFIRE_VER:-2025.0717}
ELMFIRE_BIN=$ELMFIRE_BASE_DIR/elmfire_$ELMFIRE_VER

# =============================================================================
# PREPARATION
# =============================================================================

# Output simulation start
echo
echo "====================================================================="
echo " ELMFIRE Simulation Run: $RUN_NAME"
echo "====================================================================="
echo

# Load helper functions
. ../../../../../tutorials/functions/functions.sh

# Clean previous run directories
echo "Cleaning directories..."
rm -f -r $INPUTS $OUTPUTS $SCRATCH
mkdir -p $INPUTS $OUTPUTS $SCRATCH

echo "Copying elmfire.data.in into $INPUTS..."
cp $WORKDIR/elmfire.data.in $INPUTS/elmfire.data

# Prepare static rasters
echo "Preparing computational domain..."
XMIN=`echo "0.0 - 0.5 * $DOMAINSIZE" | bc -l`
XMAX=`echo "0.0 + 0.5 * $DOMAINSIZE" | bc -l`
YMIN=$XMIN
YMAX=$XMAX

TR="$CELLSIZE $CELLSIZE"
TE="$XMIN $YMIN $XMAX $YMAX"

printf "x,y,z\n-100000,-100000,0\n100000,-100000,0\n-100000,100000,0\n100000,100000,0\n" > $SCRATCH/dummy.xyz

gdalwarp -tr 200000 200000 -te -100000 -100000 100000 100000 -s_srs "$A_SRS" -t_srs "$A_SRS" $SCRATCH/dummy.xyz $SCRATCH/dummy.tif
gdalwarp -dstnodata -9999 -ot Float32 -tr $TR -te $TE $SCRATCH/dummy.tif $SCRATCH/float.tif
gdalwarp -dstnodata -9999 -ot Int16   -tr $TR -te $TE $SCRATCH/dummy.tif $SCRATCH/int.tif

# Generate float input rasters
for i in $(eval echo "{1..$NUM_FLOAT_RASTERS}"); do
   gdal_calc.py -A $SCRATCH/float.tif --co="COMPRESS=DEFLATE" --co="ZLEVEL=9" --NoDataValue=-9999 --outfile="$INPUTS/${FLOAT_RASTER[i]}.tif" --calc="A + ${FLOAT_VAL[i]}"
done

# Generate integer input rasters
for i in $(eval echo "{1..$NUM_INT_RASTERS}"); do
   gdal_calc.py -A $SCRATCH/int.tif --co="COMPRESS=DEFLATE" --co="ZLEVEL=9" --NoDataValue=-9999 --outfile="$INPUTS/${INT_RASTER[i]}.tif" --calc="A + ${INT_VAL[i]}"
done

# Update elmfire.data with domain parameters
replace_line COMPUTATIONAL_DOMAIN_XLLCORNER "$XMIN" no
replace_line COMPUTATIONAL_DOMAIN_YLLCORNER "$YMIN" no
replace_line COMPUTATIONAL_DOMAIN_CELLSIZE "$CELLSIZE" no
replace_line SIMULATION_TSTOP $SIMULATION_TSTOP no
replace_line DTDUMP "$DTDUMP" no
replace_line LH_MOISTURE_CONTENT $LH_MOISTURE_CONTENT no
replace_line LW_MOISTURE_CONTENT $LW_MOISTURE_CONTENT no
replace_line A_SRS "$A_SRS" yes

# =============================================================================
# RUNNING ELMFIRE
# =============================================================================
echo "Running ELMFIRE..."
"$ELMFIRE_BIN" "$INPUTS/elmfire.data"

# Post-process outputs
echo "Post-processing outputs..."
for f in "$OUTPUTS"/*.bil; do
   fname=$(basename "$f" .bil)
   gdal_translate -a_srs "$A_SRS" -co "COMPRESS=DEFLATE" -co "ZLEVEL=9" "$f" "$OUTPUTS/${fname}.tif"
done

# Create hourly isochrones
gdal_contour -i $DTDUMP $(ls "$OUTPUTS"/time_of_arrival*.tif) "$OUTPUTS/isochrones.shp"

# Copy input references
cp "$INPUTS/elmfire.data" "$OUTPUTS/elmfire.data"
cp "$INPUTS/fbfm40.tif" "$OUTPUTS/fbfm40.tif"

# Clean up scratch
rm -rf "$SCRATCH"

echo "Run complete!"
exit 0