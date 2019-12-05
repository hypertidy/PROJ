#!/bin/sh

# set -e
#
# export chroot="$PWD"/bionic
# mkdir -p "$chroot$PWD"

export hr="$PWD"


sudo apt-get update
sudo apt-get upgrade

wget https://download.osgeo.org/proj/proj-4.9.3.tar.gz
(mv proj* /tmp; cd /tmp; tar xzf proj-4.9.3.tar.gz)
(cd /tmp/proj-4.9.3; ./configure; make; sudo make install; sudo ldconfig)

cd $hr

