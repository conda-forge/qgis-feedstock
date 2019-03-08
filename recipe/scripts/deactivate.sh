#!/bin/bash
# Restore previous QGIS env var if it exists


unset PYTHONPATH
if [[ -n "$_CONDA_SET_PYTHONPATH" ]]; then
    export PYTHONPATH="$_CONDA_SET_PYTHONPATH"
    unset _CONDA_SET_PYTHONPATH
fi
