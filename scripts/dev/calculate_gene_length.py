#!/bin/python

#------------------- Description & Notes --------------------#

## Requires GFF File

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports
import pandas as pd

# Internal imports
from src import io
from src.util import params

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def calculateGeneLength(gxfDf):
    ## Get all genes
    cond  = (gxfDf['feature'] == 'gene')
    gDf   = gxfDf[cond][['start', 'end', 'ID', 'biotype']]
    gDf['length'] = gDf['end'] - gDf['start'] + 1
    lenDf = gDf[['ID', 'biotype', 'length']]
    return lenDf

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--gxf", help="GFF file",
        nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--outputfile", help="Output file",
        nargs=1, required=True)
    args = argParser.parse_args()

    gxfFile = args.gxf[0]
    oFile   = args.outputfile[0]

    ## **********
    ## *** Run - Calculate length of each transcript
    ## **********
    gxfDf = list(io.gxf.read(gxfFile))[0]
    lenDf = calculateGeneLength(gxfDf)
    lenDf.to_csv(oFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
