echo on
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

:: Point qmake at qt6-main's mkspecs directly; QMAKESPEC bypasses qt.conf
:: resolution entirely. https://doc.qt.io/qt-6/qmake-environment-reference.html
set "QT_CONF_PATH=%PREFIX%\qt6.conf"
set "QMAKESPEC=%PREFIX%\Library\lib\qt6\mkspecs\win32-msvc"

echo QT_CONF_PATH=%QT_CONF_PATH%
if exist "%QT_CONF_PATH%" (type "%QT_CONF_PATH%") else (echo QT_CONF_PATH file NOT FOUND)
echo QMAKESPEC=%QMAKESPEC%
if exist "%QMAKESPEC%" (echo QMAKESPEC dir exists) else (echo QMAKESPEC dir NOT FOUND)

:: qt6-main's own build (this Qt6 was configured with the "thread" QT_CONFIG
:: feature on, per mkspecs/qconfig.pri) makes qt.prf add CONFIG += thread to
:: every project, and sip-build's generated .pro files end up trying to load
:: it. But qtbase's mkspecs only ships mkspecs/features/unix/thread.prf --
:: there's no win32 (or platform-agnostic) thread.prf, so qmake fails with
:: "Project ERROR: Could not find feature thread" on Windows. An empty
:: thread.prf is a safe no-op stand-in (mirrors what a platform not needing
:: extra pthread-style flags would ship).
::
:: Writing it into %PREFIX%\Library\lib\qt6\mkspecs\features alone was not
:: enough: qmake only searches the features dirs under its own QT_HOST_DATA
:: mkspecs root (from qt.conf), which isn't necessarily that dir. So put
:: the stub in a dir we own and hand it to qmake through the QMAKEFEATURES
:: env var, which qmake always adds to its feature search path. ninja ->
:: sip-build -> qmake inherit it.
set "QT_QMAKE=%PREFIX%\Library\lib\qt6\bin\qmake.exe"
"%QT_QMAKE%" -query
set "QGIS_QMAKE_FEATURES=%SRC_DIR%\qmake_features"
mkdir "%QGIS_QMAKE_FEATURES%"
type nul > "%QGIS_QMAKE_FEATURES%\thread.prf"
if errorlevel 1 exit 1
set "QMAKEFEATURES=%QGIS_QMAKE_FEATURES%"
echo QMAKEFEATURES=%QMAKEFEATURES%

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
    -D LazPerf_INCLUDE_DIR=%LIBRARY_INC% ^
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
