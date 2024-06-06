test_that("create works", {
    wkt2 <- proj_crs_text("EPSG:4326")

 expect_true( grepl("^\\+proj=longlat", proj_crs_text(wkt2, format = 1)))


})
