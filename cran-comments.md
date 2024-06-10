# PROJ 0.5.0

This will be closely followed by an update to reproj. There are some complications in downstream tests 
in mapscanner but I will work with Mark to update asap. 


## Test environments

* local ubuntu
* win-builder (devel and release)
* macbuilder

## R CMD check results

0 errors | 0 warnings | 1 note

* There is a note about the size of the PROJ system libs. 


## Reverse dependenices

* reproj passes check with this version
* mapscanner has a failing test once reproj is updated in line with this version, but the maintainer has been notified and 
 I will work with them to fix

