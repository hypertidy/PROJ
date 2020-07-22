context("reproj-PROJ")
#options(reproj.mock.noproj6 = TRUE)
testthat::skip_if_not(PROJ::ok_proj6())

llproj <- "+proj=longlat +datum=WGS84"
laeaproj <- "+proj=laea +datum=WGS84"

# library(proj4)
# dat <- as.matrix(expand.grid(x = seq(-180, 180), y = seq(-90, 90)))
# dat <- dat[sample(nrow(dat), 10), ]
# pdat <- proj4::ptransform(dat * pi/180, llproj, laeaproj)
# dput(dat)
# dput(pdat)
dat <- structure(c(-162L, -97L, -162L, 40L, -36L, 32L, 32L, -67L, -25L,
            -22L, 14L, -31L, 52L, -49L, -1L, -11L, 38L, 66L, -65L, 32L), .Dim = c(10L,
                                                                                  2L), .Dimnames = list(NULL, c("x", "y")))

pdat <- structure(c(-9752052.25396846, -8119467.86794594, -2678218.88894421,
            3109728.10218706, -3941443.47017694, 3466582.53790106, 2920150.83154972,
            -3147972.12215379, -1374249.03919241, -2146112.98562162, 7815696.43338213,
            -4882405.39621803, 11018883.0376461, -5528095.07432074, -116262.853667621,
            -1263068.91163095, 4276503.16642679, 7629667.99984509, -6926735.4349356,
            3555900.89373428), .Dim = c(10L,
                                                                      2L))



test_that("basic reprojection works", {
  expect_equivalent(reproj(dat, source = llproj, target = laeaproj)[,1:2, drop = FALSE], pdat)
  expect_equivalent(reproj(pdat, source = laeaproj, target = llproj)[,1:2, drop = FALSE], dat)

})

test_that("identity reprojection ok", {
  expect_equivalent(reproj(dat, source = llproj, target = llproj)[,1:2, drop = FALSE], dat)
  expect_equivalent(reproj(pdat, source = laeaproj, target = laeaproj)[,1:2, drop = FALSE], pdat)
})

test_that("basic reprojection works", {
  expect_equal(dim(reproj(dat, source = llproj, target = laeaproj, four = TRUE)), c(dim(dat)[1L], 4L))
  expect_equal(dim(reproj(pdat, source = laeaproj, target = llproj, four = TRUE)), c(dim(dat)[1L], 4L))

})
test_that("unit change", {
  expect_equivalent(reproj(dat, source = llproj, target = "+proj=laea +ellps=WGS84 +units=km")[,1:2, drop = FALSE], pdat/1000)
  expect_equivalent(reproj(dat, source = llproj, target = laeaproj)[,1:2, drop = FALSE], pdat)
})

test_that("basic with data frame works", {
  expect_equivalent(reproj(as.data.frame(dat), source = llproj, target = laeaproj)[,1:2, drop = FALSE], pdat)
  expect_equivalent(reproj(as.data.frame(pdat), source = laeaproj, target = llproj)[,1:2, drop = FALSE], dat)
})

test_that("bad arguments fail if we can't assume longlat", {
  options(reproj.assume.longlat = FALSE)
  expect_error(reproj(dat, target = llproj))
  expect_error(reproj(pdat, laeaproj))
})

test_that("bad arguments don't fail if we can assume longlat", {
  options(reproj.assume.longlat = TRUE)
  expect_warning(reproj(dat, target = laeaproj))
  expect_silent(reproj(pdat, llproj, source = laeaproj))
})

test_that("integer inputs become epsg strings", {
    expect_true(grepl("EPSG:", to_proj(4326)))
    expect_true(grepl("EPSG:", to_proj(3857)))

    expect_true(grepl("EPSG:", to_proj("4326")))
    expect_true(grepl("EPSG:", to_proj("3857")))

  expect_error(validate_proj(3434))

  ##expect_silent(.onLoad())
})

test_that("z and t works", {
  expect_silent({
    reproj(cbind(0, 0, 1), "+proj=laea +lon_0=1", source = "+proj=longlat")
  })
  expect_silent({
    reproj(cbind(0, 0, 1, 0), "+proj=laea +lon_0=1", source = "+proj=longlat")
  })
})
test_that("mesh3d works", {
  expect_warning(reproj(.mesh3d, "+proj=laea +datum=WGS84"))
})

test_that("sc works", {
  expect_silent(reproj(.sc, "+proj=laea +datum=WGS84"))
})
