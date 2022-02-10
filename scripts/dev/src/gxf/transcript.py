#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

# Internal imports
from .common import *

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def dropDuplicates(df, geneId=False):
    cols = ['start', 'end', 'seqname', 'strand', 'exon_list']
    if (geneId):
        ## Add the 'gene_id' if we have the column
        cols = cols + ['gene_id']

    ## Remove duplicates and collapse IDs
    f  = lambda x: ','.join(set(x))
    df = df.groupby(cols)['transcript_id'].apply(f)
    df = df.reset_index()
    df = df.rename(columns={'transcript_id':'transcript_ids'})
    df = df.reset_index(drop=True)
    return df

def explodeDuplicates(tDf):
    ## Explode the transcripts so that we can map them to the genes
    tDf['transcript_ids'] = tDf['transcript_ids'].str.split(',')
    tDf = tDf.explode('transcript_ids')
    tDf = tDf.rename(columns={'transcript_ids':'transcript_id'})
    tDf = tDf.reset_index(drop=True)
    return tDf

def removeSingleTranscriptGenes(gtDf):
    ## Count the number of transcripts per gene and remove
    ## those with only 1 transcript
    f    = lambda x: x['transcript_ids'].count() > 1
    gtDf = gtDf.groupby('gene_id').filter(f)
    gtDf = gtDf.reset_index(drop=True)
    return gtDf   

def getASTranscripts(tDf, gtDf):
    ## Join the tables to find transcripts associated with each gene
    gtDf = gtDf.merge(tDf, on='transcript_id', how='left')
    gtDf = dropDuplicates(gtDf, geneId=True)

    ## Find genes with > 1 distinct transcript
    ## Transcripts are considered alternatively spliced if there are 
    ## two or more distinct transcripts associated with a single gene
    gtDf = removeSingleTranscriptGenes(gtDf)
    return gtDf

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
