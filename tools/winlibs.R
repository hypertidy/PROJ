# Download libproj binaries
VERSION <- commandArgs(TRUE)
if(!file.exists(sprintf("../windows/proj-%s/include/proj.h", VERSION))){
  download.file(sprintf("https://github.com/rwinlib/proj/archive/v%s.zip", VERSION),
                "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}
