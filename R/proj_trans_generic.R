#' PROJ transform generic
#'
#' A raw interface to proj_trans_generic in PROJ => 6, if it is available.
#' @param source projection of input coordinates (must be named)
#' @param target projection for output coordinates
#' @param x input coordinates
#' @param ... ignored
#' @export
#' @examples
#' proj_trans_generic(cbind(147, -42), "+proj=laea", source = "epsg:4326")
proj_trans_generic <- function(x, target, ..., source = NULL) {

  if (missing(target) | !is.character(target)) stop("target must be a string")
  if (is.null(source) | !is.character(source)) stop("source must be provided as a string")
 ## don't run this if the basic test fails
  tst <- ok_proj6()
  if (!tst) stop("no PROJ6 available")

  x <- as.matrix(x)
  n <- dim(x)[1L]
  if (!is.numeric(x)) stop("input coordinates must be numeric")
  if (n < 1) stop("must be at least one coordinate")
  if (dim(x)[2L] > 4) x <- x[,1:4, drop = FALSE]
  if (dim(x)[2L] == 1) x <- cbind(x, 0, 0, 0)
  if (dim(x)[2L] == 2) x <- cbind(x, 0, 0)
  if (dim(x)[2L] == 3) x <- cbind(x, 0)


  ## reproj does all this stuff, and should also do the stuff above for this interface
  # xx <- x
  # ## now unpack those
  t <- x[,4L, drop = TRUE]
  z <- x[,3L, drop = TRUE]
  y <- x[,2L, drop = TRUE]
  x <- x[,1L, drop = TRUE]
  # bad <- is.na(x) | is.na(y) | is.na(z) | is.na(t)
  # if (all(bad)) stop("no valid coordinates given, all have missing values")
  # #.C(PROJ_proj_trans_generic, "epsg:4326", "+proj=laea", as.integer(1L),
  # as.double(0), as.double(0), as.double(0), as.double(0), as.integer(0))
  result <- .C(PROJ_proj_trans_generic,
           as.character(source), as.character(target),
           as.integer(n),
           x_ = as.double(x), y_ = as.double(y), z_ = as.double(z), t_ = as.double(t),
           success = as.integer(0),
           NAOK=TRUE, PACKAGE = "PROJ")
  if (!result[["success"]]) stop("problem in PROJ transformation")
  cbind(result[["x_"]], result[["y_"]], result[["z_"]], result[["t_"]])
}

ok_proj6 <- function() {
  test<- .C(PROJ_proj_trans_generic, "epsg:4326", "+proj=laea", as.integer(1L),
    as.double(0), as.double(0), as.double(0), as.double(0), success = as.integer(0))
  if (!test[["success"]] == 1L) {
    out <- FALSE
  } else {
    out <- TRUE
  }
  out
}
