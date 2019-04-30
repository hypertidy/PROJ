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


base_proj_trans_fwd <- function(dst, x, y, z) {
   .Call ("R_proj_trans_FWD", as.character(dst[1]), as.double(x), as.double(y), as.double(z),
            PACKAGE = "PROJ")
}
base_proj_trans_inv <- function(dst, x, y, z) {
   .Call ("R_proj_trans_INV", as.character(dst[1]), as.double(x), as.double(y), as.double(z),
          PACKAGE = "PROJ")
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
#' @param quiet logical, emit messages and warnings, set to `TRUE` for not
#' @return list of transformed x, y, z
#' @examples
#' dst<- "+proj=laea +datum=WGS84 +lon_0=1"
#' proj_trans(dst, 0, 0)
#' proj_trans(dst, -111318.1, 0, INV = TRUE)
proj_trans <- function(TARGET, X, Y, Z = 0.0, ..., INV = FALSE,  quiet = FALSE) {
  TARGET <- .proj_string(TARGET, xname = "TARGET")
  # handle lengths of inputs and defaults for Z
  len <- length(X)
  if (length(Z) == 1L) Z <- rep(Z, len)
  if (!length(Y) == len) stop("length of Y must match length of X")
  if (!length(Z) == len) stop("length of Z must match length of X")
  somebad <- FALSE
  if (anyNA(X) || anyNA(Y) || anyNA(Z)) {
     somebad <- TRUE
     bad <- is.na(X) | is.na(Y) | is.na(Z)
     if (all(bad)) stop("no valid coordinates, nothing to do")
    if (!quiet) warning(sprintf("some invalid or values, ignoring %i coordinates that will be NA in output", sum(bad)))
     X[bad] <- 0.0
     Y[bad] <- 0.0
     Z[bad] <- 0.0
 }
    if (INV) {
       result <- base_proj_trans_inv(TARGET, X, Y, Z)
    } else {
       result <- base_proj_trans_fwd(TARGET, X, Y, Z)
    }

  out <- cbind(result[["X"]], result[["Y"]], result[["Z"]])
 if (somebad) {
   out[bad, ] <- rep(NA_real_, sum(bad) * 3L)
 }
 ## maybe zapsmall here
 out
}
