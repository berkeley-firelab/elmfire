! *****************************************************************************
MODULE ELMFIRE_VARS
! *****************************************************************************

USE MPI_F08
USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_F_POINTER

IMPLICIT NONE

! Global Constants
REAL, PARAMETER :: PI     = 3.14159265358979323846264338327950288419716
REAL, PARAMETER :: PIO180 = PI / 180.
INTEGER, PARAMETER :: LUINPUT = 100, LUOUTPUT = 200, LUSMOKE=800, LUFIT=9000, LUBAT=7000, LUTASL=5000, &
                      LUAUXINPUT = 4000, LUNODES = 10000

! Namelist group inputs, organized by namelist group:

! &CALIBRATION
INTEGER :: DURATION_MAX_DAYS, NUM_MONTE_CARLO_VARIABLES, NUM_PARAMETERS_MISC, &
           NUM_PARAMETERS_RASTERS, NUM_PARAMETERS_SPOTTING

LOGICAL :: ADJUSTMENT_FACTORS_BY_PYROME, CALIBRATION_CONSTANTS_BY_PYROME, DURATION_PDF_BY_PYROME
INTEGER, ALLOCATABLE, DIMENSION(:) :: PYROME_ID_ARR

CHARACTER(400) :: ADJUSTMENT_FACTORS_FILENAME, CALIBRATION_CONSTANTS_FILENAME, DURATION_PDF_FILENAME

REAL, ALLOCATABLE, DIMENSION(:,:) :: ADJ_PYROME, DURATION_PDF_PYROME, DURATION_CDF_PYROME
REAL, ALLOCATABLE, DIMENSION(:) :: INITIAL_ATTACK_TIME_PYROME, B_SDI_PYROME, MAX_CONTAINMENT_PER_DAY_PYROME, &
                                   AREA_NO_CONTAINMENT_CHANGE_PYROME, SIMULATION_DURATION_PYROME, &
                                   IGNITION_DENSITY_ADJ_PYROME

! &COMPUTATIONAL_DOMAIN
CHARACTER(400) :: A_SRS
REAL :: COMPUTATIONAL_DOMAIN_CELLSIZE, COMPUTATIONAL_DOMAIN_XLLCORNER, COMPUTATIONAL_DOMAIN_YLLCORNER

! &INPUTS
! Filenames:
CHARACTER(400) ::  ADJ_FILENAME,  ASP_FILENAME,  BLDG_AREA_FILENAME, BLDG_FOOTPRINT_FRAC_FILENAME, BLDG_FUEL_MODEL_FILENAME, &
                   BLDG_SEPARATION_DIST_FILENAME, BLDG_NONBURNABLE_FRAC_FILENAME, CBD_FILENAME, CBH_FILENAME, CC_FILENAME, &
                   CH_FILENAME, DEM_FILENAME, FBFM_FILENAME, IGNITION_MASK_FILENAME, IGNITIONS_CSV_FILENAME, &
                   LAND_VALUE_FILENAME, PHI_FILENAME, &
                   POPULATION_DENSITY_FILENAME, REAL_ESTATE_VALUE_FILENAME, SLP_FILENAME, ERC_FILENAME, &
                   FMC_FILENAME, M1_FILENAME, M10_FILENAME, M100_FILENAME, MLH_FILENAME, MLW_FILENAME, &
                   PYROMES_FILENAME, RH_FILENAME, SDI_FILENAME, TMP_FILENAME, WD_FILENAME, WS_FILENAME, TIMED_LOCATIONS_CSV

! Directories:
CHARACTER(400) ::  FUELS_AND_TOPOGRAPHY_DIRECTORY, OUTPUTS_DIRECTORY, WEATHER_DIRECTORY

INTEGER :: NUM_METEOROLOGY_TIMES

REAL :: DT_METEOROLOGY, FOLIAR_MOISTURE_CONTENT, GRID_DECLINATION, LH_MOISTURE_CONTENT, &
        LW_MOISTURE_CONTENT

LOGICAL :: CALCULATE_FLAME_LENGTH_STATS, CALCULATE_TIMES_BURNED, CBD_TIMES_100,  &
           CBH_TIMES_10,  CC_IN_PERCENT,  CH_TIMES_10, &
           DEAD_MC_IN_PERCENT, LIVE_MC_IN_PERCENT, USE_CONSTANT_FMC, USE_CONSTANT_LH, USE_CONSTANT_LW, &
           USE_EXISTING_BSQS=.FALSE., USE_LAND_VALUE, USE_POPULATION_DENSITY, USE_REAL_ESTATE_VALUE, &
           USE_TILED_IO, WS_AT_10M, VRT_INSTEAD_OF_TIF=.FALSE.

! &MISCELLANEOUS
CHARACTER(400)   :: BUILDING_FUEL_MODEL_FILE, FUEL_MODEL_FILE, MISCELLANEOUS_INPUTS_DIRECTORY, PATH_TO_GDAL, SCRATCH

! &MONTE_CARLO
INTEGER :: NUM_ENSEMBLE_MEMBERS, NUM_RASTERS_TO_PERTURB, RANDOM_IGNITIONS_TYPE, SEED, &
           METEOROLOGY_BAND_START, METEOROLOGY_BAND_STOP, METEOROLOGY_BAND_SKIP_INTERVAL

REAL :: ADD_TO_IGNITION_MASK, IGNITION_MASK_SCALE_FACTOR, WIND_DIRECTION_FLUCTUATION_INTENSITY_MIN, &
        WIND_DIRECTION_FLUCTUATION_INTENSITY_MAX, WIND_SPEED_FLUCTUATION_INTENSITY_MIN, &
        WIND_SPEED_FLUCTUATION_INTENSITY_MAX
REAL, DIMENSION(1:100) :: PDF_LOWER_LIMIT, PDF_UPPER_LIMIT

