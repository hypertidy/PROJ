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
