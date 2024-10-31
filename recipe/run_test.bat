@echo on

:: First tell Qt we don't have a display
set QT_QPA_PLATFORM=offscreen

qgis --version
if errorlevel 1 exit /b 1
qgis_process --version
if errorlevel 1 exit /b 1

:: Check Python API -- paths should be OK from activate script
%PYTHON% -c "import qgis.core"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.gui"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.utils"
if errorlevel 1 exit /b 1

:: Test actual use of Python API
python test_py_qgis.py
if errorlevel 1 exit /b 1
