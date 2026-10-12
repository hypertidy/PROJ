## 2022-10-30  up/down stuff cribbed from vapour cribbed from sf
## 2026-10     reworked: C API search paths, validate the bundled proj.db
.PROJ_cache <- new.env(FALSE, parent=globalenv())


.onLoad = function(libname, pkgname) {
  PROJ_load_proj()
}

.onUnload = function(libname, pkgname) {
  PROJ_unload_proj()
}

.onAttach = function(libname, pkgname) {
  msg <- get0(".PROJ.data_message", envir = .PROJ_cache, ifnotfound = NULL)
  if (!is.null(msg)) packageStartupMessage(msg)
}

PROJ_load_proj <- function() {
  ## a copy of the PROJ data directory is in the package only on
  ## - windows, copied from Rtools by src/Makevars.ucrt
  ## - macos, when CRAN builds with --with-data-copy=yes --with-proj-data=DIR
  ##   (or PROJ_GDAL_DATA_COPY set), see configure.ac
  ## - linux, only if a user opts in with the same configure args
  ## otherwise the PROJ library self-configures and knows where its data is
  prj <- system.file("proj", package = "PROJ")
  if (nzchar(prj) && file.exists(file.path(prj, "proj.db"))) {
    PROJ_use_bundled_data(prj)
  }
  invisible(NULL)
}

PROJ_use_bundled_data <- function(prj) {
  ## PROJ validates proj.db's DATABASE.LAYOUT.VERSION lazily, on first
  ## database access, so pointing at an incompatible copy (one taken from a
  ## different PROJ than the library we are linked to) succeeds silently and
  ## then every EPSG lookup fails with 'Unknown error (code 2)'. Set the
  ## path, force a lookup, back out if it fails.
  .Call("C_proj_set_search_paths", prj, PACKAGE = "PROJ")
  probe <- .Call("C_proj_probe_db", PACKAGE = "PROJ")
  if (isTRUE(probe$ok)) {
    assign(".PROJ.data_active", TRUE, envir = .PROJ_cache)
    return(invisible(TRUE))
  }
  .Call("C_proj_set_search_paths", character(), PACKAGE = "PROJ")
  assign(".PROJ.data_active", FALSE, envir = .PROJ_cache)
  why <- if (nzchar(probe$message)) probe$message else "database lookup failed"
  msg <- sprintf(paste0(
    "{PROJ}: the PROJ data bundled with this package is not usable with the ",
    "PROJ library in use (%s): %s\n",
    "Ignoring the bundled copy and using the PROJ library defaults instead. ",
    "If this package was installed with --with-data-copy, reinstall without it."),
    proj_version(), why)
  assign(".PROJ.data_message", msg, envir = .PROJ_cache)
  warning(msg, call. = FALSE)
  invisible(FALSE)
}

PROJ_unload_proj <- function() {
  if (isTRUE(get0(".PROJ.data_active", envir = .PROJ_cache, ifnotfound = FALSE))) {
    .Call("C_proj_set_search_paths", character(), PACKAGE = "PROJ")
  }
  invisible(NULL)
}

#' Report on the PROJ data directory in use
#'
#' Returns the path of the proj.db that the PROJ library resolves, its
#' metadata (the PROJ version that built it, database layout version, EPSG
#' version), whether the copy of PROJ data bundled with this package (if
#' any) is active, and the PROJ library version.
#'
#' If `path` is NA the library cannot find a usable proj.db: EPSG codes and
#' other database lookups will fail, though '+proj=' strings still work.
#'
#' @return a list with elements 'db' (named character), 'bundled_active' (logical), 'proj_version' (character)
#' @export
#' @examples
#' proj_data_info()
proj_data_info <- function() {
  list(db = .Call("C_proj_db_info", PACKAGE = "PROJ"),
       bundled_active = isTRUE(get0(".PROJ.data_active", envir = .PROJ_cache, ifnotfound = FALSE)),
       proj_version = proj_version())
}
