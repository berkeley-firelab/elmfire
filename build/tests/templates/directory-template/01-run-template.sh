#!/bin/bash

# Run Name: Template
# Contact: [Email]

# Note:  This example case includes all the possible inputs for use of ELMFIRE
#        with the WUI, spotting, etc. models implemented. See the model details
#        for more information. 

# WARNING:  Also check consistency in elmfire.data.in. Namelists specified here
#           may replace specification in elmfire.data.in. 

# ==============================================================================================
# CONFIGURATION
# ==============================================================================================

# Run name and paths
RUN_NAME="template"                     # Run name
WORKDIR="."                             # Working directory path
INPUTS="$WORKDIR/inputs"                # Inputs directory path
OUTPUTS="$WORKDIR/outputs"              # Outputs directory path
SCRATCH="$WORKDIR/scratch"              # Scratch directory path

# Computational domain
CENTER_LAT=37.992275                    # Latitude of center point
CENTER_LON=-122.223360                  # Longitude of center point
A_SRS="EPSG: 32610"                       # Spatial reference system

# Data fetch toggles
USE_LANDFIRE=true                       # true: download fuels; false: you must provide raster filenames
WX_FETCH=false                          # true: download transient weather rasters; false: you must provide .csv or raster inputs

# Fuel settings
FUEL_VERSION="2.4.0"                    # Landfire version if applicable

# Weather settings (only used if WX_FETCH=true)
WX_TYPE="historical"                    # forecast | historical
WX_START="2019-07-15 12:00"             # Start time (UTC) if WX_FETCH=true
WX_NUM_HOURS=48                         # Duration of historical weather (only used if WX_TYPE=historical)
WX_FILE="wx.csv"                        # If WX_FETCH=false, you must provide a CSV with weather time series (columns: ws, wd, etc.)

# Simulation timing
SIMULATION_TSTOP=7200.0                 # Simulation stop time (s)
DTDUMP=3600                             # Output dump interval (s)

# ELMFIRE executable
ELMFIRE_BASE_DIR=../../../../linux/bin
ELMFIRE_VER=${ELMFIRE_VER:-2025.0717}
ELMFIRE_BIN=$ELMFIRE_BASE_DIR/elmfire_$ELMFIRE_VER

# ==============================================================================================
# PREPARATION
# ==============================================================================================

# output simulation start
echo
echo "====================================================================="
echo " ELMFIRE Simulation Run: $RUN_NAME"
echo "====================================================================="
echo " Fuel data fetch:      $USE_LANDFIRE"
echo " Weather data fetch:   $WX_FETCH"
if [ "$WX_FETCH" = true ]; then
  echo "   Weather type:       $WX_TYPE"
  echo "   Weather start:      $WX_START"
  if [ "$WX_TYPE" = "historical" ]; then
    echo "   Weather duration:   $WX_NUM_HOURS hours"
  fi
fi
echo " Domain center:        $CENTER_LAT , $CENTER_LON"
echo " Ignition:             $POINT_IGNITION at ($IGN_LAT,$IGN_LON), radius $IGN_RADIUS m"
echo

# Generate fuel/weather/ignition data
if $USE_LANDFIRE || $WX_FETCH || $DO_IGNITION; then
    echo "Generating rasters via fuel_wx_ign.py..."
    CMD="~/elmfire/cloudfire/fuel_wx_ign.py"
    CMD+=" --name=$RUN_NAME"
    CMD+=" --outdir=$WORKDIR/fuel"
    CMD+=" --center_lat=$CENTER_LAT"
    CMD+=" --center_lon=$CENTER_LON"
    CMD+=" --do_fuel=$USE_LANDFIRE"
    CMD+=" --fuel_source='landfire'"
    CMD+=" --fuel_version='$FUEL_VERSION'"
    CMD+=" --do_wx=$WX_FETCH"
    if [ "$WX_FETCH" = true ]; then
      CMD+=" --wx_type='$WX_TYPE'"
      CMD+=" --wx_start_time=\"$WX_START\""
      if [ "$WX_TYPE" = "historical" ]; then
        CMD+=" --wx_num_hours=$WX_NUM_HOURS"
      fi
    fi

    echo "---------------------------------------------------------"
    echo "fuel_wx_ign.py command:"
    echo "$CMD"
    echo "---------------------------------------------------------"
    eval $CMD
else
    echo "Skipping data fetch: using local rasters."
fi

# Load helper functions
. ../../../../../tutorials/functions/functions.sh

# Clean previous run directories
echo "Cleaning directories..."
rm -f -r $INPUTS $OUTPUTS $SCRATCH
mkdir -p $INPUTS $OUTPUTS $SCRATCH

echo "Copying elmfire.data.in into $INPUTS..."
cp $WORKDIR/elmfire.data.in $INPUTS/elmfire.data

