test_that("proj_trans() works", {
  xymap_trans <- proj_trans(
    xymap, 
    "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42 +type=crs", 
    "+proj=longlat +datum=WGS84 +type=crs"
  )

  xymap_roundtrip <- proj_trans(
    xymap_trans,
    "+proj=longlat +datum=WGS84 +type=crs",
    "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42 +type=crs"
  )

  expect_true(
    abs(max(xymap_roundtrip[, "x"], na.rm = TRUE)) <= 180 &&
      abs(max(xymap_roundtrip[, "y"], na.rm = TRUE)) <= 90
  )
})