CHARACTER(60), DIMENSION(1:100) :: PDF_TYPE, RASTER_TO_PERTURB, SPATIAL_PERTURBATION, TEMPORAL_PERTURBATION
LOGICAL :: CSV_FIXED_IGNITION_LOCATIONS, ERC_IS_PLIGNRATE, PERTURB_WIND_DIRECTION_FLUCTUATION_INTENSITY, &
           PERTURB_WIND_SPEED_FLUCTUATION_INTENSITY, USE_ERC, USE_IGNITION_MASK

REAL :: PERTURB_ADJ=0., PERTURB_CBD=0., PERTURB_CBH=0., PERTURB_FMC=0., PERTURB_M1=0., PERTURB_M10=0., PERTURB_M100=0., &
        PERTURB_MLH=0., PERTURB_MLW=0., PERTURB_WAF=0., PERTURB_WD=0., PERTURB_WS=0.

! &OUTPUTS
LOGICAL :: ACCUMULATE_EMBER_FLUX, CONVERT_TO_GEOTIFF, DUMP_AFFECTED_LAND_VALUE, DUMP_AFFECTED_POPULATION, &
           DUMP_AFFECTED_REAL_ESTATE_VALUE, DUMP_BINARY_OUTPUTS, DUMP_CROWN_FIRE, &
           DUMP_EMBER_FLUX, DUMP_CROWN_FIRE_AREA, DUMP_FIRE_SIZE_STATS, DUMP_FIRE_VOLUME, &
           DUMP_FLAME_LENGTH, DUMP_FLIN, DUMP_HOURLY_RASTERS, DUMP_HPUA, DUMP_PHI, &
           DUMP_REACTION_INTENSITY, DUMP_REAL_ESTATE_VALUE, &
           DUMP_SPOTTING_IGNITION_TIME, DUMP_SPREAD_RATE, DUMP_SURFACE_FIRE, DUMP_SURFACE_FIRE_AREA, DUMP_TAGGED, &
           DUMP_TIME_OF_ARRIVAL, DUMP_TIMINGS, DUMP_TRANSIENT_ACREAGE, DUMP_VELOCITY, DUMP_WD20, &
           DUMP_WS20, ROTATE_ASP, ROTATE_WD, USE_EMBER_COUNT_BINS, USE_FLAME_LENGTH_BINS, DUMP_SPOTTING_OUTPUTS, &
           DUMP_TOTAL_DFC_RECEIVED, DUMP_TOTAL_RAD_RECEIVED, DUMP_HRR_TRANSIENT, &
           FULL_BINARY_OUTPUTS
INTEGER :: NUM_EMBER_COUNT_BINS, NUM_FLAME_LENGTH_BINS, NUM_TIME_AT_BURNED_ACRES
REAL :: BINARY_OUTPUTS_DUMP_FRACTION, DTDUMP, FLAME_LENGTH_BIN_LO(100), FLAME_LENGTH_BIN_HI(100), MINIMUM_AREA_FOR_BINARY_OUTPUTS
INTEGER*2 :: EMBER_COUNT_BIN_LO(100), EMBER_COUNT_BIN_HI(100)
CHARACTER(80) :: RUN_ID
REAL, ALLOCATABLE, DIMENSION(:) :: TIME_AT_BURNED_ACRES

! &SIMULATOR
INTEGER :: BANDTHICKNESS, BLDG_SPREAD_MODEL_TYPE, BLDG_FUEL_MODEL_CONSTANT
LOGICAL :: ALLOW_MULTIPLE_IGNITIONS_AT_A_PIXEL, ALLOW_NONBURNABLE_PIXEL_IGNITION, &
           ESTIMATE_URBAN_LOSSES, RANDOMIZE_RANDOM_SEED, RANDOM_IGNITIONS, UNTAG_TYPE_2, UNTAG_TYPE_3, &
           WIND_FLUCTUATIONS, USE_CONSTANT_BLDG_SPREAD_MODEL_PARAMS, USE_BLDG_SPREAD_MODEL, USE_PYROMES, &
           MULTIPLE_HOSTS, WX_BILINEAR_INTERPOLATION

REAL :: ANALYSIS_CELLSIZE, ANALYSIS_XLLCORNER, ANALYSIS_YLLCORNER, BLDG_AREA_CONSTANT, BLDG_FOOTPRINT_FRAC_CONSTANT, &
        BLDG_NONBURNABLE_FRAC_CONSTANT, BLDG_SEPARATION_DIST_CONSTANT, CRITICAL_CANOPY_COVER, &
        CROWN_FIRE_ADJ, CROWN_FIRE_SPREAD_RATE_LIMIT, DT_WIND_FLUCTUATIONS, EDGEBUFFER, MAX_LOW, MAX_RUNTIME, &
        PERCENT_OF_PIXELS_TO_IGNITE, &
        PHIS_ADJ, PHIW_ADJ, PLIGNRATE_MIN, SURFACE_ACCELERATION_TIME_CONSTANT, WIND_DIRECTION_FLUCTUATION_INTENSITY, &
        WIND_SPEED_FLUCTUATION_INTENSITY

REAL, DIMENSION(0:100) :: T_IGN, X_IGN, Y_IGN

INTEGER :: CROWN_FIRE_MODEL, DEBUG_LEVEL, MODE, NUM_IGNITIONS, NUM_NODES_OMP_THRESHOLD, UNTAG_CELLS_TIMESTEP_INTERVAL

! &SPOTTING
INTEGER, PARAMETER :: EMBER_TRACKER_SIZE = 10000000
INTEGER :: NEMBERS, NEMBERS_MAX, NEMBERS_MAX_HI, NEMBERS_MAX_LO, NEMBERS_MIN, NEMBERS_MIN_HI, NEMBERS_MIN_LO

