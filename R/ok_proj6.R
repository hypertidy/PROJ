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

  test<- .C("PROJ_proj_trans_generic",
            src_ = as.character("+proj=longlat +datum=WGS84"),
            tgt_ = as.character("+proj=laea"),
            n = as.integer(1L),
            x_ = as.double(0), y_ = as.double(0), z_ = as.double(0), t_ = as.double(0),
            success = as.integer(0),
            NAOK=TRUE, PACKAGE = "PROJ")
  if (!test[["success"]] == 1L) {
    out <- FALSE
  } else {
    out <- TRUE
    ## sanity check - see issue #14
    new_syntax <- try(

      .Call("PROJ_proj_create",
            crs_ = as.character("EPSG:4326"),
            format = as.integer(1L),
            PACKAGE = "PROJ")
    )
    if (inherits(new_syntax, "try-error")) {
      out <- FALSE
    }
  }

  mock_no_proj6 <- getOption("reproj.mock.noproj6")
  if (out && !is.null(mock_no_proj6) && isTRUE(mock_no_proj6)) {
    message("PROJ6 *is* available, but operating in mock-no-proj6 mode '?PROJ::ok_proj6'")
    out <- FALSE
  }
  out
}
