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

# Currently there is a segfault on Linux when exiting Python
# so check for that error code (139) to distinguish from other
# unknown reasons for issues with the build
set +e
python test_py_qgis.py
code=$?
if [[ $code -eq 0 ]]; then
    echo "Passed without a problem"
elif [[ $code -eq 139 ]]; then
    echo "Passed, but segfaulted for a known reason at end of program"
else
    echo "Error with build - exit code $code"
    exit $code
fi
