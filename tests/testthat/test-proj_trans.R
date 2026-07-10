test_that("proj_trans() works", {
  xymap_trans <- proj_trans(
    xymap,
    "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42 +type=crs",
    "EPSG:4326"
  )

  xymap_roundtrip <- proj_trans(
    xymap_trans,
    "EPSG:4326",
    "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42 +type=crs"
  )

  expect_true(
    abs(max(xymap_roundtrip[, "x"], na.rm = TRUE)) <= 180 &&
      abs(max(xymap_roundtrip[, "y"], na.rm = TRUE)) <= 90
  )
})

test_that("proj_trans.matrix() works", {
  expect_error(
    proj_trans(cbind("foo", "bar"), "EPSG:3857", "EPSG:4326"),
    "`x` coordinates must be a numeric matrix"
  )
  expect_error(proj_trans(cbind(1, 1)), "argument \"target_crs\" is missing, with no default")

  # xy
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "EPSG:4326"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # xyz
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1), "EPSG:3857", "EPSG:4326"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # xym
  expect_equal(
    proj_trans(cbind(x = -1:1, y = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # xyzm
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "EPSG:4326"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1,
      m = -1:1
    )
  )

  # !use_z
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "EPSG:4326", use_z = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # !use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "EPSG:4326", use_m = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # !use_z & !use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1, -1:1, -1:1), "EPSG:3857", "EPSG:4326", use_z = FALSE, use_m = FALSE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # requires paleolimbot/wk#217
  skip_if_not_installed("wk", "0.9.2")

  # use_z
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "EPSG:4326", use_z = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN
    )
  )

  # use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "EPSG:4326", use_m = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = NaN
    )
  )

  # use_z & use_m
  expect_equal(
    proj_trans(cbind(-1:1, -1:1), "EPSG:3857", "EPSG:4326", use_z = TRUE, use_m = TRUE),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN,
      m = NaN
    )
  )
})

test_that("proj_trans.matix() drops non-coordinate dimensions", {
  # drops non-coordinate dimensions (x,y,z,m)
  expect_equal(
    proj_trans(cbind(x = -1:1, y = -1:1, foo = 0), "EPSG:3857", "EPSG:4326"),
    cbind(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )
})

test_that("proj_trans.data.frame() works", {
  # xy
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "EPSG:4326"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # xyz
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1), "EPSG:3857", "EPSG:4326"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # xym
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # xyzm
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1,
      m = -1:1
    )
  )

  # !use_z
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326", use_z = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = -1:1
    )
  )

  # !use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326", use_m = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = -1:1
    )
  )

  # !use_z & !use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, z = -1:1, m = -1:1), "EPSG:3857", "EPSG:4326", use_z = FALSE, use_m = FALSE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429)
    )
  )

  # requires paleolimbot/wk#217
  skip_if_not_installed("wk", "0.9.2")

  # use_z
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "EPSG:4326", use_z = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN
    )
  )

  # use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "EPSG:4326", use_m = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      m = NaN
    )
  )

  # use_z & use_m
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1), "EPSG:3857", "EPSG:4326", use_z = TRUE, use_m = TRUE),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      z = NaN,
      m = NaN
    )
  )
})

test_that("proj_trans.data.frame() keeps non-coordinate dimensions", {
  # keeps non-coordinate dimensions (x,y,z,m)
  expect_equal(
    proj_trans(data.frame(x = -1:1, y = -1:1, foo = 0), "EPSG:3857", "EPSG:4326"),
    data.frame(
      x = c(-111319.4908, 0, 111319.4908),
      y = c(-111325.1429, 0, 111325.1429),
      foo = 0
    )
  )
})

test_that("proj_trans.wk_handleable() works", {
  # data.frame
  expect_equal(
    proj_trans(
      data.frame(
        foo = "bar",
        point = wk::xyzm(-1:1, -1:1, -1:1, -1:1, "EPSG:4326")
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

  # xyzm
  expect_equal(
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "EPSG:4326"), "EPSG:3857"),
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
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "EPSG:4326"), "EPSG:3857", use_z = FALSE),
    wk::xym(
      c(-111319.4908, 0, 111319.4908),
      c(-111325.1429, 0, 111325.1429),
      -1:1,
      "EPSG:3857"
    )
  )

  # !use_m
  expect_equal(
    proj_trans(wk::xyzm(-1:1, -1:1, -1:1, -1:1, "EPSG:4326"), "EPSG:3857", use_m = FALSE),
    wk::xyz(
      c(-111319.4908, 0, 111319.4908),
      c(-111325.1429, 0, 111325.1429),
      -1:1,
      "EPSG:3857"
    )
  )

  # requires paleolimbot/wk#217
  skip_if_not_installed("wk", "0.9.2")

  # use_z & use_m
  expect_equal(
    proj_trans(wk::wkt("MULTIPOINT ((-1 -1), (0 0), (1 1))", "EPSG:4326"), "EPSG:3857", use_z = TRUE, use_m = TRUE),
    wk::wkt(
      "MULTIPOINT ZM ((-111319.4907932736 -111325.1428663851 nan nan), (0 0 nan nan), (111319.4907932736 111325.1428663851 nan nan))",
      "EPSG:3857"
    )
  )
})

test_that("proj_trans.sf() works", {
  skip_if_not_installed("sf")
  options("sf_use_s2" = FALSE)
  expect_equal(
    proj_trans(
      sf::st_as_sf(
        data.frame(x = -1:1, y = -1:1),
        coords = c("x", "y"),
        crs = "EPSG:4326"
      ),
      "EPSG:3857"
    ),
    sf::st_as_sf(
      data.frame(
        x = c(-111319.4908, 0, 111319.4908),
        y = c(-111325.1429, 0, 111325.1429)
      ),
      coords = c("x", "y"),
      crs = "EPSG:3857"
    )
  )
})

test_that("proj_trans.sfc() works", {
  skip_if_not_installed("sf")
  options("sf_use_s2" = FALSE)
  expect_equal(
    proj_trans(
      sf::st_sfc(
        sf::st_point(c(-1, -1)), sf::st_point(c(0, 0)), sf::st_point(c(1, 1)),
        crs = "EPSG:4326"
      ),
      "EPSG:3857"
    ),
    sf::st_sfc(
      sf::st_point(c(-111319.4908, -111325.1429)),
      sf::st_point(c(0, 0)),
      sf::st_point(c(111319.4908, 111325.1429)),
      crs = "EPSG:3857"
    )
  )
})

test_that("proj_trans() handles out-of-bounds coordinates", {
  trans_a <- expect_no_error(
    proj_trans(
      cbind(c(100.25, 100.75, 101.25, 101.75, 102.25, 102.75), 100.25),
      "+proj=merc +datum=WGS84 +type=crs",
      "EPSG:4326"
    )
  )

  expect_true(!all(is.finite(trans_a[, 1])))

  trans_b <- expect_no_error(
    proj_trans(cbind(2e10, 2e12),
      source = "+proj=stere +datum=WGS84 +type=crs",
      target = "+proj=laea +datum=WGS84 +type=crs"
    )
  )

  expect_true(is.matrix(trans_b))
  expect_true(all(!is.finite(trans_b)))


  expect_silent(
    proj_trans(cbind(NA_real_, NA_real_),
      target = "EPSG:4326",
      source = "+proj=laea +datum=WGS84 +type=crs"
    )
  )

  expect_silent(
    proj_trans(cbind(c(1, NA_real_, NaN), c(1e6, NA_real_, NaN)),
      target = "EPSG:4326",
      source = "+proj=laea +datum=WGS84 +type=crs"
    )
  )
})
