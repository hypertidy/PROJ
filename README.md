
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of PROJ is to provide generic coordinate system
transformations.

## Installation

Too early.

# Notes

THINGS TO WORRY ABOUT:

  - the *name* of this package
  - t and z
  - threading, see the PJ\_CONTEXT
  - coordinate order

<https://proj4.org/development/quickstart.html>

## Example

Minimal code example, two lon-lat coordinates to LAEA, and back.

``` r
library(PROJ)
lon <- c(0, 147)
lat <- c(0, -42)
z <- rep(0, length(lon))
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"

## forward transformation
(xy <- proj_trans(dst, lon, lat, z, INV = FALSE))
#> $X
#> [1] -8.013029e+06  2.108091e-09
#> 
#> $Y
#> [1] -8225762        0
#> 
#> $Z
#> [1] 0 0

## inverse transformation
proj_trans(dst, xy$X, xy$Y, z, INV = TRUE)
#> $X
#> [1]   0 147
#> 
#> $Y
#> [1] -3.194835e-15 -4.200000e+01
#> 
#> $Z
#> [1] 0 0
```

A more realistic example with coastline map data.

``` r
library(PROJ)
w <- quadmesh::xymap
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
xyz <- proj_trans(dst, X = lon, Y = lat, Z = rep(0, length(lon)), INV = FALSE)
plot(xyz$X, xyz$Y, pch = ".")
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

lonlat <- proj_trans(dst, X = xyz$X, Y = xyz$Y, Z = rep(0, length(lon)), INV = TRUE)
plot(lonlat$X, lonlat$Y, pch = ".")
```

<img src="man/figures/README-example-2.png" width="100%" />

# Speed comparisons

``` r
ll <- cbind(lon, lat)
llproj <- "+proj=longlat +datum=WGS84"
stll <- sf::st_crs(llproj)
sfx <- sf::st_sfc(sf::st_multipoint(ll), crs = stll)  
rbenchmark::benchmark(PROJ = proj_trans(dst, lon, lat, rep(0, length(lon)), FALSE), 
          reproj = reproj(cbind(lon, lat), target = dst, source = llproj), 
          rgdal = project(ll, dst), 
          lwgeom = st_transform_proj(sfx, dst), 
          sf = st_transform(sfx, dst))
#> Linking to GEOS 3.7.0, GDAL 2.4.0, PROJ 5.2.0
#>     test replications elapsed relative user.self sys.self user.child
#> 4 lwgeom          100  15.876    5.166    15.777    0.092          0
#> 1   PROJ          100   3.119    1.015     3.086    0.032          0
#> 2 reproj          100   4.010    1.305     3.916    0.092          0
#> 3  rgdal          100   3.073    1.000     3.037    0.036          0
#> 5     sf          100  16.083    5.234    16.075    0.004          0
#>   sys.child
#> 4         0
#> 1         0
#> 2         0
#> 3         0
#> 5         0
```

## Why PROJ?

The [reproj](https://CRAN.R-project.org/package=reproj) package wraps
the very efficient `proj::ptransform()` function for general coordinate
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
package](https://github.com/mdsumner/PROJ).

There are a few links to the PROJ (PROJ.4) library in R.

  - [rgdal](https://CRAN.R-project.org/package=rgdal) Provides low level
    `project(matrix, inv = TRUE/FALSE)`, and engine behind
    `sp::spTransform()`.
  - [proj4](https://CRAN.R-project.org/package=proj4) Provides low level
    `project()` and `ptransform`.
  - [sf](https://CRAN.R-project.org/package=sf) Provides high level
    `st_transform()` which works via the GDAL library and its own
    internal version of PROJ (PROJ.4). Converts coordinates in list
    heirarchies of matrices into WKB for the transformations.
  - [lwgeom](https://CRAN.R-project.org/package=lwgeom) Provides high
    level `st_transform_proj()` also converts coordinates in list
    heirarchies of matrices into WKB, but internally uses the PROJ
    (PROJ.4) library directly.

(The [mapproject](https://CRAN.R-project.org/package=mapproject) package
uses all its own internal code).

Only rgdal and proj4 provide raw access to coordinate transformations
for R vectors. Rgdal only has project forward and project inverse and
always works in degrees proj4 has the more general `ptransform()` but
requires manual conversion of degree values into radians. PROJ (PROJ.4)
internally works only with radians.

The packages rgdal, sf, lwgeom are now compatible with PROJ 5 (and 6)
and don’t need any further attention in this regard. They work fine
within their chosen context.

Are there any other wrappers around PROJ (PROJ.4) on CRAN or
Bioconductor, or in the works? Let me know\!

-----

Please note that the ‘PROJ’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
