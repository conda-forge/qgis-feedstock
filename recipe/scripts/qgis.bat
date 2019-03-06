:: QGIS application wrapper script
::
:: Template: https://github.com/qgis/QGIS/blob/master/ms-windows/osgeo4w/qgis.bat.tmpl
@echo off
setlocal

set "PATH=%CONDA_PREFIX%\Library\qgis\bin;%PATH%"
set "QGIS_PREFIX_PATH=%CONDA_PREFIX%\Library\qgis"
set "GDAL_FILENAME_IS_UTF8=YES"
rem Set VSI cache to be used as buffer, see #6448
set VSI_CACHE=TRUE
set VSI_CACHE_SIZE=1000000
set "QT_PLUGIN_PATH=%CONDA_PREFIX%\Library\qgis\qtplugins;%CONDA_PREFIX%\Library\plugins"

start "QGIS" /B "%CONDA_PREFIX%\Library\qgis\bin\qgis-bin.exe" %*

endlocal
