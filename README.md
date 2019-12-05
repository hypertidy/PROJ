
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/hypertidy/PROJ.svg?branch=master)](https://travis-ci.org/hypertidy/PROJ)[![AppVeyor
build
status](https://ci.appveyor.com/api/projects/status/jb3sg8r0exigdbb0/branch/master?svg=true)](https://ci.appveyor.com/project/mdsumner/proj-448mq)[![Codecov
test
coverage](https://codecov.io/gh/hypertidy/PROJ/branch/master/graph/badge.svg)](https://codecov.io/gh/hypertidy/PROJ?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/PROJ)](https://cran.r-project.org/package=PROJ)
[![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/PROJ)](https://cran.r-project.org/package=PROJ)
[![Travis
PROJ5(non-func)](https://travis-ci.org/hypertidy/PROJ.svg?branch=master&env=BUILD_NAME=proj5&label=PROJ5\(non-func\))](https://travis-ci.org/hypertidy/PROJ)
[![Travis
PROJ6](https://travis-ci.org/hypertidy/PROJ.svg?branch=master&env=BUILD_NAME=proj6&label=PROJ6)](https://travis-ci.org/hypertidy/PROJ)
[![Travis
PROJ7](https://travis-ci.org/hypertidy/PROJ.svg?branch=master&env=BUILD_NAME=proj7&label=PROJ7)](https://travis-ci.org/hypertidy/PROJ)
<!-- badges: end -->

The goal of PROJ is to provide generic coordinate system transformations
and overcome some current challenges and limitations in R. The key
aspect is the same goal as the
[reproj](https://cran.r-project.org/package=reproj) package - generic
transformations of coordinates. Having methods for objects and types can
come later, I need basic stuff for the way data is stored in R, as
matrices or data frames with efficient vectors of coordinate fields.

PROJ is strictly for version 6.0.0 or higher of the PROJ library. The
intention is that this package will be used for when that version is
available, and this package can be compiled and installed even when it
cannot do anything. For older versions of PROJ (5, and 4) we can use the
proj4 package.

Because we are version 6 or above only, there is no forward/inverse
transformation, only integrated source/target idioms. The source must be
provided along with the target. We can use “auth:code” forms, PROJ.4
strings, full WKT2, or the name of a CRS as found in the PROJ database,
e.g “WGS84”, “NAD27”, etc. Full details are provided in the [PROJ
documentation](https://proj.org/development/reference/functions.html#c.proj_create).

## Things to be aware of

  - Input can be a data frame or a matrix, but internally input is
    assumed to be x, y, z, *and time*. So the output is always a
    4-column matrix.
  - You can’t use strings like “+init=epsg:4326” any more, it must be
    “epsg:4326”.
  - You should know what your target projection is, and also what your
    source projection is. This is your responsibility.

Personally, I need this low-level package in order to develop other
projects. I don’t care about the big snafu regarding changes in version
6 and whatever, we should have low-level tools and then we can tool
around in R to sort stuff out. A text-handler for various versions and
validations of CRS representations would be good, for instance we can
just gsub out “+init=” for those sorts of things, and being able to
write “WGS84” as a valid source or target is a massive bonus.

## WAAT

This package strips code out of the development version of proj4, with
attribution to the author.

  - Why not proj4? It’s not maintained in a way that works for me.
  - Why not sf? It brings a lot of baggage, and can’t do geocentric
    transformations.
  - Why not rgdal? Still baggage, no transformations possible without
    special data formats.
  - Why not reproj? This is an extension for reproj, to bridge it from
    PROJ version 4 and 5, to version 6 and 7 and beyond.

## Installation

WIP

# Notes

THINGS TO WORRY ABOUT for development here:

  - the *name* of this package
  - t and z
  - threading, see the PJ\_CONTEXT
  - coordinate order
  - the zero value after transformation, it comes out like -3.19835e-15
    (do we just zapsmall()?)

<https://proj4.org/development/quickstart.html>

## Example

Minimal code example, two lon-lat coordinates to LAEA, and back.

``` r
library(PROJ)
lon <- c(0, 147)
lat <- c(0, -42)
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
src <- "WGS84"

## forward transformation
(xy <- proj_trans_generic( cbind(lon, lat), dst, source = src))
#>          [,1]     [,2] [,3] [,4]
#> [1,] -8013029 -8225762    0    0
#> [2,]        0        0    0    0

## inverse transformation
proj_trans_generic(xy, src, source = dst)
#>      [,1]          [,2] [,3] [,4]
#> [1,]    0 -3.194835e-15    0    0
#> [2,]  147 -4.200000e+01    0    0
```

A more realistic example with coastline map data.

``` r
library(PROJ)
w <- PROJ::xymap
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
xyzt <- proj_trans_generic(cbind(lon, lat, 0), dst, source = "epsg:4326")
plot(xyzt[,1:2, drop = FALSE], pch = ".")
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

lonlat <- proj_trans_generic(xyzt, src, source = dst)
plot(lonlat, pch = ".")
```

<img src="man/figures/README-example-2.png" width="100%" />

# Speed comparisons

``` r
library(reproj)
library(rgdal)
library(lwgeom)
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.2, PROJ 6.2.1
lon <- w[,1]
lat <- w[,2]
lon <- rep(lon, 5)
lat <- rep(lat, 5)
ll <- cbind(lon, lat)
z <- rep(0, length(lon))
llproj <- "+proj=longlat +datum=WGS84"
# stll <- sf::st_crs(llproj)
# sfx <- sf::st_sfc(sf::st_multipoint(ll), crs = stll)  
rbenchmark::benchmark(
          PROJ = proj_trans_generic(cbind(lon, lat, z), dst, source = llproj),
          reproj = reproj(cbind(lon, lat, z), target = dst, source = llproj), 
          rgdal = project(ll, dst), 
          sf_project = sf_project(llproj, dst, ll),
        # lwgeom = st_transform_proj(sfx, dst), 
        # sf = st_transform(sfx, dst), 
        replications = 100) %>% 
  dplyr::arrange(elapsed) %>% dplyr::select(test, elapsed, replications)
#>         test elapsed replications
#> 1      rgdal   1.281          100
#> 2 sf_project   1.596          100
#> 3       PROJ   1.894          100
#> 4     reproj   2.109          100
```

The speed is not exactly stunning, but with PROJ we can also do 3D
transformations. There’s some cruft in there for me to move out, you
should be able to get the best speed with raw vector input, so perhaps
needs more
functions.

``` r
xyz <- proj_trans_generic(cbind(lon, lat, z), "+proj=geocent +datum=WGS84", source = "WGS84")
plot(as.data.frame(xyz), pch = ".")
```

<img src="man/figures/README-geocentric-1.png" width="100%" />

Geocentric transformations aren’t used in R much, but some examples are
found in the [quadmesh](https://CRAN.R-project.org/package=quadmesh) and
[anglr](https://github.com/hypertidy/anglr) packages.

## Why PROJ?

The [reproj](https://CRAN.R-project.org/package=reproj) package wraps
the very efficient `proj4::ptransform()` function for general coordinate
system transformations. Several package now use reproj for its
consistency (no format or plumbing issues) and efficiency (directly
transforming bulk coordinates). The proj4 package used by reproj doesn’t
provide the modern features of PROJ (PROJ.4), has not been updated on
CRAN since 2012 and has an uncertain future. So reproj requires a new
wrapper around PROJ (PROJ.4) itself.

Since the 1990s [PROJ.4](https://proj4.org) has been the name of the
common standard library for general coordinate system transformations
(for geospatial). That 1994 release has been modernized and now has
versions **PROJ 5** and **PROJ 6**. There’s a bit of traction in the
name PROJ.4, so it has stuck

I’ll use “PROJ (PROJ.4)” to distinguish the [system
library](https://proj4.org) from [this
package](https://github.com/hypertidy/PROJ).

There are a few links to the PROJ (PROJ.4) library in R.

  - [rgdal](https://CRAN.R-project.org/package=rgdal) Provides low level
    `project(matrix, inv = TRUE/FALSE)`, and engine behind
    `sp::spTransform()`.
  - [proj4](https://CRAN.R-project.org/package=proj4) Provides low level
    `project()` and `ptransform`.
  - [sf](https://CRAN.R-project.org/package=sf) Provides low level
    `sf::sf_project()` transformation of matrices. Provides high level
    `st_transform()` which works via the GDAL library and its own
    internal version of PROJ (PROJ.4). The high level function converts
    coordinates in list heirarchies of matrices into WKB for the
    transformations.
  - [lwgeom](https://CRAN.R-project.org/package=lwgeom) Provides high
    level `st_transform_proj()` also converts coordinates in list
    heirarchies of matrices into WKB, but internally uses the PROJ
    (PROJ.4) library directly.

(The [mapproject](https://CRAN.R-project.org/package=mapproject) package
uses all its own internal code).

Packages sf, rgdal and proj4 provide raw access to coordinate
transformations for R vectors. `sf::sf_project()` is the winner, but is
embedded in a package that does many other things. Rgdal only has
project forward and project inverse and always works in degrees proj4
has the more general `ptransform()` but requires manual conversion of
degree values into radians. PROJ (PROJ.4) internally works only with
radians.

The rgdal function `project()` won’t transform with a third Z
coordinate. The sf functions do work with geocentric coords.

The packages rgdal, sf, lwgeom are now compatible with PROJ 5 (and 6)
and don’t need any further attention in this regard. They work fine
within their chosen context.

Are there any other wrappers around PROJ (PROJ.4) on CRAN or
Bioconductor, or in the works? Let me know\!

-----

Please note that the ‘PROJ’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
