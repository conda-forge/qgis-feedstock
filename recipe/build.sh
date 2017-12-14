#!/usr/bin/env bash

# NOTES:
# src/app/main.cpp has specific logic for handling QT_PLUGIN_PATH on
# win/osx but not linux. See ticket from homebrew-osgeo4mac for
# related information
# https://github.com/OSGeo/homebrew-osgeo4mac/issues/27
#
# Installation instructions:
#   https://github.com/qgis/QGIS/blob/master/INSTALL
# Prior art:
#   https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=qgis

# BUILD
[[ -d build ]] || mkdir build
cd build/

# Defining these allows QGIS cmake files to find most of the libraries
export CMAKE_PREFIX_PATH=${PREFIX}
export CMAKE_PREFIX=${PREFIX}

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_TESTS=FALSE \
      -D PYTHON_EXECUTABLE:PATH=${PYTHON} \
      -D WITH_PYSPATIALITE:BOOL=ON \
      -D WITH_QSPATIALITE:BOOL=ON \
      -D EXPAT_INCLUDE_DIR=$PREFIX/include \
      -D EXPAT_LIBRARY=$PREFIX/lib/libexpat$SHLIB_EXT \
      -D WITH_INTERNAL_{HTTPLIB2,JINJA2,MARKUPSAFE,OWSLIB,PYGMENTS,DATEUTIL,PYTZ,YAML,NOSE2,SIX,FUTURE}=FALSE \
      $SRC_DIR

make -j$CPU_COUNT
# no make check
make install -j$CPU_COUNT
