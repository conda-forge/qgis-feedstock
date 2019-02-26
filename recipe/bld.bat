
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release


REM -D WITH_INTERNAL_SPATIALITE=FALSE ^
REM -D SPATIALITE_LIBRARY=%LIBRARY_LIB%\spatialite_i.lib ^

cmake -G Ninja ^
    -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D ENABLE_TESTS=FALSE ^
    -D WITH_BINDINGS=ON ^
    -D WITH_3D=OFF ^
    -D WITH_DESKTOP=ON ^
    -D WITH_SERVER=OFF ^
    -D WITH_GRASS=OFF ^
    -D WITH_STAGED_PLUGINS=ON ^
    -D WITH_QSPATIALITE=OFF ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
