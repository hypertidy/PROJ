#' Is 'PROJ library >= 6' available
#'
#' It's not clear this is needed, because we've already tested the capability at package load time,
#' when the data directory paths are set. Probably will remove this function, or override it's implementation.
#'
#' Test for availability of 'PROJ' system library version 6 or higher.
#'
#' If 'PROJ' library version 6 is not available, the package still compiles and installs
#' but is not functional.
#' @return logical, `TRUE` if 'PROJ >= 6'
#' @export
#'
#' @examples
#' ok_proj6()
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
