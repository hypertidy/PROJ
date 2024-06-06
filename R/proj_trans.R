#' Transform coordinates
#'
#' Transforms all coordinates in `x` using [wk::wk_handle()] and [proj_trans_create()].
#'
#' Values that are detected out of bounds by library PROJ are allowed, we return `Inf`
#' in this case, rather than the error "tolerance condition error".
#'
#' @name proj_trans
#' @inheritParams proj_trans_create
#' @param x Input geometry/geography. May take any of the following forms:
#' - A coordinate matrix containing 2, 3 or 4 columns.
#'   If named, expects column names "x", "y" and optionally "z" and/or "m". If
#'   not named, columns are assumed in xyzm order. Non-coordinate columns are
#'   removed.
#' - A data.frame containing coordinates as columns. Expects names "x", "y" and
#'   optionally "z" and/or "m". Non-coordinate columns are retained.
#' - A data.frame containing a geometry vector which is readable by
#'   [wk::wk_handle()], including `sfc` columns.
#' - A geometry vector which is readable by [wk::wk_handle()], including `sfc`
#'   columns.
#'
#' @param ... Additional parameters forwarded to [wk::wk_handle()]
#' @return Transformed geometries whose format is dependent on input.
#'
#' @references see the [PROJ library documentation](https://proj.org/development/reference/functions.html#coordinate-transformation)
#' for details on the underlying functionality
#'
#' @examples
#' proj_trans(cbind(147, -42), "+proj=laea +type=crs", "EPSG:4326")
#' proj_trans(cbind(147, -42, -2), "+proj=laea +type=crs", "EPSG:4326")
#' proj_trans(cbind(147, -42, -2, 1), "+proj=laea +type=crs", "EPSG:4326")
#' proj_trans(wk::xy(147, -42, crs = "EPSG:4326"), "+proj=laea +type=crs")
#' proj_trans(wk::wkt("POLYGON ((1 1, 0 1, 0 0, 1 0, 1 1))", crs = "EPSG:4326"), 3112)
#'
#' @export
proj_trans <- function(x, target_crs, source_crs = NULL, ..., use_z = NA, use_m = NA) {
  UseMethod("proj_trans")
}

proj_trans_handleable <- function(x, target_crs, source_crs = NULL, ..., use_z = NA, use_m = NA) {
  source_crs <- source_crs %||% wk::wk_crs(x) %||% wk::wk_crs_longlat()
  trans <- proj_trans_create(source_crs, target_crs, use_z = use_z, use_m = use_m)

  wk::wk_set_crs(wk::wk_transform(x, trans, ...), target_crs)
}

#' @export
proj_trans.wk_vctr <- proj_trans_handleable

#' @export
proj_trans.wk_rcrd <- proj_trans_handleable

#' @export
proj_trans.sfc <- proj_trans_handleable

#' @export
proj_trans.matrix <- function(x, target_crs, source_crs = NULL, ..., use_z = NA, use_m = NA) {
  if (!is.numeric(x)) stop("`x` coordinates must be a numeric matrix")

  x_trans <- proj_trans_handleable(
    wk::as_xy(x),
    target_crs, source_crs,
    ..., use_z = use_z, use_m = use_m
  )

  as.matrix(x_trans)
}

#' @export
proj_trans.data.frame <- function(x, target_crs, source_crs = NULL, ..., use_z = NA, use_m = NA) {
  if (!wk::is_handleable(x)) {
    x_trans <- as.data.frame(
      proj_trans_handleable(
        wk::as_xy(x),
        target_crs, source_crs,
        ..., use_z = use_z, use_m = use_m
      )
    )

    nms <- names(x)
    xyzm <- c("x", "y", "z", "m")
    dims <- names(x_trans)

    x_res <- cbind(x[, setdiff(nms, xyzm), drop = FALSE], x_trans)

    # reset column order
    out_nms <- union(setdiff(nms, setdiff(xyzm, dims)), dims)
    return(x_res[, out_nms, drop = FALSE])
  }

  proj_trans_handleable(
    x,
    target_crs, source_crs,
    ..., use_z = use_z, use_m = use_m
  )
}
