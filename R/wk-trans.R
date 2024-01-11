#' Create a transformation object
#'
#' Creates a transformation object that transforms coordinates in a {wk}
#' pipeline.
#'
#' @name proj_create
#' @inheritParams wk::wk_trans_set
#' @param source_crs,target_crs Source/Target CRS definition, coerced with [wk::wk_crs_proj_definition()]
#' @return A PROJ transformation object
#'
#' @examples
#' (trans <- proj_create("OGC:CRS84", "EPSG:3857"))
#' wk::wk_transform(wk::xy(1:5, 1:5), trans)
#'
#' library(wk)
#' (invtrans <- wk_trans_inverse(trans))
#'
#' h <- 1852 * 60
#' ## the stretch of Mercator to a square
#' wk::wk_transform(wk::xy(c(-h * 180, 0, h * 180), c(-h * 180,0, h * 180)), invtrans)
#'
#' @export
proj_create <- function(source_crs, target_crs, use_z = NA, use_m = NA) {
  source_crs <- wk::wk_crs_proj_definition(source_crs)
  target_crs <- wk::wk_crs_proj_definition(target_crs)

  if (is.na(source_crs) || nchar(source_crs) == 0) stop("`source_crs` is invalid")
  if (is.na(target_crs) || nchar(target_crs) == 0) stop("`target_crs` is invalid")

  stopifnot(is.logical(use_z) && is.logical(use_m))

  trans <- .Call(
    C_proj_trans_new,
    source_crs,
    target_crs,
    use_z[1],
    use_m[1]
  )

  wk::new_wk_trans(trans, "proj_trans")
}

#' @export
print.proj_trans <- function(x, ...) {
  cat(.Call(C_proj_trans_fmt, x))
  invisible(x)
}

#' @importFrom wk wk_trans_inverse
#' @export
wk_trans_inverse.proj_trans <- function(trans, ...) {
  trans_inv <- .Call(C_proj_trans_inverse, trans)
  wk::new_wk_trans(trans_inv, "proj_trans")
}
