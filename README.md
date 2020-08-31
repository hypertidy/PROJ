
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ

The goal of PROJ is to provide generic coordinate system transformations
in R with a functional requirement for the system library to be provided
by the [libproj package](https://cran.r-project.org/package=libproj).

This is a shared goal with the
[reproj](https://cran.r-project.org/package=reproj) package, and PROJ
provides the infrastructure for later versions of the underlying
library.

PROJ provides basic coordinate transformations for generic numeric data
in matrices or data frames. Transforming spatial data coordinates is a
basic task independent of storage format.

PROJ is strictly for modern versions of the PROJ library, now via
[libproj package](https://cran.r-project.org/package=libproj) at version
7. Alternative pathways to PROJ via the proj4 package are available but
only used for expert testing.

Because we are using modern PROJ there is no forward/inverse
transformation, only integrated source/target idioms. This is the same
approach taken by the reproj package- the source must be provided as
well as the target. When a data set has an in-built CRS projection
recorded, then methods can be written for that use-case with that
format.

We can use ‘auth:code’ forms, PROJ.4 strings, full WKT2, or the name of
a CRS as found in the PROJ database, e.g ‘WGS84’, ‘NAD27’, etc. Full
details are provided in the [PROJ
documentation](https://proj.org/development/reference/functions.html#c.proj_create).

## Things to be aware of

Note that *PROJ in your system* is not used, PROJ imports the standalone
libproj package installed from CRAN.

  - Input can be a data frame or a matrix, but internally input is
    assumed to be x, y, z, *and time*. So the output is always a
    4-column matrix.
  - You can’t use strings like “+init=epsg:4326” any more, it must be
    “EPSG:4326”.
  - You should know what your target projection is, and also what your
    source projection is. This is your responsibility.
  - PROJ assumes longitude/latitude order always by setting the PROJ
    library context *proj\_normalize\_for\_visualization*.

Please see [PROJ library
documentation](https://proj.org/development/quickstart.html) for details
on this.

## Installation

On all systems do

``` r
install.packages("PROJ")
```

or

``` r
remotes::install_cran("PROJ")
```

To install the development version from Github do

``` r
remotes::install_github("hypertidy/PROJ")
```

## Example

Minimal code example, two lon-lat coordinates to LAEA, and back.

``` r
library(PROJ)
lon <- c(0, 147)
lat <- c(0, -42)
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
src <- "+proj=longlat +datum=WGS84"

## forward transformation
(xy <- proj_trans( cbind(lon, lat), dst, source = src))
#> $x_
#> [1] -8013029        0
#> 
#> $y_
#> [1] -8225762        0

## inverse transformation
proj_trans(cbind(xy$x_, xy$y_), src, source = dst)
#> $x_
#> [1]   0 147
#> 
#> $y_
#> [1] -3.194835e-15 -4.200000e+01


## note that NAs propagate in the usual way
lon <- c(0, NA, 147)
lat <- c(NA, 0, -42)

proj_trans(cbind(lon, lat), src, source = dst)
#> $x_
#> [1]       NA       NA 147.0018
#> 
#> $y_
#> [1]        NA        NA -42.00038
```

A more realistic example with coastline map data.

``` r
library(PROJ)
w <- PROJ::xymap
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
xy <- proj_trans(cbind(lon, lat), dst, source = "epsg:4326")
plot(xy$x_, xy$y_, pch = ".")
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

lonlat <- proj_trans(xy, src, source = dst)
plot(lonlat$x_, lonlat$y_, pch = ".")
```

<img src="man/figures/README-example-2.png" width="100%" />

## Convert projection strings

We can generate PROJ or within limitations WKT2 strings, format 0, 1, 2
for WKT, proj4string, projjson respectively.

``` r
cat(wkt2 <- proj_crs_text("EPSG:4326"))
#> GEOGCRS["WGS 84",
#>     DATUM["World Geodetic System 1984",
#>         ELLIPSOID["WGS 84",6378137,298.257223563,
#>             LENGTHUNIT["metre",1]]],
#>     PRIMEM["Greenwich",0,
#>         ANGLEUNIT["degree",0.0174532925199433]],
#>     CS[ellipsoidal,2],
#>         AXIS["geodetic latitude (Lat)",north,
#>             ORDER[1],
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>         AXIS["geodetic longitude (Lon)",east,
#>             ORDER[2],
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>     USAGE[
#>         SCOPE["unknown"],
#>         AREA["World"],
#>         BBOX[-90,-180,90,180]],
#>     ID["EPSG",4326]]

proj_crs_text(wkt2, format = 1L)
#> [1] "+proj=longlat +datum=WGS84 +no_defs +type=crs"
```

# Speed comparisons

``` r
library(reproj)
library(rgdal)
library(lwgeom)
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 7.0.0
lon <- w[,1]
lat <- w[,2]
lon <- rep(lon, 25)
lat <- rep(lat, 25)
ll <- cbind(lon, lat)
z <- rep(0, length(lon))
llproj <- "+proj=longlat +datum=WGS84"

xyz <- cbind(lon, lat, z)
xyzt <- cbind(lon, lat, z, 0)

rbenchmark::benchmark(
          PROJ = proj_trans(ll, target = dst, source = llproj),
          reproj = reproj::reproj(ll, target = dst, source = llproj),
          rgdal = project(ll, dst),
          sf_project = sf_project(llproj, dst, ll),
        # lwgeom = st_transform_proj(sfx, dst),
        # sf = st_transform(sfx, dst),
        replications = 100) %>%
  dplyr::arrange(elapsed) %>% dplyr::select(test, elapsed, replications)
#>         test elapsed replications
#> 1 sf_project   8.820          100
#> 2       PROJ   9.033          100
#> 3     reproj   9.929          100
#> 4      rgdal  10.390          100
```

A geocentric example, suitable for plotting in rgl.

``` r
xyzt <- proj_trans(cbind(w[,1], w[,2]), z_ = rep(0, dim(w)[1L]), target = "+proj=geocent +datum=WGS84", source = "EPSG:4326")
plot(as.data.frame(xyzt[1:3]), pch = ".", asp = 1)
```

<img src="man/figures/README-geocentric-1.png" width="100%" />

Geocentric transformations aren’t used in R much, but some examples are
found in the [quadmesh](https://CRAN.R-project.org/package=quadmesh) and
[anglr](https://github.com/hypertidy/anglr) packages.

## Why PROJ?

PROJ was created before
[libproj](https://cran.r-project.org/package=libproj) existed, and now
leverages it.

  - Why not proj4? It’s not maintained in a way that works for me.
  - Why not sf? It brings a lot of baggage, and can’t do geocentric
    transformations.
  - Why not rgdal? Still baggage, no transformations possible without
    special data formats, no geocentric.
  - Why not lwgeom? That package is format-specific, and does not work
    with generic data coordinates so is unsuitable for many
    straightforward and efficient data-handling schemes.
  - Why not mapproj? This is unusable for real-world projections in my
    experience, it seems to be written for some basic graphics cases.
  - Why not reproj? reproj will be improved by importing PROJ. This is
    an extension for reproj, to bridge it from PROJ version 4 and 5, to
    version 6 and 7 and beyond.

The [reproj](https://CRAN.R-project.org/package=reproj) package wraps
the very efficient `proj4::ptransform()` function for general coordinate
system transformations. Several package now use reproj for its
consistency (no format or plumbing issues) and efficiency (directly
transforming bulk coordinates). The proj4 package is not updated
regularly, and depends on a local installation of the system library on
some sytems. . So reproj requires a new wrapper around PROJ (PROJ.4)
itself.

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
    hierarchies of matrices into WKB, but internally uses the PROJ
    (PROJ.4) library directly.

(The [mapproj](https://CRAN.R-project.org/package=mapproj) package uses
all its own internal code).

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

-----

Please note that the PROJ project is released with a [Contributor Code
of
Conduct](https://github.com/hypertidy/PROJ/blob/master/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
