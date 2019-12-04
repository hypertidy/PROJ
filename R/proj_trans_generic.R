#' @useDynLib PROJ, C_proj_trans_generic
proj_trans_generic <- function(source, target, n,
                                   x, y, z, t) {
  .C(C_proj_trans_generic,
          as.character(source), as.character(target),
          as.integer(n),
          x_ = as.double(x), y_ = as.double(y), z_ = as.double(z), t_ = as.double(t),
          NAOK=TRUE, PACKAGE = "PROJ")
}
