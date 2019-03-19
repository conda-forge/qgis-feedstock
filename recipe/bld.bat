
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

set "CMAKE_COMPILER_PATH=%VSINSTALLDIR:\=/%/VC/bin/amd64"

cmake -G Ninja ^
    -D CMAKE_CXX_COMPILER="%CMAKE_COMPILER_PATH%/cl.exe" ^
    -D CMAKE_C_COMPILER="%CMAKE_COMPILER_PATH%/cl.exe" ^
    -D CMAKE_LINKER="%CMAKE_COMPILER_PATH%/link.exe" ^
    -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D WITH_GUI=TRUE ^
    -D ENABLE_TESTS=FALSE ^
    -D WITH_BINDINGS=TRUE ^
    -D WITH_3D=FALSE ^
    -D WITH_DESKTOP=TRUE ^
    -D WITH_SERVER=FALSE ^
    -D WITH_CUSTOM_WIDGETS=TRUE ^
    -D WITH_GRASS=FALSE ^
    -D WITH_STAGED_PLUGINS=TRUE ^
    -D WITH_QSPATIALITE=FALSE ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

:: Package up a bit. See,
:: OSGEO4W wiki: https://trac.osgeo.org/osgeo4w/wiki/PackagingInstructions
:: List of variables: https://github.com/qgis/QGIS/blob/master/ms-windows/osgeo4w/qgis.vars
:: QGIS "qgis.env" parser: https://github.com/qgis/QGIS/blob/release-3_4/src/app/mainwin.cpp
::
:: Copy `qgis.vars` so we can generate `qgis.env`
:: The `qgis.env` will be generated in post-link.bat script
copy %SRC_DIR%\ms-windows\osgeo4w\qgis.vars %LIBRARY_PREFIX%\bin\qgis.vars
if errorlevel 1 exit 1

:: Copy activate/deactivate scripts
set "ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d"
set "DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d"
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\qgis-activate.bat
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\qgis-deactivate.bat
if errorlevel 1 exit 1
