#!/bin/bash

# Store existing QGIS env vars and set to this conda env
# so other QGIS installs don't pollute the environment
if [[ -n "$QGIS_PREFIX_PATH" ]]; then
    export _CONDA_SET_QGIS_PREFIX_PATH=$QGIS_PREFIX_PATH
fi
if [[ -n "$PYTHONPATH" ]]; then
    export _CONDA_SET_PYTHONPATH=$PYTHONPATH
fi
if [[ -n "$QT_PLUGIN_PATH" ]]; then
    export _CONDA_SET_QT_PLUGIN_PATH=$QT_PLUGIN_PATH
fi

if [ -d $CONDA_PREFIX/share/qgis/python ]; then
    # Linux only needs to be able to find Python packages
    export PYTHONPATH="$CONDA_PREFIX/share/qgis/python:$PYTHONPATH"
    export PYTHONPATH="$CONDA_PREFIX/share/qgis/python/plugins:$PYTHONPATH"
    if [ -d $CONDA_PREFIX/QGIS.app ]; then
        # OSX also needs these
        export QGIS_PREFIX_PATH="$CONDA_PREFIX"
        export QT_PLUGIN_PATH="$CONDA_PREFIX/plugins:$QT_PLUGIN_PATH"
    fi
elif [ -d $CONDA_PREFIX/Library/python ]; then
    # On Windows
    # See: https://github.com/qgis/QGIS/blob/master/ms-windows/osgeo4w/qgis.vars
    export QGIS_PREFIX_PATH=$CONDA_PREFIX/Library
    export PYTHONPATH="$CONDA_PREFIX/Library/python:$PYTHONPATH"
    export PYTHONPATH="$CONDA_PREFIX/Library/python/plugins:$PYTHONPATH"
    export QT_PLUGIN_PATH="$CONDA_PREFIX/Library/plugins:$QT_PLUGIN_PATH"
    export QT_PLUGIN_PATH="$CONDA_PREFIX/Library/qtplugins;$QT_PLUGIN_PATH"
fi
