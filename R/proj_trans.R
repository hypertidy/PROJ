# PROJ_proj_trans_xy <- function(x, src_, tgt_) {
#  x <- as.list(x)
#  if (!length(x) %in% c(2, 4)) {
#    stop("input must be a list of 2 or 4 numeric vectors")
#  }
#  lens <- lengths(x)
#  if (!length(unique(lens)) == 1L) {
#    stop("all input vectors must be equal length")
#  }
#  if (lens[1] < 1) {
#    stop("no 0-length vectors")
#  }
#  if (!is.numeric(x[[1]])) {
#    stop("only numeric vectors")
#  }
#  out <- .Call("PROJ_proj_trans_xy", x = x,
#        src_ = as.character(src_), tgt_ = as.character(tgt_), PACKAGE = "PROJ")
#  if (is.null(out)) {
#    stop("cannot transform")
#  }
#  nam <- c("x_", "y_")
#  names(out) <- nam
#  out
# }
# if (length(x) ==4) {
#
# }
#
#
# PROJ_proj_trans_xyzt <- function(x, src_, tgt_) {
#    x <- as.list(x)
#    if (!length(x) == 4L) {
#       stop("input must be a list of 4 numeric vectors")
#    }
#    lens <- lengths(x)
#    if (!length(unique(lens)) == 1L) {
#       stop("all input vectors must be equal length")
#    }
#    if (lens[1] < 1) {
#       stop("no 0-length vectors")
#    }
#    if (!is.numeric(x[[1]])) {
#       stop("only numeric vectors")
#    }
#    out <- .Call("PROJ_proj_trans_list", x = x,
#                 src_ = as.character(src_), tgt_ = as.character(tgt_), PACKAGE = "PROJ")
#    if (is.null(out)) {
#       stop("cannot transform")
#    }
#
#    names(out) <- c("x_", "y_", "z_", "t_")
#    out
# }
