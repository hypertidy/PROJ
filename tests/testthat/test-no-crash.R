x <- cbind(c(100.25, 100.75, 101.25, 101.75, 102.25, 102.75),
           100.25)


source <-  "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
target <- "+proj=merc +datum=WGS84"


test_that("out of bounds works", {
  skip_if_not(ok_proj6())
  a <- expect_output({

    proj_trans_generic(x, target, source = source)

  })

  expect_equal(unique(a$z_), 0)
})
