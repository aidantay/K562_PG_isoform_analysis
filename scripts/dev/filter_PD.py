#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports
import pyspark.sql.functions as sparkF

# Internal imports
from src import io
from src import pd
from src.util import params
from src.util import spark

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def filterPdDf(pdDf):
    ## Remove rows containing NaNs. Some rows contain NaN's, probably
    ## because the PSM or peptide didn't make the Protein FDR threshold cut-off
    pdDf = pdDf.dropna()

    ## Account for 1% FDR
    pdDf = pd.removeLowConfidencePSMs(pdDf)
    pdDf = pd.removeLowConfidencePeptides(pdDf)
    pdDf = pd.removeLowConfidenceProteins(pdDf)

    ## Remove contaminants and peptides containing ambiguous bases
    ## This works for our custom databases but not our reference;
    ## We need to change the pattern to 'OS=' or something
    pdDf = pd.removeContaminants(pdDf, 'STRG')
    pdDf = pd.removeXPeptides(pdDf)

    # ## Drop columns we don't need anymore and remove any extra redundancies
    # pdDf = pdDf.drop(columns=['PSM Ambiguity', 'PSM Confidence', 'PSM Score',
    #     'Peptide Confidence', 'Peptide Confidence (by Search Engine): Mascot',
    #     'Peptide Score', 'Protein Confidence', 'Protein Score',
    #     'Positions in Proteins', 'Description'])

    # ## Remove duplicate peptides
    # pdDf = pdDf.drop_duplicates().reset_index(drop=True)
    return pdDf

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--psmfile", help="PSM group file from \
        ProteomeDiscoverer", nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--peptidefile", help="Peptide group file from \
        ProteomeDiscoverer", nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--proteinfile", help="Protein group file from \
        ProteomeDiscoverer", nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--outputfile", help="Output file",
        nargs=1, required=True)
    args = argParser.parse_args()

    psmFile = args.psmfile[0]
    pepFile = args.peptidefile[0]
    proFile = args.proteinfile[0]
    oFile   = args.outputfile[0]

    ## **********
    ## *** Run - Filter peptides
    ## **********
    (psmDf, pepDf, proDf) = io.pd.read(psmFile, pepFile, proFile)
    pdDf = pd.createPdDf(psmDf, pepDf, proDf)
    pdDf = filterPdDf(pdDf)
    pdDf.to_csv(oFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------

