#' Transform a set of coordinates with 'PROJ'
#'
#' A raw interface to 'proj_trans' in 'PROJ => 6', if it is available.
#'
#' 'proj_trans_generic()' and 'proj_trans()' have the same arguments, but differ
#'  in the default values of `z_` and `t_`, `0` or `NULL`. 'proj_trans_generic()' always
#'  returns a list for 4 elements, 'proj_trans()' will return 2 or 4 depending on the input.
#'
#'  'proj_trans_generic()' is a misnomer in that 'proj_trans' is the function from the PROJ
#'  library that is now used.
#'
#' Input 'x' is assumed to be 2-columns of "x", then "y" coordinates. If "z" or
#' "t" is required pass these in as named vectors with "z_" and "t_". For simplifying reasons
#' `z_` and `t_` must always match the length of `x` `y`. Both default to 0, and are automatically
#' recycled to the number of rows in `x` so it's pretty flexible.
#'
#' Values that are detected out of bounds by library PROJ are allowed, we return `Inf` in this
#' case, rather than the error "tolerance condition error".
#'
#' @param source projection of input coordinates (must be named)
#' @param target projection for output coordinates
#' @param x input coordinates (x,y, list or matrix see `z_` and `t_`)
#' @param ... ignored
#' @param z_ optional z coordinate vector
#' @param t_ optional t coordinate vector
#' @export
#' @return list of transformed coordinates, with 4-elements `x_`, `y_`, `z_`, `t_`
#' @references see the [PROJ library documentation](https://proj.org/development/reference/functions.html#coordinate-transformation)
#' for details on the underlying functionality
#' @examples
#' # proj_trans(cbind(147, -42), "+proj=laea", source = "epsg:4326")
#'  #proj_trans(cbind(147, -42), z_ = -2, "+proj=laea", source = "epsg:4326")
#'  #proj_trans(cbind(147, -42), z_ = -2, t_ = 1, "+proj=laea", source = "epsg:4326")
#' @name proj_trans
#' @export
proj_trans <- function(x, target, ..., source = NULL, z_ = NULL, t_ = NULL) {

  if (missing(target) || !is.character(target)) stop("target must be a string")
  if (is.null(source) || !is.character(source)) stop("source must be provided as a string")
  if (is.list(x) || is.data.frame(x)) x <- cbind(x[[1L]], x[[2L]])

  if (!is.null(z_) || !is.null(t_)) {
    if (is.null(t_)) t_ <- 0
    if (is.null(z_)) z_ <- 0
    x <- cbind(x, z_, t_)
  }

  nd <- dim(x)

  if (!nd[2L] %in% c(2, 4)) stop("x coordinates must be 2-column, with z_ and t_ provided separately")

  if (!is.numeric(x)) stop("input coordinates must be numeric")
  if (nd[1L] < 1) stop("must be at least one coordinate")
  if (nd[2L] == 2L) {
    out <- .Call("proj_trans_xy", x_ = as.double(x[,1L]), y_ = as.double(x[,2L]), src_ = source, tgt_ = target, PACKAGE = "PROJ")
    names(out) <- c("x_", "y_")
  } else {
    xx <- split(x, rep(seq_len(nd[2L]), each = nd[1L]))
    xx <- lapply(xx, as.numeric)  ## no integer
    out <- .Call("proj_trans_list", x = xx, src_ = source, tgt_ = target, PACKAGE = "PROJ")
    names(out) <- c("x_", "y_", "z_", "t_")
  }


  out
}

#' @name proj_trans
#' @export
proj_trans_generic <- function(x, target, ..., source = NULL, z_ = 0, t_ = 0) {
 ## message("'proj_trans_generic()' is soft-deprecated and may be removed, please use 'proj_trans()'")
  proj_trans(x = x, target = target, ..., source = source, z_ = z_, t_ = t_)
}