REAL :: CRITICAL_SPOTTING_FIRELINE_INTENSITY(0:303), CROWN_FIRE_SPOTTING_PERCENT, CROWN_FIRE_SPOTTING_PERCENT_MAX, &
        CROWN_FIRE_SPOTTING_PERCENT_MIN, CROWN_RATIO, GLOBAL_SURFACE_FIRE_SPOTTING_PERCENT, &
        GLOBAL_SURFACE_FIRE_SPOTTING_PERCENT_MAX, GLOBAL_SURFACE_FIRE_SPOTTING_PERCENT_MIN, MAX_SPOTTING_DISTANCE, & 
        MEAN_SPOTTING_DIST, MEAN_SPOTTING_DIST_MAX, MEAN_SPOTTING_DIST_MIN, MIN_SPOTTING_DISTANCE, &
        NORMALIZED_SPOTTING_DIST_VARIANCE, NORMALIZED_SPOTTING_DIST_VARIANCE_MAX, NORMALIZED_SPOTTING_DIST_VARIANCE_MIN, &
        PIGN, PIGN_MAX, PIGN_MIN, SPOT_FLIN_EXP, SPOT_FLIN_EXP_HI, SPOT_FLIN_EXP_LO, SPOT_WS_EXP, SPOT_WS_EXP_HI, &
        SPOT_WS_EXP_LO

LOGICAL :: ENABLE_SPOTTING, ENABLE_SURFACE_FIRE_SPOTTING, STOCHASTIC_SPOTTING, USE_SUPERSEDED_SPOTTING

CHARACTER(60) :: SPOTTING_DISTRIBUTION_TYPE

REAL, DIMENSION(0:303) :: SURFACE_FIRE_SPOTTING_PERCENT, SURFACE_FIRE_SPOTTING_PERCENT_MULT, SOURCE_FUEL_IGN_MULT

! Extra variables for UMD Spotting models
REAL :: EMBER_GR, TAU_EMBERGEN, P_EPS, EMBER_SAMPLING_FACTOR, DT_DUMP_EMBER_FLUX, CRITICAL_IGNITION_EMBER_NUMBER_LOAD, &
        LOCAL_IGNITION_TIME, CELL_IGNITION_DELAY,  MU_CROSSWIND, SIGMA_CROSSWIND, MU_DOWNWIND, SIGMA_DOWNWIND

LOGICAL :: USE_UMD_SPOTTING_MODEL, USE_PHYSICAL_SPOTTING_DURATION, USE_PHYSICAL_EMBER_NUMBER, USE_EULERIAN_SPOTTING, &
           NO_SURFACE_FIRE, USE_HALF_CFL_DT_FOR_SPOTTING, BUILD_EMBER_FLUX_TABLE, USE_EMBER_IGNITION_MODEL, &
           USE_SIMPLE_IGNITION_MODEL, USE_CUSTOMIZED_PDF

REAL, ALLOCATABLE, DIMENSION(:) :: SPOTTING_TIME_TABLE
        ! Global 2D array (NX by NY) variables added for ignition model
REAL, ALLOCATABLE, DIMENSION(:,:) :: T_LOCAL_IGNITION 
LOGICAL, ALLOCATABLE, DIMENSION(:,:) :: LOCAL_IGNITION

! &SMOKE
REAL :: DT_SMOKE_OUTPUTS, PM2P5_RELEASE_MIN_FOR_OUTPUT, SMOKE_HOC, SMOKE_YIELD, SMOKE_YIELD_BY_FUEL(0:303), &
        SMOKE_OUTPUTS_DUMP_PERCENT
LOGICAL :: ENABLE_SMOKE_OUTPUTS, USE_SMOKE_YIELD_BY_FUEL

! &SUPPRESSION
REAL :: AREA_NO_CONTAINMENT_CHANGE, B_SDI, INITIAL_ATTACK_TIME, DT_EXTENDED_ATTACK, &
        MAX_CONTAINMENT_PER_DAY, SDI_FACTOR
LOGICAL :: ENABLE_EXTENDED_ATTACK, ENABLE_INITIAL_ATTACK, USE_SDI, USE_SDI_LOG_FUNCTION

! &TIME_CONTROL
REAL :: BURN_PERIOD_CENTER_FRAC,BURN_PERIOD_LENGTH, DT_INTERPOLATE_M1, DT_INTERPOLATE_M10, &
        DT_INTERPOLATE_M100, DT_INTERPOLATE_MLH, DT_INTERPOLATE_MLW, DT_INTERPOLATE_FMC, DT_INTERPOLATE_WIND, &
        FORECAST_START_HOUR, LATITUDE, LONGITUDE, OVERNIGHT_ADJUSTMENT_FACTOR, SIMULATION_DT, SIMULATION_DTMAX, &
        SIMULATION_TSTART, SIMULATION_TSTOP, SUNRISE_HOUR, SUNSET_HOUR, TARGET_CFL
INTEGER :: BAND_ONE_HOUR_OF_YEAR, CURRENT_YEAR, HOUR_OF_YEAR
LOGICAL :: RANDOMIZE_SIMULATION_TSTOP, USE_DIURNAL_ADJUSTMENT_FACTOR

! MPI:
CHARACTER(1000) :: PROCNAME
INTEGER :: LENPROCNAME, NPROC=1, NPROC_HOST=1
TYPE(MPI_STATUS) :: ISTATUS
TYPE(MPI_COMM) :: MPI_COMM_HOST, MPI_COMM_HOST_IRANK0
INTEGER(KIND=MPI_ADDRESS_KIND) :: ANALYSIS_SINGLEBAND_SIZE_REAL, ANALYSIS_SINGLEBAND_SIZE_INT, &
                                  ANALYSIS_SINGLEBAND_SIZE_L1, WX_SIZE, STATS_SIZE, TIMINGS_SIZE
