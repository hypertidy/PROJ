.set_proj_data <- function(proj_data){
     l <- try( .Call(PROJ_set_data_dir, proj_data));
     if (!inherits(l, "try-error")) {
       return(TRUE)
     } else {
       return(FALSE)
     }
}

.onLoad <- function(libname, pkgname) {
  ok <- .set_proj_data(system.file("proj", package = "PROJ", mustWork = TRUE))
  if (ok) options(PROJ.HAVE_PROJ6 = ok)
  invisible(NULL)
}
