context("test-PROJ")

w <- worlddata
lon <- na.omit(w[,1])
lat <- na.omit(w[,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"

test_that("multiplication works", {
  expect_silent(xyz <- proj_trans(dst, X = lon, Y = lat, Z = rep(0, length(lon)), INV = FALSE))
  expect_silent(lonlat <- proj_trans(dst, X = xyz$X, Y = xyz$Y, Z = rep(0, length(lon)), INV = TRUE))
  expect_true(all(lonlat$X < 180))
  expect_true(all(lonlat$X > -180))
  expect_true(all(lonlat$Y < 90))
  expect_true(all(lonlat$Y > -90))

  expect_equivalent(as.integer(range(xyz$X)), c(-12590739L, 12193021L))
  expect_equivalent(as.integer(range(xyz$Y)), c(-11867430L, 12440125L))

})