TYPE(C_PTR) :: ASP_PTR, CBH_PTR, CBD_PTR, CC_PTR, CH_PTR, DEM_PTR, FBFM_PTR, SLP_PTR, ADJ_PTR, PHI0_PTR, &
               POPULATION_DENSITY_PTR, REAL_ESTATE_VALUE_PTR, LAND_VALUE_PTR, WAF_PTR, &
               OMCOSSLPRAD_PTR, WS_PTR, WD_PTR, M1_PTR, M10_PTR, M100_PTR, MLH_PTR, MLW_PTR, MFOL_PTR, ERC_PTR, &
               IGNFAC_PTR, STATS_X_PTR, STATS_Y_PTR, STATS_ASTOP_PTR, STATS_SURFACE_FIRE_AREA_PTR, &
               STATS_CROWN_FIRE_AREA_PTR, STATS_FIRE_VOLUME_PTR, STATS_AFFECTED_POPULATION_PTR, &
               STATS_AFFECTED_REAL_ESTATE_VALUE_PTR, STATS_AFFECTED_LAND_VALUE_PTR, STATS_NEMBERS_PTR, &
               STATS_IWX_BAND_START_PTR, STATS_IWX_SERIAL_BAND_PTR, STATS_SIMULATION_TSTOP_HOURS_PTR, &
               STATS_TSTOP_PTR, &
               STATS_WALL_CLOCK_TIME_PTR, ISNONBURNABLE_PTR, TIMINGS_PTR, IGN_MASK_PTR, SDI_PTR, BLDG_AREA_PTR, &
               BLDG_FOOTPRINT_FRAC_PTR, BLDG_FUEL_MODEL_PTR, BLDG_NONBURNABLE_FRAC_PTR, BLDG_SEPARATION_DIST_PTR, &
               PYROMES_PTR, STATS_FINAL_CONTAINMENT_FRAC_PTR, &
               STATS_PM2P5_RELEASE_PTR, STATS_HRR_PEAK_PTR

TYPE(MPI_WIN) :: WIN_ASP,WIN_CBH,WIN_CBD,WIN_CC,WIN_CH,WIN_DEM,WIN_FBFM,WIN_SLP,WIN_ADJ,WIN_PHI0,WIN_POPULATION_DENSITY, &
                 WIN_REAL_ESTATE_VALUE,WIN_LAND_VALUE,WIN_WAF,WIN_OMCOSSLPRAD, WIN_WS, WIN_WD, &
                 WIN_M1, WIN_M10, WIN_M100, WIN_MLH, WIN_MLW, WIN_MFOL, WIN_ERC, WIN_IGNFAC, WIN_STATS_X, WIN_STATS_Y, WIN_STATS_ASTOP, &
                 WIN_STATS_TSTOP, &
                 WIN_STATS_SURFACE_FIRE_AREA, WIN_STATS_CROWN_FIRE_AREA, WIN_STATS_FIRE_VOLUME, &
                 WIN_STATS_AFFECTED_POPULATION, WIN_STATS_AFFECTED_REAL_ESTATE_VALUE, WIN_STATS_AFFECTED_LAND_VALUE, &
                 WIN_STATS_NEMBERS, WIN_STATS_IWX_BAND_START, WIN_STATS_IWX_SERIAL_BAND, WIN_STATS_SIMULATION_TSTOP_HOURS, &
                 WIN_STATS_WALL_CLOCK_TIME, WIN_ISNONBURNABLE, WIN_TIMINGS, WIN_IGN_MASK, WIN_SDI, WIN_BLDG_AREA, &
                 WIN_BLDG_FOOTPRINT_FRAC, WIN_BLDG_FUEL_MODEL, WIN_BLDG_NONBURNABLE_FRAC, WIN_BLDG_SEPARATION_DIST, &
                 WIN_PYROMES, WIN_STATS_FINAL_CONTAINMENT_FRAC, WIN_STATS_PM2P5_RELEASE, WIN_STATS_HRR_PEAK

INTEGER :: ARRAYSHAPE_ANALYSIS_SINGLEBAND(1:3), ARRAYSHAPE_WX(1:3), ARRAYSHAPE_STATS(1), &
           ARRAYSHAPE_TIMINGS(1:2), ARRAYSHAPE_ISNONBURNABLE(1:2), PARALLEL_IO_RANK(1:10000)

INTEGER :: DISP_UNIT=1, IRANK_HOST, IRANK_WORLD, NPROC_IRANK0

! For broadcasting all raster headers (NRMAX is number of rasters)
INTEGER      , PARAMETER :: NRMAX = 36
INTEGER      , DIMENSION(1:NRMAX) :: BANDROWBYTES_ARR, NBANDS_ARR, NBITS_ARR, NCOLS_ARR, NROWS_ARR, TOTALROWBYTES_ARR
REAL         , DIMENSION(1:NRMAX) :: CELLSIZE_ARR, NODATA_VALUE_ARR, ULXMAP_ARR, ULYMAP_ARR, XDIM_ARR, YDIM_ARR, XLLCORNER_ARR, &
                                     YLLCORNER_ARR
CHARACTER    , DIMENSION(1:NRMAX) :: BYTEORDER_ARR
CHARACTER(3) , DIMENSION(1:NRMAX) :: LAYOUT_ARR
CHARACTER(10), DIMENSION(1:NRMAX) :: PIXELTYPE_ARR

! Profiling:
INTEGER :: CLOCK_COUNT_MAX, CLOCK_COUNT_RATE, IT_START, IT_STOP, IT1_LSP
REAL, POINTER, DIMENSION (:,:) :: TIMINGS

