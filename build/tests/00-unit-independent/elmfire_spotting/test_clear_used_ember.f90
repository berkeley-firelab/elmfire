!> test_clear_used_ember.f90
!> Unit test for subroutine CLEAR_USED_EMBER in elmfire_spotting.f90
!> Updated: 08-19-2025

! *****************************************************************************
PROGRAM TEST_CLEAR_USED_EMBER
! *****************************************************************************

USE ELMFIRE_VARS

IMPLICIT NONE

! Locals
INTEGER :: NFAIL = 0
INTEGER :: I
REAL    :: T

PRINT *, 'TESTING CLEAR_USED_EMBER...'

! Case 1: 




! Case 2: Clear All

! Test Cases
! CALL CHECK(<input1>, <expected1>)
! CALL CHECK(<input2>, <expected2>)

! Check outputs and print results
IF (NFAIL == 0) THEN
    PRINT *, 'PASS: ALL TESTS PASSED.'
ELSE
    PRINT *, 'FAIL: ', NFAIL, ' TEST(S) FAILED.'
    STOP 1
END IF

CONTAINS

! =============================================================================
SUBROUTINE CHECK(INPUT, EXPECTED)
! =============================================================================
REAL, INTENT(IN) :: INPUT, EXPECTED ! Inputs
REAL :: RESULT                      ! Locals
REAL, PARAMETER :: EPSILON = 1.0E-6

! RESULT = MYFUNC(INPUT)
! or
! CALL MYSUB(INPUT, ...)
IF (ABS(RESULT - EXPECTED) > EPSILON) THEN
    PRINT *, 'FAIL: INPUT=', INPUT, ' EXPECTED=', EXPECTED, ' GOT=', RESULT
    NFAIL = NFAIL + 1
END IF
! =============================================================================
END SUBROUTINE CHECK
! =============================================================================

! *****************************************************************************
END PROGRAM TEST_CLEAR_USED_EMBER
! *****************************************************************************