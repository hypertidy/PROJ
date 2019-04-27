# TODO make this a  user-level validator, so it can be use upfront and not repeated
.proj_string <- function(x, xname = "TARGET") {
   ## must be length 1
   if (length(x) > 1) warning(sprintf("'%s' multiple proj strings, ignoring all but first",
                                      xname))
   x <- x[1L]
   if (!is.character(x)) {
      warning(sprintf("'%s' proj string must be single-length character vector", xname))
      x <- as.character(x)
   }
   xin2 <- x
   x <- trimws(x)
   if (xin2 != x) warning(sprintf("'%s' proj string extraneous white space removed", xname))
   swp <- startsWith(x, "+proj=")
   swi <- startsWith(x, "+init=")
   if (!(swp || swi)) {
     stop("proj string must start like '+proj=' or '+init='")
   }
   if (swi) {
      if (grepl("EPSG", x)) {
         xin <- x
         x <- tolower(x)
         if (xin != x) warning(sprintf("'%s' proj string converted to lower case", xname),
                               call. = FALSE)
      }
   }
   x
}

#' PROJ trans
#'
#' Coordinate transform in forward or inverse mode
#'
#'
#' t is set to 0 internally
#' https://proj4.org/development/quickstart.html
#'
#' The minimal input is three arguments, 'TARGET', 'X', 'Y'
#' @export
#' @param TARGET target projection
#' @param X x coordinate, no default
#' @param Y y coordinate, no default
#' @param Z z coordinate, defaults to zero
#' @param ... unused, but ensures that 'INV' must be named
#' @param INV forward or inverse projection (default forward = FALSE)
#' @return list of transformed x, y, z
#' @examples
#' dst<- "+proj=laea +datum=WGS84 +lon_0=1"
#' proj_trans(dst, 0, 0)
#' proj_trans(dst, -111318.1, 0, INV = TRUE)
proj_trans <- function(TARGET, X, Y, Z = 0.0, ..., INV = FALSE, check_proj = TRUE) {
 if (check_proj) TARGET <- .proj_string(TARGET, xname = "TARGET")
  # handle lengths of inputs and defaults for Z
 XYZ <- cbind(X, Y, Z)
 if (!is.numeric(XYZ)) stop("bad inputs for X, Y, or Z")
 len <- dim(XYZ)[1L]
 #bad <- is.na(XYZ[, 1L]) | is.na(XYZ[, 2L]) | is.na(XYZ[,3L])
 bad <- .rowSums(is.na(XYZ), len, 3L) > 0
 somebad <- any(bad)
 if (any(somebad)) {
   if (all(bad)) stop("no valid coordinates, nothing to do")
   warning(sprintf("some invalid or values, ignoring %i coordinates that will be NA in output", sum(bad)))
   XYZ <- XYZ[!bad, , drop = FALSE]
   X <- XYZ[,1L, drop = TRUE]
   Y <- XYZ[,2L, drop = TRUE]
   Z <- XYZ[,3L, drop = TRUE]
 }
 result <- proj_trans_cpp(TARGET, X = X, Y = Y, Z = Z, INV = INV)
 if (!somebad) {
   out <- cbind(result$X, result$Y, result$Z)
 } else {
   out <- matrix(NA_real_, nrow = len, ncol = 3L)
   out[!bad, ] <- cbind(result$X, result$Y, result$Z)
 }
 ## maybe zapsmall here
 out
}