! Lookup tables:
REAL, DIMENSION(0:90) :: COSSLP=0, TANSLP2=0. 
REAL, DIMENSION(-1:360) :: ABSSINASP=0., ABSCOSASP=0., SINASPM180=0., COSASPM180=0.
REAL, DIMENSION(0:3600) :: COSWDMPI, SINWDMPI
REAL, DIMENSION(0:100,0:120) :: SHELTERED_WAF_TABLE
REAL, ALLOCATABLE, DIMENSION(:) :: BOH_FROM_LOW, LOW_FROM_WSMFEFF
REAL, DIMENSION(0:303) :: WSMFEFF_COEFF, B_COEFF_INVERSE, TR
REAL, ALLOCATABLE, DIMENSION (:,:) :: WSMFEFF_FROM_FBFM_AND_PHIMAG
INTEGER, ALLOCATABLE, DIMENSION(:) :: ICOL_ANALYSIS_F2C, IROW_ANALYSIS_F2C
        ! lookup tables for UMD spotting model
INTEGER, ALLOCATABLE, DIMENSION(:,:,:,:) :: EMBER_TARGET_IX, EMBER_TARGET_IY
REAL, ALLOCATABLE, DIMENSION(:,:,:,:) :: EMBER_TOA
REAL, ALLOCATABLE, DIMENSION(:) :: TIME_LIST

! 2D geospatial arrays that are not TYPE(RASTER)
INTEGER*2, POINTER, DIMENSION(:,:) :: SURFACE_FIRE, EMBER_COUNT
LOGICAL*1, ALLOCATABLE, DIMENSION (:,:) :: TAGGED
LOGICAL*1, POINTER, DIMENSION (:,:) :: ISNONBURNABLE
REAL, ALLOCATABLE, DIMENSION(:,:) :: PHIP
LOGICAL, ALLOCATABLE, DIMENSION(:,:) :: EVERTAGGED
REAL, ALLOCATABLE, DIMENSION (:,:) :: TIME_OF_ARRIVAL, EMBER_TIGN

! 1D geospatial arrays
INTEGER*2, ALLOCATABLE, DIMENSION(:) :: EVERTAGGED_IX, EVERTAGGED_IY

REAL, POINTER, DIMENSION(:) :: STATS_X, STATS_Y, STATS_ASTOP, STATS_TSTOP, STATS_SURFACE_FIRE_AREA, STATS_CROWN_FIRE_AREA, &
                               STATS_FIRE_VOLUME, STATS_AFFECTED_POPULATION, STATS_AFFECTED_REAL_ESTATE_VALUE, &
                               STATS_AFFECTED_LAND_VALUE, STATS_NEMBERS, STATS_SIMULATION_TSTOP_HOURS, &
                               STATS_WALL_CLOCK_TIME, STATS_FINAL_CONTAINMENT_FRAC, STATS_PM2P5_RELEASE, STATS_HRR_PEAK
INTEGER, ALLOCATABLE, DIMENSION(:) :: IX_IGNFAC, IY_IGNFAC
INTEGER :: IXL_EDGEBUFFER, IYL_EDGEBUFFER, IXH_EDGEBUFFER, IYH_EDGEBUFFER
INTEGER*2, ALLOCATABLE, DIMENSION (:) :: EMBER_OUTPUTS_IX
INTEGER*2, ALLOCATABLE, DIMENSION (:) :: EMBER_OUTPUTS_IY
INTEGER*2, ALLOCATABLE, DIMENSION (:) :: EMBER_OUTPUTS_COUNT

! Calibration / optimization
REAL, ALLOCATABLE, DIMENSION(:) :: COEFFS, COEFFS_UNSCALED
REAL, ALLOCATABLE, DIMENSION(:,:) :: COEFFS_UNSCALED_BY_CASE

! OS-specific
CHARACTER(12) :: DELETECOMMAND = '/bin/rm -f '
CHARACTER(1) :: PATH_SEPARATOR
CHARACTER(7) :: OPERATING_SYSTEM

! Binary outputs
INTEGER*2, POINTER, DIMENSION (:) :: BINARY_OUTPUTS_IX            => NULL()
INTEGER*2, POINTER, DIMENSION (:) :: BINARY_OUTPUTS_IY            => NULL()
REAL, POINTER, DIMENSION      (:) :: BINARY_OUTPUTS_TOA           => NULL()
REAL, POINTER, DIMENSION      (:) :: BINARY_OUTPUTS_FLAME_LENGTH  => NULL()
REAL, POINTER, DIMENSION      (:) :: BINARY_OUTPUTS_VELOCITY_FPM  => NULL()
INTEGER*1, POINTER, DIMENSION (:) :: BINARY_OUTPUTS_CROWN_FIRE    => NULL()

! Miscellaneous variables (Broadcast EMBER_FLUX_TABLE_LEN for UMD Spotting Model):
INTEGER :: ANALYSIS_NCOLS,  ANALYSIS_NROWS, IWX_BAND_SKIP, IWX_BAND_START, IWX_BAND_STOP, NUM_CASES_TOTAL, &
           NUM_ENSEMBLE_MEMBERS0, NUM_EVERTAGGED, NUM_STARTING_WX_BANDS, NUM_TRACKED_EMBERS, WX_NCOLS, WX_NROWS, WX_NBANDS, &
           EMBER_FLUX_TABLE_LEN

INTEGER, POINTER, DIMENSION(:) :: STATS_IWX_BAND_START, STATS_IWX_SERIAL_BAND
INTEGER, ALLOCATABLE, DIMENSION(:) :: CSV_IBANDARR, CSV_ICASEARR, NUM_CASES_PER_STARTING_WX_BAND, &
                                      NUM_CASES_COMPLETE_PER_STARTING_WX_BAND, IWX_BAND_START_TEMP, &
                                      IWX_SERIAL_BAND_TEMP 

REAL :: DIURNAL_ADJUSTMENT_FACTOR = 1.0
REAL, POINTER, DIMENSION(:,:,:) :: WSP, WDP, M1P, M10P, M100P, MLHP, MLWP, MFOLP, ERCP, IGNFACP
REAL, ALLOCATABLE, DIMENSION(:) :: CSV_XARR, CSV_YARR, CSV_ASTOP, CSV_TSTOP

