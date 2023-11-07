test_that("version string works", {
  expect_silent(version <- proj_version())
  cat(sprintf("\n\nPROJ VERSION IS: %s\n\n", version))
})
