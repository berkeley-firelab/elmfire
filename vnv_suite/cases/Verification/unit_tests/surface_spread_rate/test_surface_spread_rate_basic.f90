PROGRAM TEST_SURFACE_SPREAD_RATE_BASIC

USE ELMFIRE_VARS
USE ELMFIRE_SPREAD_RATE

IMPLICIT NONE

TYPE(NODE), POINTER :: C
TYPE(DLL) :: L
INTEGER :: NFAIL = 0
REAL, PARAMETER :: EPS = 1.0E-6

PRINT *, "TESTING SURFACE_SPREAD_RATE (basic functionality)"

! -------------------------------
! Minimal global setup
! -------------------------------

USE_BLDG_SPREAD_MODEL = .FALSE.
ENABLE_EXTENDED_ATTACK = .FALSE.
DIURNAL_ADJUSTMENT_FACTOR = 1.0

! Allocate required rasters minimally
ALLOCATE(ISNONBURNABLE(10,10))
ISNONBURNABLE = .FALSE.

ALLOCATE(ADJ%R4(10,10,1))
ALLOCATE(SLP%R4(10,10,1))
ALLOCATE(FBFM%I2(10,10,1))

ADJ%R4 = 1.0
SLP%R4 = 0.0
FBFM%I2 = 101   ! Example surface fuel model

! -------------------------------
! Create node
! -------------------------------

ALLOCATE(C)
C%IX = 5
C%IY = 5
C%IFBFM = 101
C%M1 = 0.05
C%M10 = 0.07
C%M100 = 0.09
C%MLH = 0.7
C%MLW = 0.9
C%WSMF = 0.0
C%WS20_NOW = 0.0
C%TANSLP2 = 0.0
C%ADJ = 1.0

! -------------------------------
! Run with zero wind
! -------------------------------

CALL SURFACE_SPREAD_RATE(L, C)
PRINT *, "VS0 =", C%VS0
PRINT *, "IR  =", C%IR

IF (C%PHIW_SURFACE > EPS) THEN
  PRINT *, "FAIL: PHIW_SURFACE nonzero at zero wind"
  NFAIL = NFAIL + 1
ENDIF

IF (C%VELOCITY_DMS_SURFACE <= 0.0) THEN
  PRINT *, "FAIL: Non-positive surface velocity"
  NFAIL = NFAIL + 1
ENDIF

! -------------------------------
! Increase wind and rerun
! -------------------------------

C%WSMF = 5.0
C%WS20_NOW = 10.0

CALL SURFACE_SPREAD_RATE(L, C)

IF (C%VELOCITY_DMS_SURFACE <= 0.0) THEN
  PRINT *, "FAIL: Velocity not positive with wind"
  NFAIL = NFAIL + 1
ENDIF

! -------------------------------
! Report
! -------------------------------

IF (NFAIL == 0) THEN
  PRINT *, "PASS: SURFACE_SPREAD_RATE basic tests"
ELSE
  PRINT *, "FAIL:", NFAIL, "tests failed"
  STOP 1
ENDIF

END PROGRAM TEST_SURFACE_SPREAD_RATE_BASIC

