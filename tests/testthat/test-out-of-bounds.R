x <- cbind(c(100.25, 100.75, 101.25, 101.75, 102.25, 102.75),
           100.25)


source <-  "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
target <- "+proj=merc +datum=WGS84"


test_that("out of bounds works", {

  skip_if(!ok_proj6())

  # #here I don't put the expected output because it's (possibly) lib version dependent
  ## ,  "Error detected, some values Inf"
  a <- expect_output({

    proj_trans(x, target, source = source)
  })

  ## fixed
  expect_true(!all(is.finite(a$x_)))


  ## could be
  #"Point outside of projection domain".
  #"Error detected, some values Inf  (ubuntu 20.04)
  expect_output(  proj_trans(cbind(2e10, 2e12),
                                     source = "+proj=stere +datum=WGS84",
                                     target = "+proj=laea +datum=WGS84")
                  )


  expect_true(is.list(  proj_trans(cbind(2e10, 2e12),
                                     source = "+proj=gnom +datum=WGS84",
                                     target = "+proj=laea +datum=WGS84")))

  # crazy stuff is fine
  expect_output(proj_trans(cbind(2e10, 2e12),
                                   source = "+proj=longlat +datum=WGS84",
                                   target = "+proj=laea +datum=WGS84"),
                "Error detected, some values Inf")

  expect_true(all(!is.finite(unlist(proj_trans(cbind(2e10, 2e12),
                                   target = "+proj=longlat +datum=WGS84",
                                   source = "+proj=laea +datum=WGS84")))))

  expect_silent({
    proj_trans(cbind(NA_real_, NA_real_),
                       target = "+proj=longlat +datum=WGS84",
                       source = "+proj=laea +datum=WGS84")

    proj_trans(cbind(c(1, NA_real_), c(1e6, NA_real_)),
                       target = "+proj=longlat +datum=WGS84",
                       source = "+proj=laea +datum=WGS84")
  })
})
