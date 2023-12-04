test_that("create works", {
    wkt2 <- proj_crs_text("+proj=longlat +datum=WGS84 +no_defs +type=crs")

  expect_true( grepl("^\\+proj=longlat", proj_crs_text(wkt2, format = 1)))


})
