#!/bin/python

#------------------- Description & Notes --------------------#

'''
Protein Accessions refer to all possible proteins containing the PSM/peptide.
Master Protein Accessions (probably) refers to the protein/s that make the
protein FDR threshold cut-off. Thus, PSMS/peptides 'should' always have Protein
Accessions, but may not always have Master Protein Accessions if the protein
didn't make the protein FDR threshold

The question is which one is better to use? I'll stick with the Master
Protein Accessions because they are adjusted to the Protein level FDR.
'''

#------------------- Dependencies ---------------------------#

# Standard library imports
import itertools
import re

# External imports
import pandas as pd

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def read(psmFile, pepFile, proFile):
    psmDf = _readPsmFile(psmFile)
    pepDf = _readPeptideFile(pepFile)
    proDf = _readProteinFile(proFile)
    return (psmDf, pepDf, proDf)

#------------------- Private Classes & Functions ------------#

def _readPsmFile(f):
    psmDf = pd.read_csv(f, sep='\t')

    ## Remove rows that aren't associated with Master Protein Accessions
    ## Probably because they didn't make the Protein FDR threshold cut-off
    cond  = (~psmDf['Master Protein Accessions'].isna())
    psmDf = psmDf[cond]

    ## Explode the 'Master Protein Accessions'
    psmDf['Master Protein Accessions'] = psmDf['Master Protein Accessions'].str.split('; ')
    psmDf = psmDf.explode('Master Protein Accessions')
    return psmDf

def _readPeptideFile(f):
    pepDf = pd.read_csv(f, sep='\t')

    ## Remove rows that aren't associated with Master Protein Accessions
    ## Probably because they didn't make the Protein FDR threshold cut-off
    cond  = (~pepDf['Master Protein Accessions'].isna())
    pepDf = pepDf[cond]

    ## Explode the 'Master Protein Accessions'
    pepDf['Master Protein Accessions'] = pepDf['Master Protein Accessions'].str.split('; ')
    pepDf = pepDf.explode('Master Protein Accessions')

    ## Fix up the format of the 'Positions in Proteins' column
    pepDf['Positions in Proteins'] = pepDf['Positions in Proteins'].apply(_fixPIPFormat)
    return pepDf

def _readProteinFile(f):
    proDf = pd.read_csv(f, sep='\t')
    return proDf

def _fixPIPFormat(prevPosInPros):
    proIds    = []
    positions = []

    ## The format of the position is always the same, i.e., [0-9-]+.
    ## However, the format of the accession is not always the same and
    ## we don't always find an accession for each position (i.e., when
    ## a peptide can map to more than one position in the protein). Instead,
    ## we need to fill in the gaps by looking back at the most recent accession
    for x in prevPosInPros:
        m = re.match(".*(\[[0-9-]+\])", x)
        if (m):
            pos   = m.groups()[0]
            proId = x.replace(pos, '').strip()
            proId = None if len(proId) == 0 else proId
            proIds.append(proId)
            positions.append(pos)

    if (None in proIds):
        newIds = pd.Series(proIds)
        newIds = newIds.ffill()
        newIds = newIds.tolist()
        newPosInPros = ["{} {}".format(a, b) for a, b in zip(newIds, positions)]
        return newPosInPros

    return prevPosInPros

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
