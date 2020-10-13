#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @useDynLib PROJ, .registration = TRUE
## usethis namespace: end
NULL

# @noRd
# @importFrom libproj libproj_version
# .libproj_version <- function() {
#   ## purely to pass check
#   libproj::libproj_version()
# }
#NULL


#' Generic Coordinate System Transformations Using 'PROJ'
#'
#' The goal of PROJ is to provide generic coordinate system transformations in R
#' without requiring bespoke formats for storing basic data.
#' @section I. Functions:
#' \tabular{ll}{
#'   \code{\link{ok_proj6}} determine if PROJ version >=6 is available
#'   \code{\link{proj_trans_generic}} a light wrapper around the underlying transformation functionality of PROJ version 6 (or higher)
#'  removed   proj_create convert projection strings to WKT2 or PROJ format
#'  }
#' @name PROJ-package
#' @docType package
NULL



#' xymap data for testing
#'
#' A copy of the xymap data set from the quadmesh package.
#'
#' A matrix of longitude/latitude values of the world coastline.
#' @docType data
#' @name xymap
NULL
