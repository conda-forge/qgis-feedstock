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
#   Arch AUR: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=qgis
#   QGIS Travis CI: https://github.com/qgis/QGIS/blob/10044fb1ddef990a1f4f7f4dddb20762077525ae/.ci/travis/linux/docker-build-test.sh
#   QGIS Docker build: https://github.com/qgis/QGIS/blob/master/.docker/qgis.dockerfile

# https://github.com/conda-forge/bison-feedstock/issues/7
export M4="${PREFIX}/bin/m4"

# BUILD
[[ -d build ]] || mkdir build
cd build/

if [ $(uname) == Darwin ]; then
  # disable thread local on OSX as build fails otherwise
  # can remove when we update XCode
  THREADLOCAL="-D WITH_THREAD_LOCAL=OFF -D QGIS_MACAPP_BUNDLE=0"

  # also rename this header as it seems to cause problems
  # with system headers
  mv $PREFIX/include/uuid/uuid.h $PREFIX/include/uuid/uuid.h.bak
else
  THREADLOCAL=""
fi

cmake \
    -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D CMAKE_PREFIX_PATH="${PREFIX}" \
    -D PYTHON_EXECUTABLE="${PYTHON}" \
    -D ENABLE_TESTS=TRUE \
    -D WITH_BINDINGS=ON \
    -D WITH_3D=OFF \
    -D WITH_DESKTOP=ON \
    -D WITH_SERVER=OFF \
    -D WITH_GRASS=OFF \
    -D WITH_STAGED_PLUGINS=ON \
    -D WITH_QSPATIALITE=ON \
    -D EXPAT_INCLUDE_DIR=$PREFIX/include \
    -D EXPAT_LIBRARY=$PREFIX/lib/libexpat${SHLIB_EXT} \
    $THREADLOCAL \
    ..

ninja -j$CPU_COUNT
ninja install

if [ $(uname) == Darwin ]; then
  # rename it back
  mv $PREFIX/include/uuid/uuid.h.bak $PREFIX/include/uuid/uuid.h

  # also create this dir or creating the conda package failes due to broken link
  mkdir -p $PREFIX/QGIS.app/Contents/MacOS/share

  # and create a link into the .app so we can run it.
  # can't easily see how to turn off the app stuff for OSX so we may be stuck with it
  ln -s $PREFIX/QGIS.app/Contents/MacOS/QGIS $PREFIX/bin/qgis
fi
