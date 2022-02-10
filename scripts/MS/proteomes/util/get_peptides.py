#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import functools

# External imports
import pandas as pd

# Internal imports
import argparse
from argparse import ArgumentParser

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def parsePepFile(f):
    df = pd.read_csv(f, sep='\t')
    df = df[['Accession', 'Sequence']].drop_duplicates().reset_index(drop=True)
    return df

def parseProteotypicFile(f):
    df = pd.read_csv(f, sep='\t', header=None)
    df.columns = ['Type', 'Accession', 'Sequence', 'Value']
    df = df[['Accession', 'Sequence', 'Value']].drop_duplicates().reset_index(drop=True)
    return df

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = ArgumentParser()
    argParser.add_argument("--proteotypic", help="Proteotypic peptide file",
        nargs=1, required=True)
    argParser.add_argument("--specific", help="Proteoform-specific peptide file",
        nargs=1, required=True)
    argParser.add_argument("--outputfile", help="Output peptide file",
        nargs=1, required=True)
    args = argParser.parse_args()

    tFile = args.proteotypic[0]
    sFile = args.specific[0]
    oFile = args.outputfile[0]

    ## **********
    ## *** Run - Compare unique peptides
    ## **********
    ## Read proteotypic file
    x = parseProteotypicFile(tFile)

    ## Read proteoform-specific file
    y = pd.read_csv(sFile, sep='\t')

    ## Merge DataFrames
    df = x.merge(y, on=['Accession', 'Sequence'], how='left')
    df.to_csv(oFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
