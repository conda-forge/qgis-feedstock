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
  
  # Stolen from PyQt feedstock - sip always looks for g++ it seems
  ln -s ${GXX} g++ || true
  ln -s ${GCC} gcc || true
  ln -s ${GCC_AR} gcc-ar || true
  chmod +x g++ gcc gcc-ar
  export PATH=${PWD}:${PATH}
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    # ensure we find the correct pkg-config during cross compilation
    export PKG_CONFIG=${BUILD_PREFIX}/bin/pkg-config
    export BISON_ROOT=${BUILD_PREFIX}
    export FLEX_ROOT=${BUILD_PREFIX}
    # hide this so we get the arm libs but x86 protoc
    rm ${PREFIX}/bin/protoc
    rm ${PREFIX}/bin/pdal
    rm ${PREFIX}/bin/sip-build ${BUILD_PREFIX}/bin/sip-build
    # to find m4
    export M4=${BUILD_PREFIX}/bin/m4
    
    # make our own sip-build with correct settings (uses PATH set above)
    SITE_PKGS_PATH=$($PREFIX/bin/python -c 'import site;print(site.getsitepackages()[0])')
    echo "#!/bin/bash" > sip-build
    echo "$BUILD_PREFIX/bin/python -m sipbuild.tools.build --target-dir $SITE_PKGS_PATH \$@" >> sip-build
    chmod +x sip-build
    cat sip-build
fi

# TODO: enable QSPATIALITE on OSX
cmake ${CMAKE_ARGS} \
    -G Ninja \
    -D CMAKE_BUILD_TYPE=Debug \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D CMAKE_PREFIX_PATH="${PREFIX}" \
    -D PYTHON_EXECUTABLE="${PYTHON}" \
    -D ENABLE_TESTS=FALSE \
    -D WITH_BINDINGS=TRUE \
    -D WITH_3D=TRUE \
    -D WITH_DESKTOP=TRUE \
    -D WITH_SERVER=FALSE \
    -D WITH_GRASS=FALSE \
    -D WITH_STAGED_PLUGINS=TRUE \
    -D WITH_CUSTOM_WIDGETS=TRUE \
    -D EXPAT_INCLUDE_DIR=$PREFIX/include \
    -D EXPAT_LIBRARY=$PREFIX/lib/libexpat${SHLIB_EXT} \
    -D WITH_PY_COMPILE=FALSE \
    -D WITH_QTWEBKIT=TRUE \
    -D WITH_PDAL=TRUE \
    -D WITH_EPT=TRUE \
    -D LazPerf_INCLUDE_DIR=$PREFIX/include \
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
