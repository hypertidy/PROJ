test_that("create works", {
  testthat::skip_if(!ok_proj6())
    wkt2 <- proj_crs_text("+proj=longlat +datum=WGS84 +no_defs +type=crs")

  expect_true( grepl("^\\+proj=longlat", proj_crs_text(wkt2, format = 1)))


})

test_that("failure is graceful", {
  ## we *do not* have PROJ lib, so we get NA
   skip_if(ok_proj6())
   expect_true(is.na(proj_crs_text("+proj=longlat", format = 1L)))
   }
)
