
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

<!-- badges: start -->

<!-- badges: end -->

The goal of PROJ is to provide generic coordinate system
transformatiosn.

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
library(lwgeom)
#> Linking to liblwgeom 2.5.0dev r16016, GEOS 3.7.0, PROJ 5.2.0
library(rgdal)
#> Loading required package: sp
#> rgdal: version: 1.4-3, (SVN revision 828)
#>  Geospatial Data Abstraction Library extensions to R successfully loaded
#>  Loaded GDAL runtime: GDAL 2.4.0, released 2018/12/14
#>  Path to GDAL shared files: /usr/share/gdal
#>  GDAL binary built with GEOS: TRUE 
#>  Loaded PROJ.4 runtime: Rel. 5.2.0, September 15th, 2018, [PJ_VERSION: 520]
#>  Path to PROJ.4 shared files: (autodetected)
#>  Linking to sp version: 1.3-1
library(reproj)
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
#> 4 lwgeom          100  14.962    5.667    14.845    0.116          0
#> 1   PROJ          100   2.640    1.000     2.600    0.040          0
#> 2 reproj          100   3.795    1.437     3.679    0.116          0
#> 3  rgdal          100   2.964    1.123     2.936    0.028          0
#> 5     sf          100  15.972    6.050    15.892    0.080          0
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
