#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import os
import itertools
from pathlib import Path

# External imports
import pysam

# Internal imports
from .common import isZFile
from .common import createDirIfNone
from .common import removeFileIfExists

#------------------- Constants ------------------------------#

BAM = 'b'
SAM = 's'

#------------------- Public Classes & Functions -------------#

def read(*filepaths, **kwargs):
    alignRecs = [_readRecords(f, **kwargs) for f in filepaths]
    alignRecs = itertools.chain(*alignRecs)
    return alignRecs

def write(filepath, xamRecords, template):
    ## Create DIR if it doesnt exist
    outputDir = os.path.dirname(filepath)
    createDirIfNone(outputDir)
    removeFileIfExists(filepath)

    tFile = _readFile(template)
    f = pysam.AlignmentFile(filepath, 'w', template=tFile)
    for x in xamRecords:
        f.write(x)

    f.close()

#------------------- Private Classes & Functions ------------#

def _readRecords(filepath, **kwargs):
    alignF    = _readFile(filepath)
    alignIter = alignF.fetch(until_eof=True, **kwargs)
    yield from alignIter

def _readFile(filepath):
    if (isZFile(filepath)):
        stem    = Path(filepath).stem
        xamType = _getFormat(stem)

    else:
        xamType = _getFormat(filepath)

    alignF    = pysam.AlignmentFile(filepath, 'r' + xamType)
    return alignF

def _getFormat(filepath):
    if (filepath.endswith('.bam')):
        return BAM

    elif (filepath.endswith('.sam')):
        return ''

    else:
        raise NotImplementedError("Unknown Xam file")

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
