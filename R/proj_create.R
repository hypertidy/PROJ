#' Generate a projection string.
#'
#' Input any accepted format of PROJ crs specification. Return value is a string
#' in the requested format.
#'
#' See the [library documentation](https://proj.org/development/reference/functions.html#transformation-setup)
#' for details on input and output formats.
#'
#' Some nuances of the format are not available, currently we use formats
#' '0: PJ_WKT2_2018', '1: PJ_PROJ_5', '2: PROJJSON'.
#'
#' Some formats are hard to read, such as WKT or PROJJSON, for easy reading
#' use `cat()`.
#' @param format integer, 0 for WKT, 1 for PROJ, 2 for PROJJSON
#' @param source input projection specification (PROJ4, WKT2, PROJJSON, ...)
#'
#' @return character string in requested format
#' @export
#'
#' @examples
#' if (ok_proj6()) {
#' proj_create("EPSG:4326", format = 1)
#'
#' proj_create("urn:ogc:def:crs:EPSG::4326")
#'
#' proj_create("urn:ogc:def:crs:EPSG::4326", format = 2)
#'
#' cat(wkt <- proj_create("EPSG:3857"))
#' proj_create(wkt, format = 1L)
#'
#' wkt_method <- proj_create("+proj=etmerc +lat_0=38 +lon_0=125 +ellps=bessel")
#'
#' cat(wkt_method)
#' proj_create(wkt, format = 1L)
#' }
proj_create <- function(source, format = 0L) {
  stopifnot(length(format) == 1L)
  stopifnot(format %in% c(0L, 1L, 2L))
  stopifnot(is.character(source))
  stopifnot(length(source) == 1L)
  .Call("PROJ_proj_create",
        crs_ = source,
        format = as.integer(format),
        PACKAGE = "PROJ")
}
