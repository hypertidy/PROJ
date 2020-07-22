# PROJ 0.2.0

Please configure on CRAN to use the following options for MacOS, this has been tested against the proj-6.3.1 binaries
used by CRAN. 

```
./configure --with-data-copy=yes --with-proj-data=/usr/local/share/proj
```

and fix some CRAN issues. 

* Set minimum PROJ version at 6.1.0. 
* now uses .Call() rather than .C() 

Thank you. 


## Test environments

* local R installation, R 4.0.2
* win-builder (devel and release)
* MacOS CRAN binaries on Github actions

## R CMD check results

0 errors | 0 warnings | 0 notes

The reverse dependencies pass check. 
