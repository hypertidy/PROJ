.set_proj_data <- function(proj_data = ""){
     l <- try(.Call("PROJ_proj_set_data_dir", proj_data), silent = TRUE)
     if (inherits(l, "try-error")) {
       ok <- FALSE
     } else {
       ok <- TRUE
     }
     ok
}

.onLoad <- function(libname, pkgname) {
  pkg_proj_lib <- FALSE
  if (tolower(Sys.info()[["sysname"]]) %in%  c("windows", "darwin")) {
    path <- system.file("proj", package = "PROJ", mustWork = FALSE)
    if (nchar(path) > 0) {
      pkg_proj_lib <- .set_proj_data(path)
    }
  } else {
   pkg_proj_lib <- TRUE
  }
  ok <- ok_proj6()
  options(PROJ.HAVE_PROJ6 = ok, PROJ.HAVE_PROJ_LIB_PKG = pkg_proj_lib)
  invisible(NULL)
}
