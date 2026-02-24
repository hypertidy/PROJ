#' Compute map projection factors for coordinates
#'
#' Computes map projection factors (distortion measures) for a set of
#' geographic coordinates and a given projected CRS. Returns a matrix with
#' one row per input coordinate and one column per factor.
#'
#' @param lp A two-column numeric matrix of geographic coordinates
#'   (longitude, latitude) in decimal degrees.
#' @param crs A PROJ CRS definition string for the target projection
#'   (e.g. a PROJ string, WKT, or authority code such as `"EPSG:3112"`).
#'
#' @return A numeric matrix with `nrow(lp)` rows and the following columns:
#' \describe{
#'   \item{meridional_scale}{Meridional scale factor (h)}
#'   \item{parallel_scale}{Parallel scale factor (k)}
#'   \item{areal_scale}{Areal scale factor (s)}
#'   \item{angular_distortion}{Angular distortion (omega), in radians}
#'   \item{meridian_parallel_angle}{Meridian-parallel angle (theta prime), in radians}
#'   \item{meridian_convergence}{Meridian convergence (conv), in radians}
#'   \item{tissot_semimajor}{Tissot semimajor axis (a)}
#'   \item{tissot_semiminor}{Tissot semiminor axis (b)}
#'   \item{dx_dlam}{Partial derivative dx/dlambda}
#'   \item{dx_dphi}{Partial derivative dx/dphi}
#'   \item{dy_dlam}{Partial derivative dy/dlambda}
#'   \item{dy_dphi}{Partial derivative dy/dphi}
#' }
#'
#' @references
#' [PROJ PJ_FACTORS documentation](https://proj.org/en/stable/development/reference/datatypes.html#c.PJ_FACTORS)
#'
#' @examples
#' # Lambert Azimuthal Equal Area
#' proj_factors(cbind(147, -42), "+proj=laea +lon_0=147 +lat_0=-42 +type=crs")
#'
#' # Multiple coordinates
#' pts <- cbind(c(130, 147, 160), c(-20, -42, -35))
#' proj_factors(pts, "EPSG:3112")
#'
#' @export
proj_factors <- function(lp, crs) {
  lp <- as.matrix(lp)
  if (!is.numeric(lp) || ncol(lp) < 2L) {
    stop("`lp` must be a numeric matrix with at least 2 columns (longitude, latitude)")
  }

  crs <- proj_add_type_crs_if_needed(wk::wk_crs_proj_definition(crs))
  if (is.na(crs) || nchar(crs) == 0L) stop("`crs` is invalid")

  .Call(C_proj_factors, crs, lp[, 1:2, drop = FALSE])
}
