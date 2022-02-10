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

def calculateTranscriptLength(gxfDf):
    ## Get all exons
    cond = (gxfDf['feature'] == 'exon')
    eDf  = gxfDf[cond][['start', 'end', 'Parent']]
    eDf['length'] = eDf['end'] - eDf['start'] + 1
    eDf  = eDf[['Parent', 'length']]
    eDf  = eDf.rename(columns={'Parent':'ID'})

    ## Calculate the length of each transcript
    ## (based on the sum of the exon lengths)
    lenDf = eDf.groupby('ID').agg(sum).reset_index()

    ## Get all transcripts and join the tables
    cond  = ((~pd.isna(gxfDf['ID']))
             & (gxfDf['ID'].str.contains('transcript')))
    tDf   = gxfDf[cond][['ID', 'biotype']]
    lenDf = tDf.merge(lenDf, how='left', on='ID')
    return lenDf

def calculateExonCount(gxfDf):
    ## Get all exons
    cond = (gxfDf['feature'] == 'exon')
    eDf  = gxfDf[cond][['start', 'end', 'Parent']]

    ## Calculate the number of exons for each transcript 
    eCountDf = eDf.groupby('Parent').count().reset_index()
    eCountDf = eCountDf[['Parent', 'start']]
    eCountDf = eCountDf.rename(columns={'Parent':'ID', 'start':'exonCount'})
    return eCountDf

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
    ## *** Run - Calculate length and number of exons of each transcript
    ## **********
    gxfDf = list(io.gxf.read(gxfFile))[0]
    lenDf = calculateTranscriptLength(gxfDf)
    eDf   = calculateExonCount(gxfDf)
    df    = lenDf.merge(eDf, on='ID', how='left')
    df.to_csv(oFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
