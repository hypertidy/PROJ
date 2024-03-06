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

test_that("proj_trans.matrix() works", {
  # xy
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "OGC:CRS84"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # xyz
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1), "EPSG:3857", "OGC:CRS84"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # xym
  expect_equal(
    proj_trans(cbind(x = -1:1, y = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # xyzm
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "OGC:CRS84"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1,
      m = -1:1
    )
  )

  # !use_z
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_z = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # !use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_m = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # !use_z & !use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_z = FALSE, use_m = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # use_z
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_z = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN
    )
  )

  # use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_m = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = NaN
    )
  )

  # use_z & use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "OGC:CRS84", use_z = TRUE, use_m = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN,
      m = NaN
    )
  )

  # drops non-coordinate dimensions (x,y,z,m)
  expect_equal(
    proj_trans(cbind(x = -1:1, y = -1:1, foo = 0), "EPSG:3857", "OGC:CRS84"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )
})
