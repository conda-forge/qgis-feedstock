#!/usr/bin/env python
import os, sys

from qgis.core import QgsApplication, QgsProcessingFeedback, QgsVectorLayer

fname = os.path.join(os.path.dirname(__file__), 'test_data', 'box.geojson')


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


def test_srs_db():
    # test if the srs.db can be found
    # see https://github.com/conda-forge/qgis-feedstock/issues/107 for details

    app = QgsApplication.instance()
    assert isinstance(app, QgsApplication)

    # import re
    # app.setPkgDataPath(re.sub(r'(/envs/[^/]+)/\.$', r'\1/Library', app.pkgDataPath()))

    assert os.path.isfile(app.srsDatabaseFilePath()) , \
        'QgsApplication::srsDatabaseFilePath() does not exist: {}'.format(app.srsDatabaseFilePath())

    assert os.path.isdir(app.iconsPath()), \
        'QgsApplication::iconsPath() directory does not exist: {}'.format(app.iconsPath())



if __name__ == '__main__':
    # Initialize QGIS API -- we shouldn't have to fuss with paths
    app = QgsApplication([], False)
    app.initQgis()
    print('Ran `app.initQgis`')

    try:
        test(fname)
        test_srs_db()
    except Exception as e:
        print(e)
        print('QGIS prefixPath(): "{0}"'.format(app.prefixPath()))
        sys.exit(1)

    # Shut down
    app.exitQgis()
    print('Ran `app.exitQgis()`')
