@echo off

set "LIBRARY_PREFIX=%PREFIX%\Library"

:: Setting OSGEO4W_ROOT turns on --postinstall
set "OSGEO4W_ROOT=%LIBRARY_PREFIX%"

:: Set a few variables to include in export
:: N.B. QGIS_PREFIX_PATH needs to be forward slashed
set "QGIS_PREFIX_PATH=%LIBRARY_PREFIX:\=/%"
:: Add what will be in our PATH once activated
set "PATH=%PREFIX%;%LIBRARY_PREFIX%\mingw-w64\bin;%LIBRARY_PREFIX%\usr\bin;%LIBRARY_PREFIX%\bin;%PATH%"
:: Set locations for Qt and Python QGIS files
set "QT_PLUGIN_PATH=%LIBRARY_PREFIX%\qgis\qtplugins;%LIBRARY_PREFIX%\plugins;%QT_PLUGIN_PATH%"
set "PYTHONPATH=%LIBRARY_PREFIX%\python;%LIBRARY_PREFIX%\python\plugins;%PYTHONPATH%"
:: GIS stack variables
set "GEOTIFF_CSV=%LIBRARY_PREFIX%\share\epsg_csv"
set "GDAL_DATA=%LIBRARY_PREFIX%\share\gdal"
set "PROJ_LIB=%LIBRARY_PREFIX%\share"
:: Probably not needed but...
set "O4W_QT_PREFIX=%LIBRARY_PREFIX%"
set "O4W_QT_BINARIES=%LIBRARY_PREFIX%\bin"
set "O4W_QT_PLUGINS=%LIBRARY_PREFIX%\plugins"
set "O4W_QT_LIBRARIES=%LIBRARY_PREFIX%\lib"
set "O4W_QT_TRANSLATIONS=%LIBRARY_PREFIX%\translations"
set "O4W_QT_HEADERS=%LIBRARY_PREFIX%\include"

:: Generate qgis.env with the above variables
%LIBRARY_PREFIX%\bin\qgis.exe --postinstall
