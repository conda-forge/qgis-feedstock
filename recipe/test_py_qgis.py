#!/usr/bin/env python
import os
import pathlib
import sys

from qgis.core import \
    QgsApplication, QgsVectorLayer, \
    QgsProjUtils, QgsCoordinateReferenceSystem

fname = os.path.join(os.path.dirname(__file__), 'test_data', 'box.geojson')


def testPROJ():
    """
    Tests if PROJ library can be found
    """
    PROJ_LIB = pathlib.Path(os.environ.get('PROJ_DATA'))
    assert PROJ_LIB.is_dir(), f'PROJ_DATA does not exist: {PROJ_DATA}'
    PROJ_DB = PROJ_LIB / 'proj.db'
    assert PROJ_DB.is_file(), f'proj.db file does not exist: {PROJ_DB}'

    found = False
    for path in QgsProjUtils.searchPaths():
        path = pathlib.Path(path) / 'proj.db'
        if path.is_file():
            found = True
            break
    assert found, f'Unable to find proj.db in QgsProjUtils.searchPaths(): {QgsProjUtils.searchPaths()}'

    wkt = QgsCoordinateReferenceSystem.fromEpsgId(4326).toWkt()
    assert not wkt.startswith('GEOGCS["unknown"')


def test(vector_file):
    vl = QgsVectorLayer(vector_file)
    valid = vl.isValid()
    print('Valid layer?: {valid}'.format(valid=valid))
    if not valid:
        print('Could not even validate the vector file... ')
        print('Printing environment\n')
        for k, v in os.environ.items():
            print('{k}: {v}'.format(k=k, v=v))
        raise Exception("QGIS Python API not functional")
    else:
        nfeat = vl.featureCount()
        print('Feature count?: {nfeat}'.format(nfeat=nfeat))
        assert nfeat == 1


if __name__ == '__main__':
    # Initialize QGIS API -- we shouldn't have to fuss with paths
    app = QgsApplication([], False)
    app.initQgis()
    print('Ran `app.initQgis`')

    try:
        test(fname)
        testPROJ()

    except Exception as e:
        print(e)
        print('QGIS prefixPath(): "{0}"'.format(app.prefixPath()))
        sys.exit(1)

    # Shut down
    app.exitQgis()
    print('Ran `app.exitQgis()`')
