@echo off

set "LIBRARY_PREFIX=%PREFIX%\Library"

:: Set a few variables to include in export
set "OSGEO4W_ROOT=%LIBRARY_PREFIX%"
set "QGIS_PREFIX_PATH=%LIBRARY_PREFIX%"
set "QT_PLUGIN_PATH=%LIBRARY_PREFIX%\qgis\qtplugins;%LIBRARY_PREFIX%\plugins;%QT_PLUGIN_PATH%"
set "O4W_QT_PREFIX=%LIBRARY_PREFIX%"
set "O4W_QT_BINARIES=%LIBRARY_PREFIX%\bin"
set "O4W_QT_PLUGINS=%LIBRARY_PREFIX%\plugins"
set "O4W_QT_LIBRARIES=%LIBRARY_PREFIX%\lib"
set "O4W_QT_TRANSLATIONS=%LIBRARY_PREFIX%\translations"
set "O4W_QT_HEADERS=%LIBRARY_PREFIX%\include"

:: Generate qgis.env with the above variables
%LIBRARY_PREFIX%\bin\qgis.exe --postinstall