LOGICAL, ALLOCATABLE, DIMENSION(:) :: HOURLY_OUTPUTS_FROM_STARTING_WX_BAND_DUMPED

CHARACTER(400) :: NAMELIST_FN

REAL, ALLOCATABLE, DIMENSION(:) :: PROB, IGN_MASK_ARR, N_ARR_R
REAL, PARAMETER :: IGN_MASK_CRIT = 1E-30
INTEGER, ALLOCATABLE, DIMENSION(:) :: ICOL_ARR, IROW_ARR, N_ARR
INTEGER :: NUM_IGNITABLE_PIXELS

! Derived types:
TYPE :: FUEL_MODEL_TABLE_TYPE
   CHARACTER(400) :: SHORTNAME ! Short character string describing fuel model
   LOGICAL        :: DYNAMIC   ! Is this a dynamic fuel model?
   REAL           :: W0 (1:6)  ! Total fuel loading, lb/ft2
   REAL           :: WN (1:6)  ! Net   fuel loading, lb/ft2
   REAL           :: SIG(1:6)  ! Surface area to volume ratio, 1/ft
   REAL           :: DELTA     ! Fuel bed thickness, ft
   REAL           :: MEX_DEAD  ! Dead fuel moisture of extinction
   REAL           :: MEX_LIVE  ! Dead fuel moisture of extinction (starting)
   REAL           :: HOC       ! Heat of combustion, Btu/lb
   REAL           :: RHOB      ! Bulk density, lb/ft3
   REAL           :: RHOP      ! Particle density, lb/ft3
   REAL           :: ST        ! Mineral content, lb minerals / lb ovendry mass
   REAL           :: SE        ! Factor in ETAS
   REAL           :: ETAS      ! Mineral damping coefficient, dimensionless
   REAL           :: BETA      ! Packing ratio, dimensionless
   REAL           :: BETAOP    ! Optimal packing ratio, dimensionless
   REAL           :: XI        ! Propagating flux ratio, dimensionless
   
   REAL           :: A_COEFF ! "A" coefficient in Rothermel model
   REAL           :: B_COEFF ! "B" coefficient in Rothermel model
   REAL           :: C_COEFF ! "C" coefficient in Rothermel model
   REAL           :: E_COEFF ! "E" coefficient in Rothermel model

   REAL           :: GAMMAPRIME     ! Reaction velocity, 1/min
   REAL           :: GAMMAPRIMEPEAK ! Peak reaction velocity, 1/min 

   REAL           :: A_DEAD    ! Area factor for dead fuels
   REAL           :: A_LIVE    ! Area factor for live fuels
   REAL           :: A_OVERALL ! Area factor (overall)

   REAL           :: F_DEAD ! f factor for dead fuels
   REAL           :: F_LIVE ! f factor for live fuels

   REAL           :: W0_DEAD ! Total fuel loading for dead fuels, lb/ft2
   REAL           :: W0_LIVE ! Total fuel loading for live fuels, lb/ft2

   REAL           :: WN_DEAD ! Net fuel loading for dead fuels, lb/ft2
   REAL           :: WN_LIVE ! Net fuel loading for live fuels, lb/ft2
   
   REAL           :: SIG_DEAD    ! Surface area to volume ratio for dead fuels, 1ft
   REAL           :: SIG_LIVE    ! Surface area to volume ratio for live fuels, 1/ft
   REAL           :: SIG_OVERALL ! Surface area to volume ratio overall, 1/ft
   
   REAL           :: TR          ! Residence time, min

   REAL, DIMENSION (1:6) :: A           ! Area factor 
   REAL, DIMENSION (1:6) :: F           ! f factor
   REAL, DIMENSION (1:4) :: FMEX        ! f * mex_dead
   REAL, DIMENSION (1:6) :: FW0         ! f * w0
   REAL, DIMENSION (1:6) :: FSIG        ! f * sigma
   REAL, DIMENSION (1:6) :: EPS         ! epsilon (Surface heating number)
   REAL, DIMENSION (1:6) :: FEPS        ! f * epsilon
   REAL, DIMENSION (1:6) :: WPRIMENUMER ! Numerator of W'
   REAL, DIMENSION (1:6) :: WPRIMEDENOM ! Denominator of W'
   REAL, DIMENSION (1:6) :: MPRIMEDENOM ! Denominator of M'

! These are for performance optimizations:
   REAL :: GP_WND_EMD_ES_HOC ! = FM%GAMMAPRIME * FM%WN_DEAD * FM%ETAS * FM%HOC
   REAL :: GP_WNL_EML_ES_HOC ! = FM%GAMMAPRIME * FM%WN_LIVE * FM%ETAS * FM%HOC
   REAL :: PHISTERM          ! = (5.275 / FUEL_MODEL_TABLE(FBFM(IX,IY))%BETA**0.3)
   REAL :: PHIWTERM          ! = FM%C_COEFF * (FM%BETA / FM%BETAOP)**(-FM%E_COEFF)

   REAL :: WPRIMEDENOM56SUM ! = SUM(FM%WPRIMEDENOM(5:6))
   REAL :: WPRIMENUMER14SUM ! = SUM(FM%WPRIMENUMER(1:4))
   REAL :: MPRIMEDENOM14SUM ! = SUM(FM%MPRIMEDENOM(1:4))
   REAL :: R_MPRIMEDENOME14SUM_MEX_DEAD ! = 1. / (FM%MPRIMEDENOM14SUM * FM%MEX_DEAD)

   REAL :: UNSHELTERED_WAF !Wind adjustment factor when unsheltered

   REAL :: B_COEFF_INVERSE
   REAL :: WSMFEFF_COEFF 

END TYPE

