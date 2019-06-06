## code to prepare `DATASET` dataset goes here
xymap <- quadmesh::xymap

xymap <- xymap[seq(1, nrow(xymap), by = 15), ]

usethis::use_data(xymap)
