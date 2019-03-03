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

# BUILD
[[ -d build ]] || mkdir build
cd build/

# https://github.com/conda-forge/bison-feedstock/issues/7
export M4="${PREFIX}/bin/m4"

echo "Current work directory: $(pwd)"
echo "PREFIX: $PREFIX"

if [ $(uname) == Darwin ]; then
  # disable thread local on OSX as build fails otherwise
  # can remove when we update XCode
  PLATFORM_OPTS="-D WITH_THREAD_LOCAL=OFF -D QGIS_MACAPP_BUNDLE=0 -D WITH_QSPATIALITE:BOOL=OFF"
else
  # Needed to find libGL.so
  export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${BUILD_PREFIX}/${HOST}/sysroot"
  PLATFORM_OPTS=""
fi

# TODO: enable tests
# TODO: enable QSPATIALITE on OSX
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
    -D WITH_CUSTOM_WIDGETS=TRUE \
    -D EXPAT_INCLUDE_DIR=$PREFIX/include \
    -D EXPAT_LIBRARY=$PREFIX/lib/libexpat${SHLIB_EXT} \
    $PLATFORM_OPTS \
    ..

ninja -j$CPU_COUNT
ninja install

if [ $(uname) == Darwin ]; then
  # also create this dir or creating the conda package failes due to broken link
  mkdir -p $PREFIX/QGIS.app/Contents/MacOS/share

  # and create a link into the .app so we can run it.
  # can't easily see how to turn off the app stuff for OSX so we may be stuck with it
  ln -s $PREFIX/QGIS.app/Contents/MacOS/QGIS $PREFIX/bin/qgis
fi
