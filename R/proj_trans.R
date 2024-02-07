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
#' @param source projection of input coordinates (must be named i.e. 'source = "<some proj string"' can't be used in positional form)
#' @param target projection for output coordinates
#' @param x input coordinates (x,y, list or matrix see `z_` and `t_`)
#' @param ... ignored
#' @param z_ optional z coordinate vector
#' @param t_ optional t coordinate vector
#' @export
#' @return list of transformed coordinates, with 4- or 2-elements `x_`, `y_`, `z_`, `t_`
#' @references see the [PROJ library documentation](https://proj.org/development/reference/functions.html#coordinate-transformation)
#' for details on the underlying functionality
#' @examples
#' proj_trans(cbind(147, -42), "+proj=laea +type=crs", source = "OGC:CRS84")
#' proj_trans(cbind(147, -42), z_ = -2, "+proj=laea +type=crs", source = "OGC:CRS84")
#' proj_trans(cbind(147, -42), z_ = -2, t_ = 1, "+proj=laea +type=crs", source = "OGC:CRS84")
#' @name proj_trans
#' @export
proj_trans <- function(x, target, ..., source = NULL, z_ = NULL, t_ = NULL) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (missing(target) || !is.character(target)) stop("target must be a string")
  if (is.null(source) || !is.character(source)) stop("source must be provided as a string")
  if (grepl("+proj", target) && !grepl("type=crs", target)) message("PROJ strings must have '+type=crs' to represent a crs correctly")
  if (grepl("+proj", target) && !grepl("type=crs", target)) message("PROJ strings must have '+type=crs' to represent a crs correctly")
  if (is.null(z_) && is.null(t_)) {
    wkx <- wk::xy(x[,1L, drop = TRUE], x[,2L, drop = TRUE], crs = source)
    trans <- proj_trans_create(source, target)
    names_in <- c("x", "y")
    names_out <- c("x_", "y_")
  }
  if (!is.null(z_) && is.null(t_)) {
    wkx <- wk::xyz(x[,1L, drop = TRUE], x[,2L, drop = TRUE], z_, crs = source)
    trans <- proj_trans_create(source, target, use_z = TRUE)
    names_in <- c("x", "y", "z")
    names_out <- c("x_", "y_", "z_")

  }
  if (is.null(z_) && !is.null(t_)) {
    wkx <- wk::xym(x[,1L, drop = TRUE], x[,2L, drop = TRUE], t_, crs = source)
    trans <- proj_trans_create(source, target, use_m = TRUE)
    names_in <- c("x", "y", "m")
    names_out <- c("x_", "y_", "t_")

  }
  if (!is.null(z_) && !is.null(t_)) {
    wkx <- wk::xyzm(x[,1L, drop = TRUE], x[,2L, drop = TRUE], z_, t_, crs = source)
    trans <- proj_trans_create(source, target, use_z = TRUE, use_m = TRUE)
    names_in <- c("x", "y", "z", "m")
    names_out <- c("x_", "y_", "z_", "t_")

  }

  out <- wk::wk_coords(wk::wk_transform(wkx, trans))[, names_in, drop = FALSE]
  setNames(as.list(out), names_out)
}

