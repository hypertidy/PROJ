.set_proj_data <- function(proj_data = ""){
     l <- try(.Call("PROJ_set_data_dir", proj_data), silent = TRUE)
     if (inherits(l, "try-error")) {
       ok <- FALSE
     } else {
       ok <- TRUE
     }
     ok
}

.onLoad <- function(libname, pkgname) {
  ok_data <- FALSE
  if (tolower(Sys.info()[["sysname"]]) %in%  c("windows", "darwin")) {
    path <- system.file("proj", package = "PROJ", mustWork = FALSE)
    if (nchar(path) > 0) {
      ok_data <- .set_proj_data(path)
    }
  } else {
    # if (nchar(projdata <- Sys.getenv("PROJ_LIB")) < 1) {
    #   Sys.setenv(PROJ_LIB = "/usr/share/proj")
    #   print(Sys.getenv("PROJ_LIB"))
    #
    # }
    ok_data <- TRUE
  }
  ok <- ok_proj6() && ok_data
  options(PROJ.HAVE_PROJ6 = ok)
  invisible(NULL)
}