TYPE(FUEL_MODEL_TABLE_TYPE), DIMENSION(0:303,30:120) :: FUEL_MODEL_TABLE_2D !Table for holding fuel models

INTEGER, PARAMETER :: NUM_BUILDING_FUEL_MODELS=100
TYPE :: BUILDING_FUEL_MODEL_TABLE_TYPE
   CHARACTER(80) :: SHORTNAME
   REAL :: T_1MW
   REAL :: T_EARLY
   REAL :: T_FULLDEV
   REAL :: T_DECAY
   REAL :: FUEL_LOAD
   REAL :: HRRPUA_PEAK
   REAL :: FTP_CRIT
   REAL :: ABSORPTIVITY
   REAL :: HEIGHT
   REAL :: NONBURNABLE_FRAC
   REAL :: P_IGNITION
END TYPE
TYPE(BUILDING_FUEL_MODEL_TABLE_TYPE), DIMENSION(0:NUM_BUILDING_FUEL_MODELS) :: BUILDING_FUEL_MODEL_TABLE

! Suppression
TYPE SUPPRESSION_TRACKER
   INTEGER :: NCELLS(0:359)
   REAL    :: VELOCITY(0:359)
   REAL    :: VELOCITY_SMOOTHED(0:359)
   REAL    :: FIRELINE_FRACTION(0:359)
   REAL    :: SUPPRESSED_FRACTION(0:359)
   REAL    :: T
   REAL    :: ACRES
   REAL    :: ACRES_SDI
   REAL    :: TARGET_CONTAINMENT
   REAL    :: DC_PER_DAY
   REAL    :: DADT
   REAL    :: DASDIDT
   REAL    :: SDIBAR
   INTEGER :: IXCEN
   INTEGER :: IYCEN
END TYPE SUPPRESSION_TRACKER
TYPE(SUPPRESSION_TRACKER), ALLOCATABLE, DIMENSION (:) :: SUPP

! Spotting
TYPE SPOTTING_TRACKER
   REAL :: X_FROM
   REAL :: Y_FROM
   REAL :: X_TO
   REAL :: Y_TO
   INTEGER :: IX_FROM
   INTEGER :: IY_FROM
   INTEGER :: IX_TO
   INTEGER :: IY_TO
   REAL :: DIST
   REAL :: TTRAVEL
   REAL :: TLAUNCH
   REAL :: TIGN
   REAL :: TAU
   LOGICAL :: POSITIVE_IGNITION
   LOGICAL :: ALREADY_IGNITED
END TYPE SPOTTING_TRACKER
TYPE (SPOTTING_TRACKER), ALLOCATABLE, DIMENSION(:) :: SPOTTING_STATS

!Types
TYPE :: RASTER_TYPE
   CHARACTER     :: BYTEORDER
   CHARACTER(3)  :: LAYOUT
   INTEGER       :: NROWS
   INTEGER       :: NCOLS
   INTEGER       :: NBANDS   
   INTEGER       :: NBITS
   INTEGER       :: BANDROWBYTES
   INTEGER       :: TOTALROWBYTES
   CHARACTER(10) :: PIXELTYPE
   REAL          :: ULXMAP
   REAL          :: ULYMAP
   REAL          :: XDIM
   REAL          :: YDIM
   REAL          :: NODATA_VALUE
   REAL          :: CELLSIZE
   REAL          :: XLLCORNER
   REAL          :: YLLCORNER
   REAL,POINTER, DIMENSION(:,:,:) :: R4 =>NULL()
   INTEGER*2,POINTER, DIMENSION(:,:,:) :: I2 =>NULL()
END TYPE

TYPE(RASTER_TYPE), TARGET :: ADJ, ANALYSIS_SURFACE_FIRE, ANALYSIS_TIMES_BURNED, ASP, &
                             CBD, CBH, CC, CH, DEM, FLAME_LENGTH_SUM, EMBER_BIN_COUNT, &
                             FLAME_LENGTH_BIN_COUNT, FLAME_LENGTH_MAX, FBFM, IGN_MASK, LAND_VALUE, OMCOSSLPRAD, &
                             PHI0, POPULATION_DENSITY, REAL_ESTATE_VALUE, SLP, ERC, MFOL, IGNFAC, M1, M10, M100, &
                             MLH, MLW, PYROMES, RH, TMP, WD, WS, WAF, EMBER_FLUX, TIMES_BURNED, TIMES_BURNED_HOURLY, SDI

TYPE(RASTER_TYPE), TARGET :: BLDG_AREA             ! Previously HAMADA_A
TYPE(RASTER_TYPE), TARGET :: BLDG_SEPARATION_DIST  ! Previously HAMADA_D
TYPE(RASTER_TYPE), TARGET :: BLDG_NONBURNABLE_FRAC ! Previously HAMADA_FB
TYPE(RASTER_TYPE), TARGET :: BLDG_FOOTPRINT_FRAC
TYPE(RASTER_TYPE), TARGET :: BLDG_FUEL_MODEL


! UCB declares variables
TYPE :: UCB_ELLIPSE
   REAL     :: DIST_DOWNWIND ! Downwind distance (a) [m]
   REAL     :: DIST_UPWIND ! Upwind distance (b) [m]
   REAL     :: DIST_SIDEWIND ! Sidewind distance (c) [m]

   INTEGER  :: FOREST_FACTOR ! urban = 1; forest = 3
   REAL     :: WIND_POWER = 2 ! Default 1

   REAL     :: ELLIPSE_MINOR ! Semiminor (A) [m]
   REAL     :: ELLIPSE_MAJOR ! Semimajor (B) [m]
   REAL     :: ELLIPSE_ECCENTRICITY ! Eccentricity (E) [m]

END TYPE UCB_ELLIPSE


