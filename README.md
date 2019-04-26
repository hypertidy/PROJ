
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

<!-- badges: start -->

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
#> 4 lwgeom          100  15.760    5.328    15.649    0.105          0
#> 1   PROJ          100   3.216    1.087     3.160    0.047          0
#> 2 reproj          100   3.923    1.326     3.836    0.080          0
#> 3  rgdal          100   2.958    1.000     2.921    0.036          0
#> 5     sf          100  16.304    5.512    16.195    0.096          0
#>   sys.child
#> 4         0
#> 1         0
#> 2         0
#> 3         0
#> 5         0
```

## Why PROJ?

For many years [PROJ.4](https://proj4.org) has been the name of the
common standard library for general coordinate system transformations
(for geospatial). That name was given in the 1970s and is now
encapsulated by a new modernized version of the library that probably
should be called “PROJ”, and now has versions **PROJ 5** and **PROJ 6**.

There are various links to the PROJ.4 library in R.

  - [rgdal](https://CRAN.R-project.org/package=rgdal)

Please note that the ‘PROJ’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
