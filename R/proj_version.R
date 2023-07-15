#' Report PROJ library version
#'
#' @return character string (major.minor.patch)
#' @export
#'
#' @examples
#' proj_version()
proj_version <- function() {
  .Call("C_proj_version", PACKAGE = "PROJ")
}
