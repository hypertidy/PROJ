.set_proj_data_on_windows <- function(proj_data){
  ## return logical vector of length two
  ok <- FALSE
  if (.Platform[["OS.type"]] == "windows") {
     l <- .Call("PROJ_set_data_dir", proj_data)
     ok <- TRUE; ## !inherits(l, "try-error")
  }
  c(windows = .Platform[["OS.type"]] == "windows",
    ok = ok)
}

.onLoad <- function(libname, pkgname) {
  windows_ok <- .set_proj_data_on_windows(system.file("proj", package = "PROJ", mustWork = FALSE))
  if (windows_ok["windows"] && windows_ok["ok"]) options(PROJ.HAVE_PROJ6 = TRUE)
  if (!windows_ok["windows"]) {
    ok <- ok_proj6()
    if (ok) options(PROJ.HAVE_PROJ6 = ok)
  }
  invisible(NULL)
}
