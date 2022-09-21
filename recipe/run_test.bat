@echo on

:: Check for QGIS executable
if not exist "%LIBRARY_PREFIX%\bin\qgis.exe" exit /b 1

:: Check Python API -- paths should be OK from activate script
%PYTHON% -c "import qgis;import qgis.core"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis;import qgis.gui"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis;import qgis.utils"
if errorlevel 1 exit /b 1

:: Test actual use of Python API
:: First tell Qt we don't have a display
set QT_QPA_PLATFORM=offscreen
python test_py_qgis.py
if errorlevel 1 exit /b 1
