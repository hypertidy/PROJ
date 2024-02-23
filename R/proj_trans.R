#' Transform a set of coordinates with 'PROJ'
#'
#' A raw interface to 'proj_trans' in 'PROJ => 6', if it is available.
#'
#' Input 'x' is assumed to be 2-columns of "x", then "y" coordinates. If "z" or
#' "t" is required pass these in as named vectors with "z_" and "t_". For simplifying reasons
#' `z_` and `t_` must always match the length of `x` `y`. Both default to 0, and are automatically
#' recycled to the number of rows in `x`.
#'
#' Values that are detected out of bounds by library PROJ are allowed, we return `Inf` in this
#' case, rather than the error "tolerance condition error".
#'
#' @name proj_trans
#' @inheritParams proj_trans_create
#' @param x input coordinates (x,y, list or matrix see `z_` and `t_`)
#' @param ... Additional parameters forwarded to [wk::wk_handle()]
#' @return list of transformed coordinates, with 4- or 2-elements `x_`, `y_`, `z_`, `t_`
#' 
#' @references see the [PROJ library documentation](https://proj.org/development/reference/functions.html#coordinate-transformation)
#' for details on the underlying functionality
#' 
#' @examples
#' proj_trans(cbind(147, -42), "+proj=laea type=crs", "OGC:CRS84")
#' proj_trans(cbind(147, -42, -2), "+proj=laea type=crs", "OGC:CRS84")
#' proj_trans(cbind(147, -42, -2, 1), "+proj=laea type=crs", "OGC:CRS84")
#' proj_trans(wk::xy(147, -42, crs = "OGC:CRS84"), "+proj=laea type=crs")
#' proj_trans(wk::wkt("POLYGON ((1 1, 0 1, 0 0, 1 0, 1 1))", crs = "OGC:CRS84"), 3112)
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
    dims <- names(x_trans)
    
    x_res <- cbind(x[, setdiff(nms, dims), drop = FALSE], x_trans)
    # reset column order
    return(x_res[, union(nms, dims), drop = FALSE])
  }

  proj_trans_handleable(
    x, 
    target_crs, source_crs, 
    ..., use_z = use_z, use_m = use_m
  )
}
