
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of PROJ is to provide generic coordinate system transformations
and overcome some current challenges and limitations in R.

## Installation

WIP

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
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"

## forward transformation
(xy <- proj_trans(dst, lon, lat, INV = FALSE))
#>               [,1]     [,2] [,3]
#> [1,] -8.013029e+06 -8225762    0
#> [2,]  2.108091e-09        0    0

## inverse transformation
proj_trans(dst, xy[,1L], xy[,2L], xy[,3], INV = TRUE)
#>      [,1]          [,2] [,3]
#> [1,]    0 -3.194835e-15    0
#> [2,]  147 -4.200000e+01    0
```

A more realistic example with coastline map data.

``` r
library(PROJ)
w <- PROJ:::worlddata
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
xyz <- proj_trans(dst, X = lon, Y = lat, Z = rep(0, length(lon)), INV = FALSE)
plot(xyz, pch = ".")
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

lonlat <- proj_trans(dst, X = xyz[,1], Y = xyz[,2], INV = TRUE)
plot(lonlat, pch = ".")
```

<img src="man/figures/README-example-2.png" width="100%" />

# Speed comparisons

``` r
library(reproj)
library(rgdal)
library(lwgeom)
library(sf)
#> Linking to GEOS 3.7.0, GDAL 2.4.0, PROJ 5.2.0
lon <- w[,1]
lat <- w[,2]
lon <- rep(lon, 5)
lat <- rep(lat, 5)
ll <- cbind(lon, lat)
z <- rep(0, length(lon))
llproj <- "+proj=longlat +datum=WGS84"
# stll <- sf::st_crs(llproj)
# sfx <- sf::st_sfc(sf::st_multipoint(ll), crs = stll)  
bench::mark(
          PROJ = proj_trans(dst, lon, lat, z, INV = FALSE, quiet = TRUE), 
          PROJ_rcpp = proj_trans(dst, lon, lat, z, INV = FALSE, use_rcpp = TRUE, quiet = TRUE),
          reproj = reproj(cbind(lon, lat, z), target = dst, source = llproj), 
          rgdal = project(ll, dst), 
        # lwgeom = st_transform_proj(sfx, dst), 
        # sf = st_transform(sfx, dst), 
          iterations = 100, check = FALSE) %>% dplyr::arrange(total_time)
#> # A tibble: 4 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 reproj        160ms    165ms      5.90    70.8MB    11.8 
#> 2 PROJ          150ms    153ms      6.43    42.8MB    10.4 
#> 3 PROJ_rcpp     169ms    171ms      5.81    42.8MB     6.64
#> 4 rgdal         133ms    137ms      7.25    22.1MB     1.59
```

The comparison with rgdal is not exactly stunning, but with PROJ we can
also do 3D transformations and (eventually, if needed) datum
transformations and use the pipeline and other new features of PROJ
(PROJ.4).

``` r
xyz <- proj_trans("+proj=geocent +datum=WGS84", lon, lat, z, INV = FALSE)
#> Warning in proj_trans("+proj=geocent +datum=WGS84", lon, lat, z, INV =
#> FALSE): some invalid or values, ignoring 9860 coordinates that will be NA
#> in output
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

The rgdal function `project()` won’t transform with a third Z
coordinate. The sf function `st_transform()` cannot work with geocentric
coordinates.

The packages rgdal, sf, lwgeom are now compatible with PROJ 5 (and 6)
and don’t need any further attention in this regard. They work fine
within their chosen context.

Are there any other wrappers around PROJ (PROJ.4) on CRAN or
Bioconductor, or in the works? Let me know\!

-----

Please note that the ‘PROJ’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
