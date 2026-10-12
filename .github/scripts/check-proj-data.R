## Cross-platform check of the bundled PROJ data handling (R/zzz.R).
##
## Usage: Rscript check-proj-data.R <expect>
##   expect = "bundled"   the installed package must be using its own inst/proj
##   expect = "system"    the installed package must be using the library defaults
##   expect = "fallback"  inst/proj exists but is unusable; the package must have
##                        reported it and fallen back to the library defaults
## In every case EPSG lookups must work afterwards.

expect <- commandArgs(TRUE)[1]
stopifnot(expect %in% c("bundled", "system", "fallback"))

suppressPackageStartupMessages(library(PROJ))

info <- PROJ::proj_data_info()
w <- info$message
prj  <- system.file("proj", package = "PROJ")
cat("PROJ library:   ", info$proj_version, "\n")
cat("inst/proj:      ", if (nzchar(prj)) prj else "(absent)", "\n")
cat("bundled_active: ", info$bundled_active, "\n")
cat("proj.db path:   ", info$db[["path"]], "\n")
cat("proj.db built by PROJ", info$db[["PROJ.VERSION"]], "layout",
    info$db[["DATABASE.LAYOUT.VERSION.MAJOR"]], ".", info$db[["DATABASE.LAYOUT.VERSION.MINOR"]], "\n")
if (length(w)) cat("startup message:\n ", w, "\n")

fail <- function(...) { cat("FAIL:", ..., "\n"); quit(status = 1) }

switch(expect,
  bundled = {
    if (!nzchar(prj)) fail("expected inst/proj to exist")
    if (!info$bundled_active) fail("expected bundled copy to be active")
    if (!startsWith(normalizePath(info$db[["path"]]), normalizePath(prj))) fail("proj.db not resolved from inst/proj")
    if (length(w)) fail("unexpected startup message")
  },
  system = {
    if (nzchar(prj)) fail("expected no inst/proj")
    if (info$bundled_active) fail("bundled copy should not be active")
    if (length(w)) fail("unexpected startup message")
  },
  fallback = {
    if (!nzchar(prj)) fail("expected inst/proj to exist")
    if (info$bundled_active) fail("unusable bundled copy was activated")
    if (!any(grepl("not usable", w))) fail("expected a startup message about the bundled copy")
    if (is.na(info$db[["path"]])) fail("no fallback proj.db found; library defaults unavailable on this runner")
  })

## the thing that actually matters to users
txt <- PROJ::proj_crs_text("EPSG:3112", 2L)
if (!grepl("Lambert", txt)) fail("EPSG lookup did not work")
f <- PROJ::proj_factors(cbind(147, -42), "EPSG:3112")
if (!is.finite(f[1, "meridional_scale"])) fail("proj_factors with EPSG CRS returned NaN")
cat("OK (", expect, ")\n")
