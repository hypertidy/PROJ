is_scalar_logical <- function(x) {
  is.logical(x) && length(x) == 1
}
