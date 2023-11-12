test_that("version string works", {
  skip_if(!ok_proj6())
  expect_silent(version <- proj_version())
  cat(sprintf("\n\nPROJ VERSION IS: %s\n\n", version))
})
