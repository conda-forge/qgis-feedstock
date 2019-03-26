@REM Store existing QGIS env vars and set to this conda env
@REM so other QGIS installs don't pollute the environment

:: Path to QGIS install
@if defined QGIS_PREFIX_PATH (
    @set "_CONDA_QGIS_PREFIX_PATH=%QGIS_PREFIX_PATH%"
)
@set "QGIS_PREFIX_PATH=%CONDA_PREFIX:\=/%/Library"

:: Path to QGIS Python bindings
@if defined PYTHONPATH (
    @set "_CONDA_PYTHONPATH=%PYTHONPATH%"
)
@set "PYTHONPATH=%CONDA_PREFIX%\Library\python;%PYTHONPATH%"
@set "PYTHONPATH=%CONDA_PREFIX%\Library\python\plugins;%PYTHONPATH%"

:: Qt plugins might not be built by QGIS
@if defined QT_PLUGIN_PATH (
    @set "_CONDA_QT_PLUGIN_PATH=%QT_PLUGIN_PATH%"
)
@set "QT_PLUGIN_PATH=%CONDA_PREFIX%\Library\plugins;%QT_PLUGIN_PATH%"
@set "QT_PLUGIN_PATH=%CONDA_PREFIX%\Library\qtplugins;%QT_PLUGIN_PATH%"
