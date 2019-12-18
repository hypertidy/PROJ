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
