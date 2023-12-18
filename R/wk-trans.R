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
#' wk::wk_transform(wk::xy(1:5, 1:5), proj_create("OGC:CRS84", "EPSG:3857"))
#'
#' @export
proj_create <- function(source_crs, target_crs, use_z = NA, use_m = NA) {
  stopifnot(is_scalar_logical(use_z))
  stopifnot(is_scalar_logical(use_m))

  trans <- .Call(
    C_proj_trans_new,
    wk::wk_crs_proj_definition(source_crs),
    wk::wk_crs_proj_definition(target_crs),
    use_z,
    use_m
  )

  wk::new_wk_trans(trans, "proj_trans")
}

#' @export
print.proj_trans <- function(x, ...) {
  cat(.Call(C_proj_trans_fmt, x))
  invisible(x)
}
