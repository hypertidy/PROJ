context("test-PROJ")

w <- xymap
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"

test_that("PROJ works", {
  if (!ok_proj6()) skip("no PROJ6 available, no real testing to do")

  expect_silent(xyz <- proj_trans_generic(cbind(X = lon, Y = lat, Z = rep(0, length(lon))), dst, source = "WGS84"))
  expect_silent(lonlat <- proj_trans_generic(cbind(X = xyz[, 1L], Y = xyz[, 2L], Z = rep(0, length(lon))),
                                     "WGS84", source = dst))
  expect_true(all(lonlat[, 1L] <= 180))
  expect_true(all(lonlat[, 1L] > -180))
  expect_true(all(lonlat[, 2L] < 90))
  expect_true(all(lonlat[, 2L] > -90))


})

test_that("set proj does nothing on unix", {
  if (!ok_proj6()) skip("no PROJ6 available, no real testing to do")
  if (.Platform$OS.type == "unix") {
    expect_equal(.set_proj_data_on_windows("tfile"), c(windows = FALSE, ok = FALSE))
  }
  ## don't test this on Windows
})

