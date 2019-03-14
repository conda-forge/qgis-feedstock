
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
    -D WITH_TOUCH=TRUE ^
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
:: OSGEO4W_ROOT and --postinstall turn on "qgis.env" generation
set "OSGEO4W_ROOT=%LIBRARY_PREFIX%"
:: Set a few variables to include in export
set "QGIS_PREFIX_PATH=%LIBRARY_PREFIX%"
set "QT_PLUGIN_PATH=%LIBRARY_PREFIX%\qgis\qtplugins;%LIBRARY_PREFIX%\plugins;%QT_PLUGIN_PATH%"
set "O4W_QT_PREFIX=%LIBRARY_PREFIX%"
set "O4W_QT_BINARIES=%LIBRARY_PREFIX%\bin"
set "O4W_QT_PLUGINS=%LIBRARY_PREFIX%\plugins"
set "O4W_QT_LIBRARIES=%LIBRARY_PREFIX%\lib"
set "O4W_QT_TRANSLATIONS=%LIBRARY_PREFIX%\translations"
set "O4W_QT_HEADERS=%LIBRARY_PREFIX%\include"

:: Copy qgis.vars
copy %SRC_DIR%\ms-windows\osgeo4w\qgis.vars %LIBRARY_PREFIX%\bin\qgis.vars
if errorlevel 1 exit 1

:: Generate qgis.env
%LIBRARY_PREFIX%\bin\qgis.exe --postinstall
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
