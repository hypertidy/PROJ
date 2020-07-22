w <- xymap
ss <- sample(seq_len(nrow(w)), 100)
lon <- na.omit(w[ss,1])
lat <- na.omit(w[ss,2])
dst <- "+proj=laea +datum=WGS84 +lon_0=147 +lat_0=-42"
llproj <- "+proj=longlat +datum=WGS84"

xy <- cbind(lon, lat)
#xyz <- cbind(lon, lat, 1)
xyzt <- cbind(lon, lat, 1, 0)
test_that("input checks work", {
  if (!ok_proj6()) skip("no PROJ6 available, no real testing to do")

  expect_error(proj_trans_generic(xy), "argument \"target\" is missing, with no default")
  expect_error(proj_trans_generic(xy, dst), "source must be provided as a string")
  expect_error(proj_trans_generic(xy, 1, source = llproj), "target must be a string")
  expect_silent(proj_trans_generic(data.frame(lon, lat), dst, source = llproj))
  expect_error(proj_trans_generic(cbind("a", "b"), dst , source  = llproj),
               "input coordinates must be numeric")

  expect_error(proj_trans_generic(cbind(numeric(0), numeric(0)), dst , source  = llproj),
               "must be at least one coordinate")
  expect_error(proj_trans_generic(matrix(1:3, 3:1)[NA, , drop   = FALSE], dst , source  = llproj),
              "x coordinates must be 2-columns")

  expect_silent(proj_trans_generic(xy, dst, source = llproj))
  expect_silent(proj_trans_generic(xy, z_ = 0, dst, source = llproj))
  expect_silent(proj_trans_generic(xy, z_ = 0, t_ = 1, dst, source = llproj))

  expect_error(proj_trans_generic(cbind(xyzt, 2, 1), dst, source = llproj))

})


test_that("PROJ6 checks work", {
  if (!ok_proj6()) skip("no PROJ6 available, no real testing to do")
  expect_error(proj_trans_generic(xy, "myfave", source = llproj))

  expect_error(proj_trans_generic(xy, llproj, source = "myfave"))
})
