
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake -G Ninja ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D ENABLE_TESTS=TRUE ^
    -D WITH_BINDINGS=ON ^
    -D WITH_3D=OFF ^
    -D WITH_DESKTOP=ON ^
    -D WITH_SERVER=OFF ^
    -D WITH_GRASS=OFF ^
    -D WITH_STAGED_PLUGINS=ON ^
    -D WITH_QSPATIALITE=ON ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
