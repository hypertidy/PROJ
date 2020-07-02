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
#' if (ok_proj6()) {
#'  proj_trans_generic(cbind(147, -42), "+proj=laea", source = "epsg:4326")
#'  proj_trans_generic(cbind(147, -42), z_ = -2, "+proj=laea", source = "epsg:4326")
#'  proj_trans_generic(cbind(147, -42), z_ = -2, t_ = 1, "+proj=laea", source = "epsg:4326")
#'  }
proj_trans_generic <- function(x, target, ..., source = NULL, z_ = 0, t_ = 0) {
#  if (!ok_proj6()) {
  if (!getOption("PROJ.HAVE_PROJ6")){
    stop("'proj_trans_generic()' is not functional on this system")

  }
  if (missing(target) | !is.character(target)) stop("target must be a string")
  if (is.null(source) | !is.character(source)) stop("source must be provided as a string")
  if (is.list(x) && !is.data.frame(x)) x <- as.data.frame(x[1:2])
  if (dim(x)[2L] != 2L) stop("x coordinates must be 2-columns")
  if (is.data.frame(x)) x <- as.matrix(x)
  n <- dim(x)[1L]
  if (!is.numeric(x)) stop("input coordinates must be numeric")
  if (n < 1) stop("must be at least one coordinate")
  y <- x[,2L, drop = TRUE]
  x <- x[,1L, drop = TRUE]
  z_ <- rep(z_,  length.out = length(x))
  t_ <- rep(t_,  length.out = length(x))

  lx <- length(x)

  if (!(lx > 0 && length(z_) == lx && length(t_) == lx && is.numeric(z_) && is.numeric(t_) )) {
    stop("x, z_, t_ must be numeric and compatible lengths")
  }
  result <- .Call("PROJ_proj_trans_list", x = list(as.numeric(x), as.numeric(y), as.numeric(z_), as.numeric(t_)), src_ = source, tgt_ = target, PACKAGE = "PROJ")
  if (is.null(result)) stop("problem in PROJ transformation")
  names(result) <- c("x_", "y_", "z_", "t_")
  result
}
#' @name proj_trans_generic
#' @export
proj_trans <- function(x, target, ..., source = NULL, z_ = NULL, t_ = NULL) {
  if (!getOption("PROJ.HAVE_PROJ6")){
    stop("'proj_trans()' is not functional on this system")

  }
  if (missing(target) | !is.character(target)) stop("target must be a string")
  if (is.null(source) | !is.character(source)) stop("source must be provided as a string")
  if (is.list(x) || is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (!is.null(z_) && is.null(t_)) t_ <- 0
  if (is.null(z_) && !is.null(t_)) z_ <- 0
  x <- cbind(x, z_, t_)
  nc <- dim(x)[2L]

  if (!nc %in% c(2, 4)) stop("x coordinates must be 2-column, with z_ and or t_ provide separately")
  n <- dim(x)[1L]
  if (!is.numeric(x)) stop("input coordinates must be numeric")
  if (n < 1) stop("must be at least one coordinate")
  xx <- split(x, rep(seq_len(nc), each = n))
  xx <- lapply(xx, as.numeric)  ## no integer
  if (nc == 2L) {
    out <- .Call("PROJ_proj_trans_xy", x_ = xx[[1L]], y_ = xx[[2L]], src_ = source, tgt_ = target, PACKAGE = "PROJ")
  }
  if (nc == 4L) {
    out <- .Call("PROJ_proj_trans_list", x = xx, src_ = source, tgt_ = target, PACKAGE = "PROJ")
  }

  if (is.null(out)) stop("problem in PROJ transformation")
  names(out) <- if (nc == 2L) c("x_", "y_") else c("x_", "y_", "z_", "t_")
  out
}

