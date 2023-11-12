context("test-PROJ")

w <- xymap
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"

test_that("PROJ works", {
skip_if(!ok_proj6())
  src <- "+proj=longlat +datum=WGS84"
  expect_silent(xyz <- proj_trans(cbind(X = lon, Y = lat), z_ = rep(0, length(lon)), dst, source = src))
  expect_silent(lonlat <- proj_trans(cbind(X = xyz["x_"], Y = xyz["y_"]), z_ = rep(0, length(lon)),
                                     src, source = dst))
  expect_true(all(lonlat[["x_"]] <= 180))
  expect_true(all(lonlat[["x_"]] > -180))
  expect_true(all(lonlat[["y_"]] < 90))
  expect_true(all(lonlat[["y_"]] > -90))

  expect_silent(xy <- proj_trans(cbind(X = xyz["x_"], Y = xyz["y_"]),
                                     src, source = dst))
  expect_equal(length(xy), 2L)

  ## extra cols are ignored
  expect_silent(xy <- proj_trans(cbind(X = xyz["x_"], Y = xyz["y_"], a  = 1),
                                 src, source = dst))
  expect_error(proj_trans(cbind(0, 0), "+proj=laea", source = "goofy"))

})
