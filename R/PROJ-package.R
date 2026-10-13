#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @importFrom lifecycle deprecated
#' @useDynLib PROJ, .registration = TRUE
## usethis namespace: end
NULL



#' Generic Coordinate System Transformations Using 'PROJ'
#'
#' The goal of PROJ is to provide generic coordinate system transformations in R
#' without requiring bespoke formats for storing basic data.
#' @section Using a non-default libproj:
#' When installing from source, set `PKG_LIBS` and `PKG_CPPFLAGS` to point to
#' the custom PROJ library and headers. For example, on Linux:
#'
#' ```sh
#' export PKG_LIBS="-L/home/user/lib -lproj"
#' export PKG_CPPFLAGS="-I/home/user/include"
#' export LD_LIBRARY_PATH="/home/user/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
#' remotes::install_github("hypertidy/PROJ")
#' ```
#'
#' The linked PROJ library must be version 8.2.0 or later.
#' @section I. Functions:
#' \tabular{ll}{
#'   \code{\link{ok_proj6}} determine if PROJ version >=6 is available
#'   \code{\link{proj_trans}} a light wrapper around the underlying transformation functionality of PROJ version 6 (or higher)
#'  \code{\link{proj_crs_text}} generate PROJ crs strings from input
#'  \code{\link{proj_version}} report the linked PROJ library version
#'  }
#' @name PROJ-package
NULL



#' xymap data for testing
#'
#' A copy of the xymap data set from the quadmesh package.
#'
#' A matrix of longitude/latitude values of the world coastline.
#' @docType data
#' @name xymap
NULL
