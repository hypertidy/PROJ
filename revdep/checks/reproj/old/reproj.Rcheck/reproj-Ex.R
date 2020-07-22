pkgname <- "reproj"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('reproj')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("reproj")
### * reproj

flush(stderr()); flush(stdout())

### Name: reproj.sc
### Title: Reproject coordinates.
### Aliases: reproj.sc reproj.mesh3d reproj.quadmesh reproj.triangmesh
###   reproj reproj.matrix reproj.data.frame

### ** Examples

reproj(cbind(147, -42), target = "+proj=laea +datum=WGS84",
                         source = "+proj=longlat +datum=WGS84")



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
