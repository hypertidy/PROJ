# PROJ 0.1.5

* System requirements and logic for functionality are explained better than the 
 last release. 
* Patch release to fix errors on CRAN.  

I had not included sufficient capability checks, and I've used a more generic
initialization string in the CRAN-failing test.

I hope this will fix it. 


These had error: 

* r-patched-linux-x86_64
* r-release-linux-x86_64
* r-devel-linux-x86_64-debian-clang	0.1.0
* r-devel-linux-x86_64-debian-gcc

```
     proj_create_operations: source_crs is not a CRS
     -- 1. Error: PROJ works (@test-PROJ.R#11) -------------------------------------
     generic error of unknown origin
     Backtrace:
     1. testthat::expect_silent(...)
     9. PROJ::proj_trans_generic(...)
    
     proj_create: unrecognized format / unknown name
     proj_create: unrecognized format / unknown name
```
 
Thank you. 


## Test environments

* local R installation, R 3.6.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

There are no reverse dependencies. 
