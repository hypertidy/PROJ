#' Create PROJ transformation object
#'
#' Creates a PROJ CRS to CRS transformation object, to be used in [wk::wk_transform()].
#'
#' @name proj_create
#' @inheritParams wk::wk_trans_set
#' @param source_crs,target_crs Source/Target CRS definition, coerced with [wk::wk_crs_proj_definition()]
#' @return A PROJ transformation object
#'
#' @export
proj_create <- function(source_crs, target_crs, use_z = NA, use_m = NA) {
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
