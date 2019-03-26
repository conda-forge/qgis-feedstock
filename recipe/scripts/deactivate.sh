#!/bin/bash
# Restore previous QGIS env var if it exists

unset QGIS_PREFIX_PATH
if [[ -n "$_CONDA_SET_QGIS_PREFIX_PATH" ]]; then
    export QGIS_PREFIX_PATH="$_CONDA_SET_QGIS_PREFIX_PATH"
    unset _CONDA_SET_QGIS_PREFIX_PATH
fi

unset PYTHONPATH
if [[ -n "$_CONDA_SET_PYTHONPATH" ]]; then
    export PYTHONPATH="$_CONDA_SET_PYTHONPATH"
    unset _CONDA_SET_PYTHONPATH
fi

if [[ -n "$_CONDA_SET_QT_PLUGIN_PATH" ]]; then
    export QT_PLUGIN_PATH="$_CONDA_SET_QT_PLUGIN_PATH"
    unset _CONDA_SET_QT_PLUGIN_PATH
fi

unset QGIS_BUNDLE
if [[ -n "$_CONDA_SET_QGIS_BUNDLE" ]]; then
    export QGIS_BUNDLE="$_CONDA_SET_QGIS_BUNDLE"
    unset _CONDA_SET_QGIS_BUNDLE
fi
