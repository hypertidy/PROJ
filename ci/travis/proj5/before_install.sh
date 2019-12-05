#!/bin/sh

# set -e
#
# export chroot="$PWD"/bionic
# mkdir -p "$chroot$PWD"

export hr="$PWD"

#sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable --yes

sudo apt-get update
sudo apt-get upgrade
#sudo apt-get install -y libgdal-dev libproj-dev

wget http://download.osgeo.org/proj/proj-5.2.0.tar.gz
(mv proj* /tmp; cd /tmp; tar xzf proj-5.2.0.tar.gz)
(cd /tmp/proj-5.2.0; ./configure; make; sudo make install; sudo ldconfig)

cd $hr

