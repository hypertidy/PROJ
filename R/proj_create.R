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
#' '0: PJ_WKT2_2018', '1: PJ_PROJ_5'.
#'
#' A third option '2: PROJJSON' is not available, requiring 'PROJ 6.2.0' or above.
#'
#' Some formats are hard to read, such as WKT so for easy reading
#' use `cat()`.
#' @param format integer, 0 for 'WKT', 1 for 'PROJ'
#' @param source input projection specification one of ('PROJ4', 'WKT2',
#'  'EPSG', 'PROJJSON', ... see the library documentation link in Details)
#'
#' @return character string in requested format
#' @export
#'
#' @examples
#' proj_create("EPSG:4326", format = 1)
#'
#' proj_create("urn:ogc:def:crs:EPSG::4326")
#'
#' proj_create("urn:ogc:def:crs:EPSG::4326", format = 1L)
#'
#' cat(wkt <- proj_create("EPSG:3857"))
#'
#' proj_create(wkt, format = 1L)
#'
#' wkt_method <- proj_create("+proj=etmerc +lat_0=38 +lon_0=125 +ellps=bessel")
#'
#' cat(wkt_method)
#'
#' proj_create(wkt_method, format = 1L)
#' s1 <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0"
#' s2 <- "+y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs"
#' cat(proj_create(paste(s1, s2)))
proj_create <- function(source, format = 0L) {
  if (!ok_proj6()) {
    warning("'proj_create()' is not functional on this system")
    return(NA_character_)
  }
  stopifnot(length(format) == 1L)
  stopifnot(format %in% c(0L, 1L))
  stopifnot(is.character(source))
  stopifnot(length(source) == 1L)
  .Call("PROJ_proj_create",
        crs_ = source,
        format = as.integer(format),
        PACKAGE = "PROJ")
}
