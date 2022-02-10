#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

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
    ## Remove rows containing NaNs. some rows contain NaN's, probably
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

    ## Explode the 'Positions in Proteins'
    pdDf['Positions in Proteins'] = pdDf['Positions in Proteins'].str.split('; ')
    pdDf = pdDf.explode('Positions in Proteins')

    ## Remove rows that are not consistent. This is because some accessions
    ## listed in 'Positions in Protein' are not Master proteins
    cond = pdDf.apply(lambda x: x['Accession'] in x['Positions in Proteins'], axis=1)
    pdDf = pdDf[cond]

    ## Remove duplicate peptides
    pdDf = pdDf.drop_duplicates(['Accession', 'Sequence',
        'Positions in Proteins', 'Description'])
    pdDf = pdDf.reset_index(drop=True).reset_index()
    return pdDf

def PDtoDAT(pdDf):
    with spark.getSparkSession() as ss:
        with ss.sparkContext as sc:
            pdDf = ss.createDataFrame(pdDf)

            ## Add row numbers
            pdDf  = pdDf.select('index', 'Sequence', 'Positions in Proteins', 'Peptide Score')
            pdRdd = pdDf.rdd.map(list).map(getRow)
            qIds  = pdRdd.collect()

    return qIds

def getRow(x):
    qId     = x[0]
    qId     = "q{}_p1".format(qId)

    pepSeq  = x[1].upper()
    score   = x[3]
    pepInfo = "0,0.0,0.0,10,{},0,00000000000000000000,{},0000000000000000000,0,0".format(pepSeq, score)

    posInPros = x[2]
    proInfo   = getProteinInfo(posInPros)

    qId = "{}={};{}".format(qId, pepInfo, proInfo)
    return qId

def getProteinInfo(x):
    proId    = x.split(' ')[0]
    pepPos   = x.split(' ')[1].replace('[', '').replace(']', '')
    pepStart = pepPos.split('-')[0]
    pepEnd   = pepPos.split('-')[1]

    proInfo = "\"{}\":0:{}:{}:0".format(proId, pepStart, pepEnd)
    return proInfo

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
    ## *** Run - Convert PD files to Mascot DAT file
    ## **********
    (psmDf, pepDf, proDf) = io.pd.read(psmFile, pepFile, proFile)
    pdDf = pd.createPdDf(psmDf, pepDf, proDf)
    pdDf = filterPdDf(pdDf)
    qIds = PDtoDAT(pdDf)
    io.dat.write(oFile, qIds)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