# Unpack Landfire tarball if needed
if $USE_LANDFIRE; then
    echo "Extracting Landfire inputs..."
    tar -xvf "$WORKDIR/fuel/${RUN_NAME}.tar" -C "$INPUTS"
    rm -f "$INPUTS"/m*.tif "$INPUTS"/w*.tif "$INPUTSR"/l*.tif "$INPUTS"/ignition*.tif "$INPUTS"/forecast_cycle.txt
fi

# Prepare static rasters
echo "Preparing computational domain..."
XMIN=$(gdalinfo "$INPUTS/fbfm40.tif" | grep 'Lower Left' | cut -d '(' -f2 | cut -d ',' -f1 | xargs)
YMIN=$(gdalinfo "$INPUTS/fbfm40.tif" | grep 'Lower Left' | cut -d '(' -f2 | cut -d ',' -f2 | cut -d ')' -f1 | xargs)
XMAX=$(gdalinfo "$INPUTS/fbfm40.tif" | grep 'Upper Right' | cut -d '(' -f2 | cut -d ',' -f1 | xargs)
YMAX=$(gdalinfo "$INPUTS/fbfm40.tif" | grep 'Upper Right' | cut -d '(' -f2 | cut -d ',' -f2 | cut -d ')' -f1 | xargs)
XCEN=$(echo "0.5*($XMIN + $XMAX)" | bc)
YCEN=$(echo "0.5*($YMIN + $YMAX)" | bc)
A_SRS=$(gdalsrsinfo "$INPUTS/fbfm40.tif" | grep PROJ.4 | cut -d ':' -f2 | xargs)
CELLSIZE=$(gdalinfo "$INPUTS/fbfm40.tif" | grep 'Pixel Size' | cut -d '(' -f2 | cut -d ',' -f1)

# Create dummy float raster for weather interpolation
gdalwarp -multi -dstnodata -9999 \
  -tr 300 300 \
  -te "$XMIN" "$YMIN" "$XMAX" "$YMAX" \
  "$INPUTS/adj.tif" "$SCRATCH/dummy.tif"
gdal_calc.py -A "$SCRATCH/dummy.tif" --NoDataValue=-9999 \
  --type=Float32 --outfile="$SCRATCH/float.tif" --calc="A*0.0"

# Generate transient weather rasters
if [ "$WX_FETCH" = false ]; then
    echo "Generating transient weather rasters from $WX_FILE..."
    COLS=$(head -n 1 "$WX_FILE" | tr ',' ' ')
    tail -n +2 "$WX_FILE" > "$SCRATCH/wx.csv"
    NUM_TIMES=$(cat "$SCRATCH/wx.csv" | wc -l)

    ICOL=0
    for QUANTITY in $COLS; do
        let "ICOL = ICOL + 1"
        TIMESTEP=0
        FNLIST=''
        while read LINE; do
            VAL=$(echo "$LINE" | cut -d',' -f$ICOL)
            FNOUT="$SCRATCH/${QUANTITY}_${TIMESTEP}.tif"
            FNLIST="$FNLIST $FNOUT"
            gdal_calc.py -A "$SCRATCH/float.tif" --NoDataValue=-9999 --type=Float32 --outfile="$FNOUT" --calc="A + $VAL" >& /dev/null &
            let "TIMESTEP+=1"
        done < $SCRATCH/wx.csv
        wait
        gdal_merge.py -separate -n -9999 -init -9999 -a_nodata -9999 -co "COMPRESS=DEFLATE" -co "ZLEVEL=9" -o "$INPUTS/$QUANTITY.tif" $FNLIST
    done
fi

# Update elmfire.data with domain parameters
replace_line COMPUTATIONAL_DOMAIN_XLLCORNER "$XMIN" no
replace_line COMPUTATIONAL_DOMAIN_YLLCORNER "$YMIN" no
replace_line COMPUTATIONAL_DOMAIN_CELLSIZE "$CELLSIZE" no
replace_line DTDUMP "$DTDUMP" no
replace_line A_SRS "$A_SRS" yes
replace_line X_IGN\(1\) "$XCEN" no
replace_line Y_IGN\(1\) "$YCEN" no

# ==============================================================================================
# RUNNING ELMFIRE
# ==============================================================================================
echo "Running ELMFIRE..."
"$ELMFIRE_BIN" "$INPUTS/elmfire.data"

# Post-process outputs
echo "Post-processing outputs..."
for f in "$OUTPUTS"/*.bil; do
    fname=$(basename "$f" .bil)
    gdal_translate -a_srs "$A_SRS" -co "COMPRESS=DEFLATE" -co "ZLEVEL=9" "$f" "$OUTPUTS/${fname}.tif"
done

# Create isochrones
gdal_contour -i $DTDUMP $(ls "$OUTPUTS"/time_of_arrival*.tif) "$OUTPUTS/isochrones.shp"

# Copy input references
cp "$INPUTS/elmfire.data" "$OUTPUTS/elmfire.data"
cp "$INPUTS/fbfm40.tif" "$OUTPUTS/fbfm40.tif"

# Clean up scratch
rm -rf "$SCRATCH"

echo "Run complete!"
exit 0