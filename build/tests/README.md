# Automated Testing Suite
Automated testing is a primary line of defense against bugs, regressions, and 
invalid model outputs [1]. In ELMFIRE, we organize tests into a 
**verification and validation taxonomy** that ensures both code correctness 
(*built it right*) and scientific fidelity (*built the right thing*).

## Testing Types
The suite is structured around several core test types [2]:

1. *Unit Tests* --
    Verify that individual subroutines or functions produce consistent outputs 
    in isolation.
2. *Component Tests* --
    Verify that groups of related subroutines or functions produce consistent 
    outputs together.
3. *Integration Tests* --
    Verify that the combination of all components in a simulation workflow 
    operates consistently and robustly.
4. *Regression Tests* --
    Ensure that updates, refactors, or optimizations do not inadvertently alter 
    model behavior.
5. *Performance Tests* --
    Evaluate whether the program executes within acceptable time, memory, and 
    resource usage constraints under different workloads.
6. *Validation Tests* --
    Ensure the physical reality of model outputs to some acceptable degree.
    Evaluations are based on observational datasets, field measurements, and/or
    published benchmarks. 

Further description of these types can be found in the reference [2].

---

## Notes on Verification vs. Validation
Work in progress...

---

## Directory Taxonomy
The testing suite follows the following top-down layout

```
tests/
├── 00-unit-independent/        # Unit verificaation tests without dependencies
│   ├── elmfire_init/           # Test scripts for elmfire_init.f90 units
│   ├── elmfire_level_set/      # Test scripts for elmfire_level_set.f90 units
│   ├── elmfire_spread_rate/    # Test scripts for elmfire_spread_rate.f90 units
│   └── ...
│
├── 01-unit-dependent/          # Unit verification tests with dependencies
│   ├── elmfire_level_set/      # Test scripts for elmfire_level_set.f90 dependent units
│   ├── elmfire_spread_rate/    # Test scripts for elmfire_spread_rate.f90 dependent units
│   └── ...
│
├── 02-component/               # Component verification tests
│   ├── wildfire_spread/        # Test run directories for wildfire spread cases
│   ├── spotting/               # Test run directories for spotting model cases
│   ├── urban_spread/           # Test run directories for urban spread model cases
│   ├── numerics/               # Test run directories for numerics functional cases
|   └── ...
│
├── 03-integration/             # Integration verification tests (end-to-end)
│   ├── forecasts/              # Test run directories for forecast cases
│   ├── hindcasts/              # Test run directories for hindcast cases (e.g. Tubbs)
|   ├── potential/              # Test run directories for fire potential cases (mode 2)
|   ├── risk/                   # Test run directories for structure fire risk cases
│   └── ... 
│
├── 04-regression/              # Regression tests
│   └── ...                     # Work in progres...
│
├── 05-performance/             # Performance testing with profiler outputs & benchmarking
│   └── ...                     # Work in progres...
│
└── 06-validation/              # Validation testing based on published studies
    └── ...                     # Work in progres...
```

---

## Functional Testing
The purpose of functional testing is to confirm the program or its subsections 
produce consistent and appropriate outputs for fixed inputs. Some common types 
of black-box tests used are given below. 

### Nominal Cases
Tests under typical, well-behaved conditions. These confirm correctness for 
expected or default inputs. These should validate the base algorithmic logic.

### Edge and Boundary Cases
Tests that evaluate the behavior of algorithms near the edge of the domain, 
array indices, or logical thresholds. These should catch off-by-one indexing 
errors, incorrect handling of boundary conditions, int vs. real data types, and 
logic breakdowns near thresholds. 

### Clipping and Truncation Cases
Tests that verify the algorithms correctly handle geometric, logic, or physical 
constraints. These should ensure proper enforcement of domain limits and 
physical clippings. 

### Resolution and Offset Mismatch Cases
Tests designed to catch spatial or temporal alignment errors. These can occur 
due to resolution issues, origin offsets, etc.

### Discontinuity and Gradient Jump Cases
Tests for correct geometric behavior across sharp changes in fuel properties, 
slope, weather, etc. that affect fire spread rates. These should verify that 
the solver handles abrupt changes while minimizing numerical instability or 
iterpolation artifacts. 

### Trigger and Activation Logic Cases
Tests that verify correct handling of conditional or threshold-based control 
logic. These should ensure timed events (ignitions, suppression, spotting, 
crown fire) and tagging are activated only when appropriate. 

---

## Complete Test List

### 00-unit-independent
Tests that run in isolation from other routines. This is the lowest test level. 

**elmfire_init**
- `test_calc_wind_adjustment_factor_single`

**elmfire_level_set**
- `test_calc_cfl`: CFL time step calculation.
- `test_calc_normal_vectors`: Outward normal calculation.
- `test_half_superbee`: Flux limiter.
- `test_rk2_integrate`: 2nd order Runge-Kutta time integration.

**elmfire_spotting**
- `test_set_spotting_parameters`

**elmfire_spread_rate**
- `test_ellipse_ucb`: Urban spread ellipse calculation.
- `test_hamada`: Urban spread rate calculation. 

**elmfire_subs**
- `test_bilinear_interpolate`
- `test_erfinv`
- `test_get_bilinear_interpolate_coeffs`
- `test_hour_of_year_to_timestamp`
- `test_icol_fine_to_coarse`
- `test_icol_from_x`
- `test_irow_from_y`
- `test_locate`
- `test_map_fine_to_coarse`
- `test_sunrise_sunset_calcs`
- `test_ux_from_wswd`
- `test_uy_from_wswd`
- `test_wx_icol_from_analysis_ix`
- `test_wx_irow_from_analysis_iy`
- `test_x_from_icol`
- `test_y_from_irow`

---

## 01-unit-dependent
Routines with internal dependencies but still testable at the unit scale.

**elmfire_level_set**
- `test_tag_band`: Narrow band cell tagging.
- `test_limit_gradients`: Spatial gradient limiter. 

**elmfire_spread_rate**

---

## 02-component
Directory-based tests that stress one primary mechanism in a realistic setup.

**numerics**
- `single-ignition-nwns`: No wind, no slope with single ignition
- `elliptical-shape`: Flat terrain with wind
- `dual-ignition-nwns`: No wind, no slope with two ignitions
- `planar-front-fuel-jump`: Vertical fire line moving over fuel discontinuity
- `planar-front-spot-merging`: Vertical fire line merging with spot fire

- `point-ignition-near-boundary`: 
- `planar-front-diagonal`: 
- `

**spotting**

**urban_spread**

**wildfire_spread**

---

## Integration Testing
End-to-end workflows for real applications. This includes running forecasts, 
hindcasts, fire potential, and risk analyses. Work in progress...

**forecasts**

**hindcasts**

**potential**

**risk**

---

## Regression Testing
Frozen reference outputs or bug reproductions. Work in progress...

---

## Performance Testing
Work in progress...

---

## Validation Testing
End-to-end tests comparing to empirical and/or published data. Work in 
progress...

---

# References
[1] G. Wilson et al., “Best Practices for Scientific Computing,” PLoS Biol., 
vol. 12, no. 1, p. e1001745, Jan. 2014, doi: 10.1371/journal.pbio.1001745.

[2] U. Priya, “Types Of Automation Testing: Definition, Benefits And Best 
Practices,” Lambda Test. [Online]. 
Available: https://www.lambdatest.com/blog/types-of-automation-testing/

---

This branch is in active development. Tests, information, and outcomes are 
subject to change.

**Questions?** Blame [Adam Laird](mailto:adam.laird@berkeley.edu)