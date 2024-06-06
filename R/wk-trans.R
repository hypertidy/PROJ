#' Create a transformation object
#'
#' Creates a transformation object that transforms coordinates in a wk
#' pipeline.
#'
#' @name proj_trans_create
#' @inheritParams wk::wk_trans_set
#' @param source_crs,target_crs Source/Target CRS definition, coerced with [wk::wk_crs_proj_definition()]
#' @return A PROJ transformation object
#'
#' @examples
#' (trans <- proj_trans_create("EPSG:4326", "EPSG:3857"))
#' wk::wk_transform(wk::xy(1:5, 1:5), trans)
#'
#' library(wk)
#' (invtrans <- wk_trans_inverse(trans))
#'
#' h <- 1852 * 60
#' ## the stretch of Mercator to a square
#' wk::wk_transform(wk::xy(c(-h * 180, 0, h * 180), c(-h * 180,0, h * 180)), invtrans)
#'
#' @export
proj_trans_create <- function(source_crs, target_crs, use_z = NA, use_m = NA) {
  source_crs <- proj_add_type_crs_if_needed(wk::wk_crs_proj_definition(source_crs))
  target_crs <- proj_add_type_crs_if_needed(wk::wk_crs_proj_definition(target_crs))

  if (is.na(source_crs) || nchar(source_crs) == 0) stop("`source_crs` is invalid")
  if (is.na(target_crs) || nchar(target_crs) == 0) stop("`target_crs` is invalid")

  stopifnot(is.logical(use_z) && is.logical(use_m))

  trans <- .Call(
    C_proj_trans_create,
    source_crs,
    target_crs,
    use_z[1],
    use_m[1]
  )

  wk::new_wk_trans(trans, "proj_trans")
}

#' @importFrom wk wk_trans_inverse
#' @export
wk_trans_inverse.proj_trans <- function(trans, ...) {
  trans_inv <- .Call(C_proj_trans_inverse, trans)
  wk::new_wk_trans(trans_inv, "proj_trans")
}

#' @export
print.proj_trans <- function(x, ...) {
  info <- proj_trans_info(x)

  # FIXME: cleanup repetitive code
  lines <- paste_line(
    sprintf("<proj_trans at %s>", .Call(C_xptr_addr, x)),
    sprintf("type: %s", info$type),
    sprintf("id: %s", info$id),
    sprintf("description: %s", info$description),
    sprintf("definition: %s", info$definition),
    "area_of_use:",
    sprintf("  name: %s", info$area_of_use$name),
    sprintf("  bounds: %s", info$area_of_use$bounds),
    "source_crs:",
    sprintf("  type: %s", info$source_crs$type),
    sprintf("  id: %s", info$source_crs$id),
    sprintf("  name: %s", info$source_crs$name),
    "  area_of_use:",
    sprintf("    name: %s", info$source_crs$area_of_use$name),
    sprintf("    bounds: %s", info$source_crs$area_of_use$bounds),
    "target_crs:",
    sprintf("  type: %s", info$target_crs$type),
    sprintf("  id: %s", info$target_crs$id),
    sprintf("  name: %s", info$target_crs$name),
    "  area_of_use:",
    sprintf("    name: %s", info$target_crs$area_of_use$name),
    sprintf("    bounds: %s", info$target_crs$area_of_use$bounds)
  )

  cat(lines, sep = "\n")

  invisible(x)
}

#' @export
#' @importFrom utils str
str.proj_trans <- function(object, ...) {
  cat(
    sprintf("<proj_trans at %s>", .Call(C_xptr_addr, object)),
    format(object),
    sep = "\n"
  )
  invisible(object)
}

#' @export
format.proj_trans <- function(x, ...) {
  # FIXME: wkt or json may be better options
  proj_trans_info(x)$definition
}
