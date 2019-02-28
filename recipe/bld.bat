
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

cmake -G Ninja ^
    -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D WITH_GUI=FALSE ^
    -D ENABLE_TESTS=FALSE ^
    -D WITH_BINDINGS=ON ^
    -D WITH_3D=OFF ^
    -D WITH_DESKTOP=OFF ^
    -D WITH_SERVER=OFF ^
    -D WITH_GRASS=OFF ^
    -D WITH_STAGED_PLUGINS=OFF ^
    -D WITH_QSPATIALITE=OFF ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
