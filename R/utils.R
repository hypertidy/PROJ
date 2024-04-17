`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

paste_line <- function(...) {
  paste0(c(...), collapse = "\n")
}

# ported from https://github.com/OSGeo/PROJ/blob/af8a4edc4e0ce9e56098439181d6f717bcadd5a6/src/4D_api.cpp#L1173-L1181
proj_add_type_crs_if_needed <- function(crs) {
  if ((startsWith(crs, "proj=") || startsWith(crs, "+proj=") ||
      startsWith(crs, "+init=") || startsWith(crs, "+title=")) &&
      !grepl("type=crs", crs, fixed = TRUE)) {
    paste(crs, "+type=crs")
  } else {
    crs
  }
}