! Doubly linked list variables
TYPE NODE
   TYPE(NODE), POINTER :: NEXT => NULL()
   TYPE(NODE), POINTER :: PREV => NULL()
   TYPE(UCB_ELLIPSE) :: ELLIPSE_PARAMETERS

   INTEGER   :: BLDG_FUEL_MODEL = 0
   INTEGER*1 :: CROWN_FIRE =  0
   INTEGER   :: IX         = -1
   INTEGER   :: IY         = -1

   LOGICAL :: BURNED            = .FALSE.
   LOGICAL :: JUST_TAGGED       = .TRUE.

   REAL :: BLDG_AREA                     = 0. ! Was HAMADA_A
   REAL :: BLDG_NONBURNABLE_FRAC         = 0. ! Was HAMADA_FB
   REAL :: BLDG_SEPARATION_DIST          = 0. ! Was HAMADA_D
   REAL :: BLDG_FOOTPRINT_FRAC           = 0.
   REAL :: CRITICAL_FLIN                 = 9E9
   REAL :: DPHIDX_LIMITED                = 0.
   REAL :: DPHIDY_LIMITED                = 0.
   REAL :: FLAME_LENGTH                  = 0.
   REAL :: FLIN_CANOPY                   = 0.
   REAL :: FLIN_DMS_SURFACE              = 0.
   REAL :: FLIN_SURFACE                  = 0.
   REAL :: FMC                           = 0.
   REAL :: HPUA_CANOPY                   = 0.
   REAL :: HPUA_SURFACE                  = 0.
   REAL :: IR                            = 0.
   REAL :: M1                            = 0.
   REAL :: M10                           = 0.
   REAL :: M100                          = 0.
   REAL :: MLH                           = 0.
   REAL :: MLW                           = 0.
   REAL :: NORMVECTORX                   = 0.
   REAL :: NORMVECTORY                   = 0.
   REAL :: PHIS_SURFACE                  = 0.
   REAL :: PHIW_CROWN                    = 0.
   REAL :: PHIW_SURFACE                  = 0.
   REAL :: SUPPRESSION_ADJUSTMENT_FACTOR = 1.0
   INTEGER :: SUPPRESSION_IDEG           = 9999
   REAL :: TIME_ADDED                    = -1.0
   REAL :: TIME_OF_ARRIVAL               = -1.0
   REAL :: TIME_SUPPRESSED               = -1.0
   REAL :: UX                            = 0.
   REAL :: UY                            = 0.
   REAL :: VELOCITY                      = 0.
   REAL :: VELOCITY_DMS                  = 0.
   REAL :: VS0                           = 0.
   REAL :: WD20_INTERP                   = 0.
   REAL :: WD20_NOW                      = 0.
   REAL :: WS20_INTERP                   = 0.
   REAL :: WS20_NOW                      = 0.
   REAL :: WSMF                          = 0.
   REAL :: SDI                           = 0.
   REAL :: TAU_EMBERGEN                  = 0.
   REAL :: VELOCITY_DMS_SURFACE          = 0.
   REAL :: LOCAL_EMBERGEN_DURATION       = 0.

! For optimization purposes
   LOGICAL   :: NEED_SLOPE_CALC = .TRUE.
   REAL      :: PHISX = -9999.
   REAL      :: PHISY = -9999.
   REAL      :: UXOUSX = -9999.
   REAL      :: UYOUSY = -9999.
   REAL      :: NORMVECTORX_DMS = -9999.
   REAL      :: NORMVECTORY_DMS = -9999.
   REAL      :: VBACK = -9999.
   REAL      :: LOW = -9999.
   INTEGER*2 :: IFBFM = 0
   REAL      :: ADJ
   REAL      :: TANSLP2
   REAL      :: PHIP_OLD
   REAL      :: DUMPME

! For smoke
   REAL :: TIME_IGNITED      = 0.
   REAL :: TIME_EXTINGUISHED = 0.
   REAL :: HRRPUA            = 0.
   REAL :: SMOKE_TFRAC       = 0.
   REAL :: QDOT_AVG          = 0.
   
! UCB parameters
   REAL    :: RAD_DIST           = 100.
   INTEGER :: IBLDGFM            = 1
   INTEGER :: SIGN_X             = 1
   INTEGER :: SIGN_Y             = 1
   REAL    :: WIND_PROP          = 1.
   REAL    :: HEAT_VALUE         = 0.
   REAL    :: HRR_TRANSIENT      = 0.
   REAL    :: ABSOLUTE_U         = 0.
   REAL    :: TOTAL_DFC_RECEIVED = 0.
   REAL    :: TOTAL_RAD_RECEIVED = 0.

! UMD spotting parameters
   REAL    :: T_START_SPOTTING = -1. 
   REAL    :: T_END_SPOTTING   = -1. 

END TYPE NODE
 
TYPE DLL
  TYPE(NODE), POINTER :: HEAD => NULL()
  TYPE(NODE), POINTER :: TAIL => NULL()
  INTEGER :: NUM_NODES = 0
  INTEGER :: NUM_NODES_PREVIOUS = 0
END TYPE DLL
TYPE(DLL), TARGET :: LIST_TAGGED, LIST_BURNED, LIST_SUPPRESSED

LOGICAL, ALLOCATABLE, DIMENSION(:) :: ALREADY_REACHED_BURNED_ACRES
LOGICAL :: PROCESS_TIMED_LOCATIONS
INTEGER :: NUM_TIMED_LOCATIONS

TYPE TIMED_LOCATIONS_TRACKER_TYPE
   INTEGER(8) :: ID
   REAL       :: X
   REAL       :: Y
   INTEGER    :: IX
   INTEGER    :: IY
END TYPE TIMED_LOCATIONS_TRACKER_TYPE
TYPE(TIMED_LOCATIONS_TRACKER_TYPE), ALLOCATABLE, DIMENSION (:) :: TIMED_LOCATIONS_TRACKER

! *****************************************************************************
END MODULE ELMFIRE_VARS
! *****************************************************************************
