#' Is 'PROJ library >= 6' available
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Test for availability of 'PROJ' system library version 6 or higher.
#'
#' @details
#' On unix-alikes, this function is run in `.onLoad()` to check that version 6 functionality is
#' available. On Windows, the load process sets the data file location with the version 6 API, and that
#' is used as a test instead.
#'
#' If 'PROJ' library version 6 is not available, the package still compiles and installs
#' but is not functional.
#'
#' The lack of function can be simulated by setting
#' `options(reproj.mock.noproj6 = TRUE)`, designed for use with the reproj package.
#' @return logical, `TRUE` if the system library 'PROJ >= 6'
#' @export
#'
#' @examples
#' ok_proj6()
ok_proj6 <- function() {
  lifecycle::deprecate_warn("0.5", "ok_proj6()")
  TRUE
}
