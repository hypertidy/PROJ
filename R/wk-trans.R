#' Create a transformation object
#'
#' Creates a transformation object that transforms coordinates in a wk
#' pipeline.
#'
#' @name proj_trans_create
#' @inheritParams wk::wk_trans_set
#' @param source_crs,target_crs Source/Target CRS definition, coerced with [wk::wk_crs_proj_definition()]
#' @param options character vector of `"KEY=VALUE"` options passed to the PROJ
#'   library when choosing the coordinate operation, see Details
#' @return A PROJ transformation object
#'
#' @details
#' `options` are passed to the PROJ library function
#' `proj_create_crs_to_crs_from_pj()`. The options PROJ accepts are
#'
#' * `AUTHORITY=name` restrict candidate operations to one authority (e.g.
#'   `"EPSG"`), or `"any"`
#' * `ACCURACY=value` minimum desired accuracy in metres
#' * `ALLOW_BALLPARK=YES/NO` set to `NO` to disallow ballpark
#'   transformations
#' * `FORCE_OVER=YES/NO` (PROJ >= 9.1.1) set to `YES` to force the `+over`
#'   flag, so longitudes are not wrapped to -180..180. This is what you want
#'   when transforming data that straddles the antimeridian, see the example
#' * `ONLY_BEST=YES/NO` (PROJ >= 9.2) set to `YES` to error rather than fall
#'   back to a worse operation when the best one needs a grid that is not
#'   available
#'
#' An option the linked PROJ library predates is dropped with a warning. Any
#' other unrecognized option is an error from PROJ.
#'
#' @examples
#' (trans <- proj_trans_create("EPSG:4326", "EPSG:3857"))
#' wk::wk_transform(wk::xy(1:5, 1:5), trans)
#'
#' ## longitude wrapping at the antimeridian: just past the western edge of
#' ## Web Mercator comes back as +180 by default, -180 with FORCE_OVER
#' xmin <- -20037508.3427892
#' inv <- proj_trans_create("EPSG:3857", "EPSG:4326")
#' wk::wk_transform(wk::xy(xmin - 0.001, 0), inv)
#' if (proj_version() >= "9.1.1") {
#'   over <- proj_trans_create("EPSG:3857", "EPSG:4326", options = "FORCE_OVER=YES")
#'   wk::wk_transform(wk::xy(xmin - 0.001, 0), over)
#' }
#'
#' library(wk)
#' (invtrans <- wk_trans_inverse(trans))
#'
#' h <- 1852 * 60
#' ## the stretch of Mercator to a square
#' wk::wk_transform(wk::xy(c(-h * 180, 0, h * 180), c(-h * 180,0, h * 180)), invtrans)
#'
#' @export
proj_trans_create <- function(source_crs, target_crs, use_z = NA, use_m = NA,
                              options = character()) {
  source_crs <- proj_add_type_crs_if_needed(wk::wk_crs_proj_definition(source_crs))
  target_crs <- proj_add_type_crs_if_needed(wk::wk_crs_proj_definition(target_crs))

  if (is.na(source_crs) || nchar(source_crs) == 0) stop("`source_crs` is invalid")
  if (is.na(target_crs) || nchar(target_crs) == 0) stop("`target_crs` is invalid")

  stopifnot(is.logical(use_z) && is.logical(use_m))
  options <- proj_trans_options(options)

  trans <- .Call(
    C_proj_trans_create,
    source_crs,
    target_crs,
    use_z[1],
    use_m[1],
    options
  )

  wk::new_wk_trans(trans, "proj_trans")
}

## options newer than the PROJ 8.2 floor, with the version that introduced
## them; anything not listed here is left to PROJ, which errors on unknown
## options. FORCE_OVER exists from 9.0 but proj_normalize_for_visualization()
## (which every transformer here goes through) only honours it from 9.1.1.
.proj_trans_option_versions <- c(
  FORCE_OVER = "9.1.1",
  ONLY_BEST = "9.2.0"
)

proj_trans_options <- function(options) {
  if (is.null(options) || length(options) == 0L) return(character())
  if (!is.character(options) || anyNA(options)) {
    stop("`options` must be a character vector of \"KEY=VALUE\" strings")
  }
  options <- options[nzchar(options)]
  bad <- !grepl("^[A-Za-z_]+=.+$", options)
  if (any(bad)) {
    stop("`options` must be \"KEY=VALUE\" strings, not: ",
         paste(sQuote(options[bad]), collapse = ", "))
  }
  key <- toupper(sub("=.*$", "", options))
  options <- paste0(key, "=", sub("^[^=]*=", "", options))
  needs <- .proj_trans_option_versions[key]
  have <- numeric_version(proj_version())
  drop <- !is.na(needs) & numeric_version(ifelse(is.na(needs), "0.0.0", needs)) > have
  if (any(drop)) {
    warning(sprintf("ignoring option(s) not supported by PROJ %s: %s",
                    proj_version(),
                    paste(sprintf("%s (PROJ >= %s)", options[drop], needs[drop]), collapse = ", ")),
            call. = FALSE)
    options <- options[!drop]
  }
  options
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
