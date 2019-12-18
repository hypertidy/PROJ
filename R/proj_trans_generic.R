#' Transform a set of coordinates with 'PROJ'
#'
#' A raw interface to proj_trans_generic in 'PROJ => 6', if it is available.
#'
#' Input 'x' is assumed to be 2-columns of "x", then "y" coordinates. If "z" or
#' "t" is required pass these in as named vectors with "z_" and "t_". These
#' are left empty (zero-length) internally by default, if possible but it seems that
#' z must always match the length of `x` `y` if 'xyz' is the output, so for safety this
#' is always initialized as a zero value vector.
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
proj_trans_generic <- function(x, target, ..., source = NULL, z_ = 0, t_ = numeric(0)) {
  ## don't run this if the basic test fails
  #tst <- getOption("PROJ.HAVE_PROJ6")
  #if (!tst) stop("no PROJ6 available (you could use proj4 package, via reproj)")

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
  if (length(z_) < 1) z_ <- 0
  if (length(z_) < length(x)) z_ <- rep(z_,  length.out = length(x))
  result <- .C("PROJ_proj_trans_generic",
           src_ = as.character(source), tgt_ = as.character(target),
           n = as.integer(n),
           x_ = as.double(x), y_ = as.double(y),
           z_ = as.double(z_), t_ = as.double(t_),
           success = as.integer(0),
           NAOK=TRUE, PACKAGE = "PROJ")
  if (!result[["success"]]) stop("problem in PROJ transformation:\n(likely you don't have system PROJ version 6 or higher), WIP: see help in reproj package")
  result[c("x_", "y_", "z_", "t_")]
}


