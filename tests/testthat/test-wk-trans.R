test_that("proj_trans_create() works", {
  expect_type(proj_trans_create("OGC:CRS84", "EPSG:3857"), "externalptr")
  expect_s3_class(proj_trans_create("OGC:CRS84", "EPSG:3857"), "proj_trans")
})

test_that("proj_trans print method works", {
  crs_to_crs <- proj_trans_create("OGC:CRS84", "EPSG:3857")
  str <- capture_output(print(crs_to_crs))

  expect_match(str, "<proj_trans at .*>")
  expect_match(str, "source_crs=OGC:CRS84", fixed = TRUE)
  expect_match(str, "target_crs=EPSG:3857", fixed = TRUE)
})

test_that("proj_trans print doesn't crash on invalid input", {
  nullptr <- new("externalptr")
  null_trans <- wk::new_wk_trans(nullptr, "proj_trans")

  expect_error(.Call(C_proj_trans_fmt, NULL))
  expect_error(.Call(C_proj_trans_fmt, nullptr))
  expect_error(.Call(C_proj_trans_fmt, null_trans))
})

test_that("proj_trans_create() doesn't crash on invalid input", {
  expect_error(proj_trans_create(1, 2))
  expect_error(proj_trans_create("OGC:CRS84", 2))

  expect_error(proj_trans_create(4326, "", logical(), logical(2)))
  expect_error(proj_trans_create("", 4326, TRUE, logical(2)))
  expect_error(proj_trans_create(4326, 4326, "", TRUE))
  expect_error(proj_trans_create(4326, 4326, NA, 1))
})

test_that("wk_transform() works", {
  fwd <- wk::wk_transform(wk::xy(-5:5, -5:5), proj_trans_create("OGC:CRS84", "EPSG:3857"))
  inv <- wk::wk_transform(fwd, proj_trans_create("EPSG:3857", "OGC:CRS84"))

  expect_equal(inv, wk::xy(-5:5, -5:5))

  expect_equal(
    wk::wk_transform(wk::xy(1, 1), proj_trans_create("OGC:CRS84", "EPSG:3857")),
    wk::xy(111319.4908, 111325.1429)
  )
})

test_that("proj_trans_create() is normalised", {
  pts <- wk::xy(-10:10, 10:-10)
  expect_equal(
    # no coord flip
    wk::wk_transform(pts, proj_trans_create("EPSG:4326", "OGC:CRS84")),
    pts
  )
})

test_that("transform() handles NA & NaN", {
  # NaN z & m won't cause NaN results
  expect_equal(
    wk::wk_transform(
      wk::xy(1:3, 1:3),
      proj_trans_create("OGC:CRS84", "OGC:CRS84")
    ),
    wk::xy(1:3, 1:3)
  )

  # treat NA and NaN separately
  expect_equal(
    wk::wk_transform(
      wk::xyzm(1, 1, NA, NaN),
      proj_trans_create("OGC:CRS84", "OGC:CRS84")
    ),
    wk::xyzm(1, 1, NA, NaN)
  )

  # 9.2 behaviour: x and y must be both non NaN
  expect_equal(
    wk::wk_transform(
      wk::xyzm(c(NaN, NaN, NA, NA), c(NaN, NA, NaN, NA), 0, 0),
      proj_trans_create("OGC:CRS84", "OGC:CRS84")
    ),
    rep.int(wk::xyzm(NaN, NaN, NaN, NaN), 4)
  )
})

test_that("wk_trans_inverse() works", {
  inv <- wk::wk_trans_inverse(proj_trans_create("EPSG:3857", "OGC:CRS84"))
  rev <- proj_trans_create("OGC:CRS84", "EPSG:3857")

  expect_equal(
    wk::wk_transform(
      wk::xy(-5:5, -5:5),
      inv
    ),
    wk::wk_transform(
      wk::xy(-5:5, -5:5),
      rev
    )
  )

  expect_equal(
    wk::wk_transform(wk::xy(1, 1), inv),
    wk::xy(111319.4908, 111325.1429)
  )
})

test_that("inverse(proj_trans) print method works", {
  crs_to_crs <- wk::wk_trans_inverse(proj_trans_create("OGC:CRS84", "EPSG:3857"))
  str <- capture_output(print(crs_to_crs))

  expect_match(str, "<proj_trans at .*>")
  expect_match(str, "target_crs=OGC:CRS84", fixed = TRUE)
  expect_match(str, "source_crs=EPSG:3857", fixed = TRUE)
})
