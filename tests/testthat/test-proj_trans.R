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

test_that("proj_trans.data.frame() works", {
  # xy
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "OGC:CRS84"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # xyz
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1), "EPSG:3857", "OGC:CRS84"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # xym
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # xyzm
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1,
      m = -1:1
    )
  )

  # !use_z
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84", use_z = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # !use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84", use_m = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # !use_z & !use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "OGC:CRS84", use_z = FALSE, use_m = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # use_z
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "OGC:CRS84", use_z = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN
    )
  )

  # use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "OGC:CRS84", use_m = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = NaN
    )
  )

  # use_z & use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "OGC:CRS84", use_z = TRUE, use_m = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN,
      m = NaN
    )
  )

  # keeps non-coordinate dimensions (x,y,z,m)
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, foo = 0), "EPSG:3857", "OGC:CRS84"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      foo = 0
    )
  )
})

test_that("proj_trans.wk_handleable() works", {
  # xyzm
  expect_equal(
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "OGC:CRS84"), "EPSG:3857"),
    wk::xyzm(
      c(-111319.4908, 0, 111319.4908),
      c(-111325.1429, 0, 111325.1429),
      -1:1,
      -1:1,
      "EPSG:3857"
    )
  )

  # !use_z
  expect_equal(
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "OGC:CRS84"), "EPSG:3857", use_z = FALSE),
    wk::xym(
      c(-111319.4908, 0, 111319.4908),
      c(-111325.1429, 0, 111325.1429),
      -1:1,
      "EPSG:3857"
    )
  )

  # !use_m
  expect_equal(
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "OGC:CRS84"), "EPSG:3857", use_m = FALSE),
    wk::xyz(
      c(-111319.4908, 0, 111319.4908),
      c(-111325.1429, 0, 111325.1429),
      -1:1,
      "EPSG:3857"
    )
  )

  # use_z & use_m
  expect_equal(
    proj_trans(wk::wkt("MULTIPOINT ((-1 -1), (0 0), (1 1))", "OGC:CRS84"), "EPSG:3857", use_z = TRUE, use_m = TRUE),
    wk::wkt(
      "MULTIPOINT ZM ((-111319.4907932736 -111325.1428663851 nan nan), (0 0 nan nan), (111319.4907932736 111325.1428663851 nan nan))",
      "EPSG:3857"
    )
  )

  # data.frame
  expect_equal(
    proj_trans(
      data.frame(
        foo = "bar",
        point = wk::xyzm(-1:1, -1:1, -1:1, -1:1, "OGC:CRS84")
      ), 
      "EPSG:3857"
    ),
    data.frame(
      foo = "bar",
      point = wk::xyzm(
        c(-111319.4908, 0, 111319.4908),
        c(-111325.1429, 0, 111325.1429),
        -1:1,
        -1:1,
        "EPSG:3857"
      )
    )
  )
})
