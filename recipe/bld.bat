echo on
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

:: qt6-main ships two identical qmake binaries. The Qt6::qmake CMake target
:: points at Library\lib\qt6\bin\qmake.exe, which has no qt.conf beside it,
:: so its QT_HOST_DATA is wrong: qconfig.pri is never loaded and sip-build's
:: qmake step fails with "Could not find feature thread". Library\bin\qmake6.exe
:: has a qt6.conf (relocated by conda on install) next to it, so use that one
:: (needs 0010-allow-qmake-executable-override.patch).
set "QGIS_QMAKE=%LIBRARY_BIN%\qmake6.exe"
"%QGIS_QMAKE%" -query QT_HOST_DATA
if errorlevel 1 exit 1

:: Workaround for this lib being required but not set in cmake
:: (Seems maybe it used to be?)
set _LINK_=Ws2_32.lib

cmake -G Ninja ^
    -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D PYTHON3_EXECUTABLE=%PYTHON% ^
    -D Python3_EXECUTABLE=%PYTHON% ^
    -D Python_EXECUTABLE=%PYTHON% ^
    -D QMAKE_EXECUTABLE=%QGIS_QMAKE% ^
    -D PYUIC_PROGRAM=%PREFIX%\pyuic6.bat ^
    -D PYRCC_PROGRAM=%PREFIX%\pyrcc6.bat ^
    -D WITH_GUI=TRUE ^
    -D ENABLE_TESTS=FALSE ^
    -D WITH_BINDINGS=TRUE ^
    -D WITH_3D=TRUE ^
    -D WITH_DESKTOP=TRUE ^
    -D WITH_SERVER=FALSE ^
    -D WITH_CUSTOM_WIDGETS=TRUE ^
    -D WITH_GRASS=FALSE ^
    -D WITH_STAGED_PLUGINS=TRUE ^
    -D WITH_QSPATIALITE=FALSE ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    -D WITH_QTWEBENGINE=TRUE ^
    -D QGIS_INSTALL_SYS_LIBS=FALSE ^
    -D WITH_PDAL=TRUE ^
    -D WITH_EPT=TRUE ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

:: Copy activate/deactivate scripts
set "ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d"
set "DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d"
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

:: For batch
copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\qgis-activate.bat
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\qgis-deactivate.bat
if errorlevel 1 exit 1

:: For Cygwin
copy %RECIPE_DIR%\scripts\activate.sh %ACTIVATE_DIR%\qgis-activate.sh
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\deactivate.sh %DEACTIVATE_DIR%\qgis-deactivate.sh
if errorlevel 1 exit 1
