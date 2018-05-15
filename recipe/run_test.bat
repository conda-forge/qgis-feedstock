
set PYTHONPATH=%LIBRARY_PREFIX%\share\qgis\python;%PYTHONPATH%

%PYTHON% -c 'import qgis.core'
if errorlevel 1 exit 1
%PYTHON% -c 'import qgis.utils'
if errorlevel 1 exit 1
