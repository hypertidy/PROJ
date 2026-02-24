test_that("proj_factors() returns a matrix with correct dimensions and colnames", {
  pts <- cbind(147, -42)
  result <- proj_factors(pts, "+proj=laea +lon_0=147 +lat_0=-42 +type=crs")

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 1L)
  expect_equal(ncol(result), 12L)

  expected_cols <- c(
    "meridional_scale", "parallel_scale", "areal_scale",
    "angular_distortion", "meridian_parallel_angle", "meridian_convergence",
    "tissot_semimajor", "tissot_semiminor",
    "dx_dlam", "dx_dphi", "dy_dlam", "dy_dphi"
  )
  expect_equal(colnames(result), expected_cols)
})

test_that("proj_factors() works for multiple coordinates", {
  pts <- cbind(c(130, 147, 160), c(-20, -42, -35))
  result <- proj_factors(pts, "EPSG:3112")

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3L)
  expect_equal(ncol(result), 12L)
  expect_true(all(is.finite(result)))
})

test_that("proj_factors() areal_scale is ~1 for equal-area projection at projection centre", {
  result <- proj_factors(cbind(147, -42), "+proj=laea +lon_0=147 +lat_0=-42 +type=crs")
  expect_equal(unname(result[1, "areal_scale"]), 1, tolerance = 1e-6)
})

test_that("proj_factors() errors on invalid crs", {
  expect_error(proj_factors(cbind(147, -42), "INVALID:9999"))
})

test_that("proj_factors() errors on non-matrix or wrong column count", {
  expect_error(proj_factors(c(147, -42), "EPSG:3112"))
  expect_error(proj_factors(matrix(1, 1, 1), "EPSG:3112"))
})

test_that("proj_factors() accepts data frames and extra columns", {
  pts <- data.frame(lon = c(147, 150), lat = c(-42, -40), extra = 1:2)
  result <- proj_factors(pts, "EPSG:3112")

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 2L)
})
