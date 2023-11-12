#' Report PROJ library version
#'
#' This function returns NA if PROJ lib is not available.
#'
#' @return character string (major.minor.patch)
#' @export
#'
#' @examples
#' proj_version()
proj_version <- function() {
  .Call("C_proj_version", PACKAGE = "PROJ")
}
