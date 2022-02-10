#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import re
from pathlib import Path

# External imports
import pandas as pd

# Internal imports
from .common import isZFile

#------------------- Constants ------------------------------#

GTF = 'GTF'
GFF = 'GFF'

#------------------- Public Classes & Functions -------------#

def read(*filepaths, **kwargs):
    fDbs  = (_readFile(f, **kwargs) for f in filepaths)
    return fDbs

#------------------- Private Classes & Functions ------------#

def _readFile(filepath, **kwargs):
    if (isZFile(filepath)):
        stem    = Path(filepath).stem
        gxfType = _getFormat(stem)

    else:
        gxfType = _getFormat(filepath)

    fDb = _getFeatureDB(filepath, gxfType, **kwargs)
    return fDb

def _getFormat(filepath):
    if (filepath.endswith('.gtf')):
        return GTF

    elif (filepath.endswith('.gff') \
          or filepath.endswith('.gff3')):
        return GFF

    else:
        raise NotImplementedError("Unknown GXF file")

def _getFeatureDB(filepath, gxfType, **kwargs):
    asPdf = kwargs.pop('asPdf', True)
    attrs = kwargs.pop('attrs', [])
    fDb   = None
    if (asPdf):
        ## Create DataFrame of the file
        colNames = ['seqname', 'source', 'feature', 'start',
                    'end', 'score', 'strand', 'frame', 'attribute']
        mDf      = pd.read_csv(filepath, sep='\t', comment='#',
            header=None, names=colNames, low_memory=False)

        ## Parse the attributes column
        f   = lambda x: _parseAttributes(x, gxfType, attrs)
        aDf = mDf['attribute'].apply(f)

        ## Join the tables and adjust column types
        fDb = pd.concat([mDf, aDf], axis=1)
        fDb['start'] = fDb['start'].astype(int)
        fDb['end']   = fDb['end'].astype(int)

    else:
        import gffutils             ## Requires python 3.5; not 3.7
        fDb = gffutils.create_db(filepath,
            ':memory:', force=True, keep_order=True,
            merge_strategy='merge', sort_attribute_values=True)

        fDb.update(fDb.create_introns())

    return fDb

def _parseAttributes(row, gxfType, attrs):
    if (gxfType == GFF):
        l = dict(x.split('=') for x in row.split(';'))

    else:
        l = {}
        for x in row.split('; '):
            m = re.match('(.*) "(.*)"', x)
            k = m.group(1)
            v = m.group(2)
            l[k] =v

    l = pd.Series(l)
    if (len(attrs) != 0):
        colsToRemove = set(l.index).difference(attrs)
        l = l.drop(colsToRemove)

    return l

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
