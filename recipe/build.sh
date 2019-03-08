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
  PLATFORM_OPTS="-D WITH_THREAD_LOCAL=FALSE -D QGIS_MACAPP_BUNDLE=0 -D WITH_QSPATIALITE=FALSE"
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
    -D PYTHON_EXECUTABLE="${PYTHON}" \
    -D ENABLE_TESTS=TRUE \
    -D WITH_BINDINGS=TRUE \
    -D WITH_3D=FALSE \
    -D WITH_DESKTOP=TRUE \
    -D WITH_SERVER=FALSE \
    -D WITH_GRASS=FALSE \
    -D WITH_STAGED_PLUGINS=TRUE \
    -D WITH_CUSTOM_WIDGETS=TRUE \
    -D EXPAT_INCLUDE_DIR=$PREFIX/include \
    -D EXPAT_LIBRARY=$PREFIX/lib/libexpat${SHLIB_EXT} \
    -D WITH_PY_COMPILE=FALSE \
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
