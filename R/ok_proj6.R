#' Is 'PROJ library >= 6' available
#'
#' Test for availability of 'PROJ' system library version 6 or higher.
#'
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

  mock_no_proj6 <- getOption("reproj.mock.noproj6")

  if (!is.null(mock_no_proj6) && isTRUE(mock_no_proj6)) {
    message("PROJ6 *is* available, but operating in mock-no-proj6 mode '?PROJ::ok_proj6'")
    out <- FALSE
  } else {
    #test <- try(proj_trans(list(x = 0, y = 0),
    ##                       source = "+proj=longlat +datum=WGS84",
    #                       target = "+proj=laea"), silent = TRUE)
    #out <-   !inherits(test, "try-error")
    out <- !is.na(proj_version())
  }

  out
}
