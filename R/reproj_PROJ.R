#' Reproj base function
#'
#' Coordinate transformation via the PROJ library
#'
#' Designed for use by the reproj package.
#' @param x matrix of x, y, z (z is optional, 2 or 3 columns)
#' @param target projection to transform to
#' @param ... reserved
#' @param source projection being transformed from
#'
#' @return matrix of 3 columns (x, y, z or long, lat, z)
#' @export
#'
#' @examples
#' m <- cbind(147, -42)
#' plot(m, pch = ".")
#' s0 <- "+init=epsg:4326"
#' t1 <- "+proj=laea"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
#' t1 <- "+proj=lcc +lon_0=147"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
#' t1 <- "+proj=gnom +lon_0=147"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
#' t1 <- "+proj=laea +lon_0=147"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
#' t1 <- "+proj=ortho +lon_0=147"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
#' t1 <- "+proj=merc +lon_0=147"
#' m <- reproj_PROJ(m, t1, source = s0); s0 <- t1
#' plot(m, pch = ".")
reproj_PROJ <- function(x, target, ..., source = NULL) {
  if (is.null(source))
    stop("'source' projection must be included, as a named argument")
  source <- to_proj(source)
  target <- to_proj(target)
  validate_proj(source)
  validate_proj(target)

  if (ncol(x) < 3) x <- cbind(x, 0)
  if (is_ll(source) && is_ll(target)) stop("must be forward, inverse, or transform")
  if (!is_ll(source)) {
    x <- PROJ::proj_trans(source, x[,1], x[,2], x[,3], INV = TRUE)
    #x <- do.call(cbind, x)
  }
  if (!is_ll(target)) {
    x <- PROJ::proj_trans(target, x[, 1], x[, 2], x[, 3], INV = FALSE)
    #x <- do.call(cbind, x)
  }
  x
}
