# # TODO make this a  user-level validator, so it can be use upfront and not repeated
# .proj_string <- function(x, xname = "TARGET") {
#    ## must be length 1
#    if (length(x) > 1) warning(sprintf("'%s' multiple proj strings, ignoring all but first",
#                                       xname))
#    x <- x[1L]
#    if (!is.character(x)) {
#       warning(sprintf("'%s' proj string must be single-length character vector", xname))
#       x <- as.character(x)
#    }
#    xin2 <- x
#    x <- trimws(x)
#    if (xin2 != x) warning(sprintf("'%s' proj string extraneous white space removed", xname))
#    swp <- startsWith(x, "+proj=")
#    swi <- startsWith(x, "+init=")
#    if (!(swp || swi)) {
#      stop("proj string must start like '+proj=' or '+init='")
#    }
#    if (swi) {
#       if (grepl("EPSG", x)) {
#          xin <- x
#          x <- tolower(x)
#          if (xin != x) warning(sprintf("'%s' proj string converted to lower case", xname),
#                                call. = FALSE)
#       }
#    }
#    x
# }


