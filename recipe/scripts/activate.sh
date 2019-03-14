#!/bin/bash

# Store existing QGIS env vars and set to this conda env
# so other QGIS installs don't pollute the environment

if [[ -n "$PYTHONPATH" ]]; then
    export _CONDA_SET_PYTHONPATH=$PYTHONPATH
fi

if [ -d $CONDA_PREFIX/share/qgis/python ]; then
    # On Linux
    export PYTHONPATH="$CONDA_PREFIX/share/qgis/python:$PYTHONPATH"
elif [ -d $CONDA_PREFIX/QGIS.app/Contents/Resources/python ]; then
    # On MacOS
    export PYTHONPATH="$CONDA_PREFIX/QGIS.app/Contents/Resources/python:$PYTHONPATH"
elif [ -d $CONDA_PREFIX/Library/python ]; then
    # On Windows
    export PYTHONPATH="$CONDA_PREFIX/Library/python:$PYTHONPATH"

    # Windows needs more paths...
    if [[ -n "$QGIS_PREFIX_PATH" ]]; then
        export _CONDA_SET_QGIS_PREFIX_PATH=$QGIS_PREFIX_PATH
    fi
    export QGIS_PREFIX_PATH=$CONDA_PREFIX/Library

    if [[ -n "$QT_PLUGIN_PATH" ]]; then
        export _CONDA_SET_QT_PLUGIN_PATH=$QT_PLUGIN_PATH
    fi
    export QT_PLUGIN_PATH="$CONDA_PREFIX/Library/plugins:$CONDA_PREFIX/Library/qtplugins;$QT_PLUGIN_PATH"
fi
