#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def createPdDf(psmDf, pepDf, proDf):
    ## Get the columns we want and the unique rows
    subPsmDf = psmDf[['Master Protein Accessions', 'PSM Ambiguity', 'Confidence',
        'Ions Score', 'Sequence']]
    subPsmDf = subPsmDf.rename(columns={'Confidence':'PSM Confidence',
        'Ions Score':'PSM Score'})
    subPsmDf = subPsmDf.drop_duplicates().reset_index(drop=True)

    subPepDf = pepDf[['Master Protein Accessions', 'Confidence',
        'Confidence (by Search Engine): Mascot', 'Ions Score (by Search Engine): Mascot',
        'Positions in Proteins', 'Sequence']]
    subPepDf = subPepDf.rename(columns={'Confidence':'Peptide Confidence',
        'Confidence (by Search Engine): Mascot':'Peptide Confidence (by Search Engine): Mascot',
        'Ions Score (by Search Engine): Mascot':'Peptide Score'})
    subPepDf = subPepDf.drop_duplicates().reset_index(drop=True)

    subProDf = proDf[['Accession', 'Description',
        'Protein FDR Confidence: Mascot', 'Score Mascot: Mascot']]
    subProDf = subProDf.rename(columns={'Protein FDR Confidence: Mascot':'Protein Confidence',
        'Score Mascot: Mascot':'Protein Score'})
    subProDf = subProDf.drop_duplicates().reset_index(drop=True)

    ## Join the tables
    df = subPsmDf.merge(subPepDf, on=['Sequence', 'Master Protein Accessions'], how='right') \
        .rename(columns={'Master Protein Accessions':'Accession'})
    df = df.merge(subProDf, on='Accession', how='right')
    return df

def removeLowConfidencePSMs(df):
    ## Low confidence PSMs == PSMs > 1% FDR threshold
    cond1 = (df['PSM Ambiguity'] == 'Unambiguous')
    cond2 = (df['PSM Confidence'] == 'High')
    return df[cond1 & cond2]

def removeLowConfidencePeptides(df):
    ## Low confidence peptides == peptides > 1% FDR threshold
    cond1 = (df['Peptide Confidence'] == 'High')
    cond2 = (df['Peptide Confidence (by Search Engine): Mascot'] == 'High')
    return df[cond1 & cond2]

def removeLowConfidenceProteins(df):
    ## Low confidence proteins == proteins > 1% FDR threshold
    cond = (df['Protein Confidence'] == 'High')
    return df[cond]

def removeContaminants(df, ids):
    ## Contaminants == PSMs/Peptides/Proteins associated with contaminant
    cond = (df['Description'].str.contains(ids))
    return df[cond]

def removeXPeptides(df):
    ## X peptides == Peptides containing X's or other ambiguous bases
    cond = (~df['Sequence'].str.contains('X'))
    return df[cond]

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
