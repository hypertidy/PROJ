# PROJ 0.1.6

* We now use the PROJ::proj_trans internally, and just loop over vectors. 
(so proj_trans_generic is a misnomer, technically). 

* Prevent error on out of bounds values from `proj_trans_generic()`. We get `Inf`. 

# PROJ 0.1.5

* Attempt to fix errors on CRAN, add missing test for functionality 
 with required lib-proj version and use more generic initialization string. 
 
* New function [proj_create()] to generate CRS formats from various input types. 

# PROJ 0.1.0

* Removed CPP variable from configure thanks to CRAN. 

* Sorted out .C registration. 

* Now set data directory for installed share files, thanks to Jeroen Ooms for the nudge in the right
 direction with the R API. 

* Cleaned up CI testing, so we get tested on versions 5, 6, and 7 of PROJ on travis. 

* Removed proj_trans(), only function is proj_trans_generic() more closely aligned to the
 API of PROJ itself (=> 6). 

* Included PROJ library tooling for Windows, thanks to Jeroen Ooms. 

# PROJ 0.0.1.9001

* Remove Rcpp. 

# PROJ 0.0.1

* R function `proj_trans()` gains a `quiet` argument to control output of warnings about missing
 values. 
 
* New C functions `R_proj_trans_FWD()` and `R_proj_trans_INV()` using the base R API. Interface is matrix in, matrix out always with three columns out as per reproj.  

* First working code with Rcpp function `proj_trans_cpp()`. 
