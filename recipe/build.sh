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
  PLATFORM_OPTS="-D WITH_QSPATIALITE=FALSE -D QGIS_MACAPP_FRAMEWORK=FALSE"
else
  # Needed to find libGL.so
  export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${BUILD_PREFIX}/${HOST}/sysroot"
  PLATFORM_OPTS=""
fi

# TODO: enable QSPATIALITE on OSX
cmake \
    -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D CMAKE_PREFIX_PATH="${PREFIX}" \
    -D WITH_3D=TRUE \
    -D WITH_DESKTOP=TRUE \
    -D WITH_SERVER=FALSE \
    -D WITH_GRASS=FALSE \
    -D WITH_PDAL=TRUE \
    -D BINDINGS_GLOBAL_INSTALL=TRUE \
    -D WITH_QWTPOLAR=TRUE \
    -D QWTPOLAR_LIBRARY=${PREFIX}/lib/libqwt.so \
    -D QWTPOLAR_INCLUDE_DIR=${PREFIX}/include/qwt \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -DQWT_POLAR_VERSION=0x060200" \
    -D WITH_INTERNAL_QWTPOLAR=FALSE \
    $PLATFORM_OPTS \
    ..

ninja -j$CPU_COUNT
ninja install

# QGIS gets bundled as a QGIS.app on MacOS (unless we creeate our own cmake)
# https://github.com/qgis/QGIS/blob/master/mac/readme.txt
if [ $(uname) == Darwin ]; then
  # also create this dir or creating the conda package failes due to broken link
  mkdir -p $PREFIX/QGIS.app/Contents/MacOS/share

  # and create a link into the .app so we can run it.
  ln -s $PREFIX/QGIS.app/Contents/MacOS/QGIS $PREFIX/bin/qgis
fi


# Install activate/deactivate scripts
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/qgis-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/qgis-deactivate.sh
