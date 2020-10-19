.onLoad <- function(libname, pkgname) {

  # Load libproj namespace for access to C callables
  #requireNamespace("libproj", quietly = TRUE)
  #.Call("libproj_c_init", PACKAGE = "PROJ")

  invisible(NULL)
}

.onAttach <- function(libname, pkgname) {
  if (interactive()) packageStartupMessage("PROJ is currently non-operational since version 0.4.0")
  invisible(NULL)
}
