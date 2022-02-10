#!/bin/python

#------------------- Description & Notes --------------------#

'''
python compare_peptides.py \
    --inputfile ../../output/MS/peptides/ont_peptides.txt  \
                ../../output/MS/peptides/illumina_R1_bbduk_peptides.txt \
    --outputcount count.txt \
    --outputdata data.txt
'''

#------------------- Dependencies ---------------------------#

# Standard library imports
import functools

# External imports
import pandas as pd

# Internal imports
from src import io
from src import ops
from src.util import params

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def parsePDPFile(f):
    df  = pd.read_csv(f, sep='\t')
    df  = df[['Accession', 'Sequence']]

    ## Remove duplicate peptides
    df = df.drop_duplicates().reset_index(drop=True)
    return df

def comparePeptides(pepDfs, iFiles):
    ## Two peptides are the same if they have the same sequence.
    cols   = ['Sequence']
    pepDfs = [pepDf[cols].drop_duplicates() for pepDf in pepDfs]

    ## Summarise counts for each data (i.e., Venn diagram)
    pepDict = {f:ops.toSet(pepDf, cols) for pepDf, f in zip(pepDfs, iFiles)}
    cDf     = ops.compareData(pepDict)

    ## Rename columns and organise table
    pepDfs = [pepDf.assign(tmp=pepDf['Sequence']) for pepDf in pepDfs]
    pepDfs = [pepDf.rename(columns={'tmp':f})
              for pepDf, f in zip(pepDfs, iFiles)]

    ## Summarise info for each data
    f      = lambda x, y: x.merge(y, on=cols, how='outer')
    dDf    = functools.reduce(f, pepDfs)
    dDf    = dDf.drop(columns=['Sequence'])
    return (cDf, dDf)

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--inputfile", help="PD Peptide file",
        nargs='+', type=argParser.isFile, required=True)
    argParser.add_argument("--outputcount", help="Output count file",
        nargs=1, required=True)
    argParser.add_argument("--outputdata", help="Output data file",
        nargs=1, required=True)
    args = argParser.parse_args()

    iFiles     = args.inputfile
    oCountFile = args.outputcount[0]
    oDataFile  = args.outputdata[0]

    ## **********
    ## *** Run - Compare unique peptides
    ## **********
    dfs = [parsePDPFile(f) for f in iFiles]

    ## How many peptides are present in each dataset?
    (cDf, dDf) = comparePeptides(dfs, iFiles)
    cDf.to_csv(oCountFile, sep='\t', index=False)
    dDf.to_csv(oDataFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
