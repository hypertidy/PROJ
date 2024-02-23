`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

paste_line <- function(...) {
  paste0(c(...), collapse = "\n")
}
