# PROJ 0.0.0.9001

* R function `proj_trans()` gains a `verbose` argument to control output of warnings about missing
 values. 
* New C functions `R_proj_trans_FWD()` and `R_proj_trans_INV()` using the base R API. Interface is matrix in, matrix out always with three columns out as per reproj.  

* First working code with Rcpp function `proj_trans_cpp()`. 
