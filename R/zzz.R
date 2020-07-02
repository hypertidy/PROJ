.set_proj_data_on_os <- function(proj_data){
  ## return logical vector of length two
  ok <- winmac <- FALSE
  if (tolower(Sys.info()[["sysname"]]) %in%  c("windows", "darwin")) {
     l <- .Call("PROJ_set_data_dir", proj_data)
     ok <- TRUE; ## !inherits(l, "try-error")
     winmac <- TRUE
  }
  c(windows_or_mac = winmac, ok = ok)
}

.onLoad <- function(libname, pkgname) {
  windows_ok <- .set_proj_data_on_os(system.file("proj", package = "PROJ", mustWork = FALSE))
  if (windows_ok["windows_or_mac"] && windows_ok["ok"]) options(PROJ.HAVE_PROJ6 = TRUE)
  if (!windows_ok["windows_or_mac"]) {
    ok <- ok_proj6()
    if (ok) options(PROJ.HAVE_PROJ6 = ok)
  }
  invisible(NULL)
}
