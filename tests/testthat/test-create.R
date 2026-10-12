test_that("create works", {
    wkt2 <- proj_crs_text("EPSG:4326")

 expect_true( grepl("^\\+proj=longlat", proj_crs_text(wkt2, format = 1)))


})

test_that("proj_crs_text() returns NA with a warning on failure, never crashes", {
  expect_warning(res <- proj_crs_text("this is not a crs"), "cannot create object")
  expect_identical(res, NA_character_)
  expect_warning(res <- proj_crs_text("EPSG:999999999"), "cannot create object")
  expect_identical(res, NA_character_)
})
