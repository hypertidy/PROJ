.onLoad <- function(libname, pkgname) {

  # Load libproj namespace for access to C callables
  requireNamespace("libproj", quietly = TRUE)
  .Call("libproj_c_init", PACKAGE = "PROJ")
  invisible(NULL)
}
