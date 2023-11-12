## 2022-10-30  up/down stuff cribbed from vapour cribbed from sf
.PROJ_cache <- new.env(FALSE, parent=globalenv())


.onLoad = function(libname, pkgname) {
  PROJ_load_proj()
}

.onUnload = function(libname, pkgname) {
  PROJ_unload_proj()
}

.onAttach = function(libname, pkgname) {

}

PROJ_load_proj <- function() {
  ## data only on
  ## - windows because tools/winlibs.R
  ## - macos because   CRAN mac binary libs, and configure --with-data-copy=yes --with-proj-data=/usr/local/share/proj

  if (!ok_proj6())  packageStartupMessage("no PROJ lib available, {PROJ} requires PROJ lib 6.3.1 or later")
  ##PROJ  data, only if the files are in package (will fix in gdalheaders)
  if (file.exists(system.file("proj/nad.lst", package = "PROJ"))) {
    prj = system.file("proj", package = "PROJ")[1L]
    assign(".PROJ.PROJ_LIB", Sys.getenv("PROJ_LIB"), envir=.PROJ_cache)
    Sys.setenv("PROJ_LIB" = prj)
  }

}
# todo
PROJ_unload_proj <- function() {

  if (file.exists(system.file("proj/alaska", package = "PROJ")[1L])) {
    Sys.setenv("PROJ_LIB"=get(".PROJ.PROJ_LIB", envir=.PROJ_cache))
  }
}
