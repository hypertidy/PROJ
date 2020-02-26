wkt2 <- proj_create("EPSG:4326")

test_that("multiplication works", {
  expect_equal( proj_create(wkt2, format = 1L),
               "+proj=longlat +datum=WGS84 +no_defs +type=crs")
})
