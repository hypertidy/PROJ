proj_trans_info <- function(trans) {
  info <- .Call(C_proj_trans_info, trans)

  info$area_of_use <- proj_area_of_use(info$area_of_use)
  info$source_crs <- proj_crs_info(info$source_crs)
  info$target_crs <- proj_crs_info(info$target_crs)

  structure(info, class = "proj_trans_info")
}

proj_area_of_use <- function(area_of_use) {
  if (is.null(area_of_use)) return(NULL)

  area_of_use$bounds <- do.call(wk::rct, as.list(area_of_use$bounds))
  structure(area_of_use, class = "proj_area_of_use")
}

proj_crs_info <- function(crs_info) {
  crs_info$id <- sprintf("%s:%s", crs_info$authority, crs_info$code)
  crs_info$area_of_use <- proj_area_of_use(crs_info$area_of_use)
  structure(crs_info, class = "proj_crs_info")
}
