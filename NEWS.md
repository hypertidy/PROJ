# PROJ 0.5.0

* proj_trans() is no longer supported with list input, and returns matrix output. 

* PROJ >= 6 is now a hard dependency (#42)

* Deprecate ok_proj6() (#42)

* Add {wk} transformer api (#44, #46, #48, #50)

* Replace proj_trans() with S3 generic (#56)

# PROJ 0.4.5

* New function `proj_version()`.

* reinstated proj function!

* `ok_proj6()` is now meaningful again.

* Deprecated old `proj_trans_generic()`.

# PROJ 0.3.1

* New function 'proj_crs_text()' to convert from one CRS text format to another.

* No set up on load now, all handled by libproj. Package should always function,
always with version 7 or above.

* FIXME:  (should deprecate) Removed `ok_proj6()`

* Now importing libproj, to provide cross platform access to PROJ version 7 and above and for
 configuration of metadata files.

* Incorporated fixes and improvements from Dewey Dunnington.


# PROJ 0.2.0

* Now using Github Actions to test linux, windows, macos. Many thanks to James Balamuta for guidance on how to do this.

* The internal C functionality calling the PROJ library now uses .Call rather than .C. The .C function
 `PROJ_proj_trans_generic()` is now not used and will be removed.

* On load behaviour has changed, on Windows and MacOS a check is made for a local copy of the proj/
 PROJ data directory with metadata files. If this is present, the path to that folder is set using the
 underlying PROJ library function `proj_context_set_search_paths()`.

 This is only relevant to Windows and MacOS **static builds**, these are self-contained, the R package contains the
 PROJ library and everything it needs. Generally in other installations (brew on MacOS, apt install, or from source builds
 on Linux) the PROJ library self-configures and knows where to find this directory.

 This is automatic for source builds on Windows which download pre-built binaries and data from https://github.com/rwinlib, and
 so will be using a given PROJ version.

 On MacOS, this only occurs if configure options `--with-data-copy=yes` and `--with-proj-data=DIR` are used. This
 is done manually on CRAN by admins. The current version used can be found at https://mac.r-project.org/libs-4/.

* Need proj version 6.1.0 or above, and a configuration fix on MacOS for libsqlite thanks to Brian Ripley, and CRAN.

* Fixed bug not returning transformed z or t.

* Windows: update to proj 6.3.1

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
