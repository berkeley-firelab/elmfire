!> test_ember_ignition.f90
!> Unit test for subroutine EMBER_IGNITION in elmfire_spotting.f90
!> Updated: 08-19-2025

! *****************************************************************************
PROGRAM TEST_EMBER_IGNITION
! *****************************************************************************

USE ELMFIRE_VARS
USE ELMFIRE_LEVEL_SET

IMPLICIT NONE

! Locals
INTEGER :: NFAIL=0
INTEGER, PARAMETER :: NX=2, NY=2, NT=4
INTEGER :: IX, IY

PRINT *, 'TESTING EMBER_IGNITION...'

! Setup grid and tables
ANALYSIS_CELLSIZE = 1.0
EMBER_FLUX_TABLE_LEN = NT
DT_DUMP_EMBER_FLUX   = 10.0

USE_SIMPLE_IGNITION_MODEL = .TRUE.

! Allocate fields
ALLOCATE(EMBER_FLUX%R4(NX,NY,NT))
ALLOCATE(LOCAL_IGNITION(NX,NY))
ALLOCATE(T_LOCAL_IGNITION(NX,NY))

! Initialize arrays
EMBER_FLUX%R4(:,:,:) = 0.0
LOCAL_IGNITION(:,:)  = .FALSE.
T_LOCAL_IGNITION(:,:)= -1.0

IX=1; IY=1

! Case 1: Ignition, No Development --------------------------------------------
CALL CHECK( IX, IY, &
            T_ELMFIRE=12.0, DT_ELMFIRE=1.0, UWIND=5.0, &
            P_IGN_INPUT=100.0, TAU_IGN_INPUT=10.0, T_DEVELOP_INPUT=60.0, &
            HARDENING_FACTOR=1.0, &
            EXPECTED=.FALSE., LABEL='Ignition, No Development' )

! Case 2: Develop Ignition ----------------------------------------------------
! We keep LOCAL_IGNITION(1,1)=.TRUE. from Case 1 and advance time so that
! (T+DT - T_LOCAL_IGNITION) >= T_DEVELOP_INPUT
! CALL CHECK( ix, iy, &
!             T_ELMFIRE=80.0, DT_ELMFIRE=1.0, UWIND=0.0, &
!             P_IGN_INPUT=0.0, TAU_IGN_INPUT=10.0, T_DEVELOP_INPUT=60.0, &
!             HARDENING_FACTOR=1.0, &
!             EXPECTED=.TRUE., LABEL='Developed spot fire' )

! Case 3: No Embers, No Ignition ----------------------------------------------
LOCAL_IGNITION(:,:)  = .FALSE.
T_LOCAL_IGNITION(:,:)= -1.0
EMBER_FLUX%R4(:,:,:) = 0.0
CALL CHECK( ix, iy, &
            T_ELMFIRE=12.0, DT_ELMFIRE=1.0, UWIND=5.0, &
            P_IGN_INPUT=100.0, TAU_IGN_INPUT=10.0, T_DEVELOP_INPUT=30.0, &
            HARDENING_FACTOR=1.0, &
            EXPECTED=.FALSE., LABEL='No embers, no ignition' )

! Case 4: Not Ignitable -------------------------------------------------------
EMBER_FLUX%R4(ix,iy,1) = 25.0
EMBER_FLUX%R4(ix,iy,2) = 25.0
CALL CHECK( ix, iy, &
            T_ELMFIRE=12.0, DT_ELMFIRE=1.0, UWIND=5.0, &
            P_IGN_INPUT=0.0, TAU_IGN_INPUT=10.0, T_DEVELOP_INPUT=30.0, &
            HARDENING_FACTOR=1.0, &
            EXPECTED=.FALSE., LABEL='Zero P_IGN blocks ignition' )

! Check outputs and print results
IF (NFAIL == 0) THEN
    PRINT *, 'PASS: ALL TESTS PASSED.'
ELSE
    PRINT *, 'FAIL: ', NFAIL, ' TEST(S) FAILED.'
    STOP 1
END IF

CONTAINS

! =============================================================================
SUBROUTINE CHECK(IX,IY,T_ELMFIRE,DT_ELMFIRE,UWIND, &
                 P_IGN_INPUT,TAU_IGN_INPUT,T_DEVELOP_INPUT,HARDENING_FACTOR, &
                 EXPECTED,LABEL)
! =============================================================================
INTEGER, INTENT(IN) :: IX, IY
REAL   , INTENT(IN) :: T_ELMFIRE, DT_ELMFIRE, UWIND
REAL   , INTENT(IN) :: P_IGN_INPUT, TAU_IGN_INPUT, T_DEVELOP_INPUT, HARDENING_FACTOR
LOGICAL, INTENT(IN) :: EXPECTED
CHARACTER(*), INTENT(IN) :: LABEL

LOGICAL :: GOT
REAL, PARAMETER :: EPS_T = 1.0E-6
REAL :: t_before

! Track side effects for debugging if needed
t_before = T_LOCAL_IGNITION(IX,IY)

GOT = EMBER_IGNITION(IX,IY, T_ELMFIRE, DT_ELMFIRE, UWIND, &
                      P_IGN_INPUT, TAU_IGN_INPUT, T_DEVELOP_INPUT, HARDENING_FACTOR)

IF (GOT .NEQV. EXPECTED) THEN
    PRINT *, 'FAIL: ', TRIM(LABEL), ' EXPECTED=', EXPECTED, ' GOT=', GOT, &
             ' LOCAL_IGN=', LOCAL_IGNITION(IX,IY), ' T_LOC_IGN(before,after)=', &
             t_before, T_LOCAL_IGNITION(IX,IY)
    NFAIL = NFAIL + 1
ELSE
    PRINT *, 'PASS: ', TRIM(LABEL)
END IF
! =============================================================================
END SUBROUTINE CHECK
! =============================================================================

! *****************************************************************************
END PROGRAM TEST_EMBER_IGNITION
! *****************************************************************************