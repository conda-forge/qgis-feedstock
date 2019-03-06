@echo on

:: Check for QGIS executable and shortcut
if not exist "%LIBRARY_PREFIX%\qgis\bin\qgis-bin.exe" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\qgis.bat" exit /b 1

:: Check Python API -- paths should be OK from activate script
:: TODO: fix the activate/deactivate scripts so the above is true

set "PATH=%LIBRARY_PREFIX%\qgis\bin;%PATH%"

%PYTHON% -c "import qgis.core"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.gui"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.utils"
if errorlevel 1 exit /b 1
