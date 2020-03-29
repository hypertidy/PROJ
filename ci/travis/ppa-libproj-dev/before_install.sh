#!/bin/sh

# set -e
#
# export chroot="$PWD"/bionic
# mkdir -p "$chroot$PWD"

export hr="$PWD"

#sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable --yes

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install sqlite3 libsqlite3-dev libproj-dev

# cd /tmp
#
# git clone https://github.com/OSGeo/PROJ.git
# (cd PROJ; ./autogen.sh;  ./configure; make; sudo make install; sudo ldconfig)
#
# cd $hr

