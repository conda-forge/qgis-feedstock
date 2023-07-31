#!/bin/bash

# exit when any command fails
set -e
# print all commands
set -x

# Testing QGIS command currently is found as lint in meta.yaml
# QGIS has no --version, and --help exists 2
qgis --help || [[ "$?" == "2" ]]

# Check Python API -- paths should be OK from activate script
python -c 'import qgis.core'
python -c 'import qgis.gui'
python -c 'import qgis.utils'

# Test actual use of Python API
# First tell Qt we don't have a display
export QT_QPA_PLATFORM=offscreen


if [ $(uname) == Darwin ]; then

    sudo mv /usr/local/conda_mangled/* /usr/local/
    /usr/local/Homebrew/bin/brew tap LouisBrunner/valgrind
    /usr/local/Homebrew/bin/brew install --HEAD LouisBrunner/valgrind/valgrind

    ulimit -n 1024
    valgrind python test_py_qgis.py
else
    python test_py_qgis.py
fi
