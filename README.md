
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
#> 4 lwgeom          100  14.758    5.107    14.690    0.068          0
#> 1   PROJ          100   3.137    1.085     3.083    0.052          0
#> 2 reproj          100   3.742    1.295     3.622    0.120          0
#> 3  rgdal          100   2.890    1.000     2.850    0.040          0
#> 5     sf          100  15.504    5.365    15.484    0.020          0
#>   sys.child
#> 4         0
#> 1         0
#> 2         0
#> 3         0
#> 5         0
```

Please note that the ‘PROJ’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
