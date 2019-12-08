.set_proj_data <- function(proj_data){
      .Call(PROJ_set_data_dir, proj_data);
}

.onLoad <- function(libname, pkgname) {
  ok <- ok_proj6()
  options(PROJ.HAVE_PROJ6 = ok)
  if (ok) {
    .set_proj_data(system.file("proj", package = "PROJ", mustWork = TRUE))
  }
  invisible(NULL)
}
