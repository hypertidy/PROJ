proj_create <- function(format = 0L) {
  stopifnot(length(format) == 1L)
  stopifnot(format %in% c(0L, 1L, 2L))
  #stop("not functional")
  .Call("PROJ_proj_create",
        crs_ = "+proj=longlat",
        format = as.integer(1),
        success = 0L,
        PACKAGE = "PROJ")
  # PROJJSON
  # $crs_
  # [1] "+proj=longlat"
  #
  # $format
  # [1] 2
  #
  # $success
  # [1] 1
}
