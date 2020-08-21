#' Generate a projection string.
#'
#' Input any accepted format of 'PROJ' coordinate reference system specification.
#' Return value is a string in the requested format.
#'
#' This function requires PROJ version 6.0 or higher to be useful. If not, this
#' function simply returns 'NA'.
#'
#' See the [library documentation](https://proj.org/development/reference/functions.html#transformation-setup)
#' for details on input and output formats.
#'
#' Some nuances of the format are not available, currently we use formats
#' '0: PJ_WKT2_2018'.
#'
#'  Options '1: PJ_PROJ_5', '2: PROJJSON' is not available, WIP.
#'
#' Some formats are hard to read, such as WKT so for easy reading
#' use `cat()`.
#' @noRd
#' @param format integer, 0 for 'WKT', 1 for 'PROJ'
#' @param source input projection specification one of ('PROJ4', 'WKT2',
#'  'EPSG', 'PROJJSON', ... see the library documentation link in Details)
#'
#' @return character string in requested format
#'
#' @examples
#' #proj_create("EPSG:4326", format = 0)
#' #cat(proj_create(paste(s1, s2)))
proj_create <- function(source, format = 0L) {
  stop("proj_create is disabled for now")

  stopifnot(length(format) == 1L)
  stopifnot(format %in% c(0L))
  stopifnot(is.character(source))
  stopifnot(length(source) == 1L)
  # .Call("proj_create_text",
  #       crs_ = source,
  #       format = as.integer(format),
  #       PACKAGE = "PROJ")
}
