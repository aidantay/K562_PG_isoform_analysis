#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

# Internal imports
from ..ops import sortExonStrList

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def getExons(gtfDf):
    ## Get all exons
    cond = (gtfDf['feature'] == 'exon')
    eDf  = gtfDf[cond][['start', 'end', 'transcript_id']]
    eDf['start_end'] = '(' + eDf['start'].astype(str) \
                           + '-' + eDf['end'].astype(str) + ')'
    f = lambda x: ','.join(set(x))
    eDf = eDf.groupby(['transcript_id'])['start_end'].apply(f)
    eDf = eDf.reset_index()
    eDf = eDf.rename(columns={'start_end':'exon_list'})

    ## Sort exons by genomic coordinates
    f = lambda x: ','.join(sortExonStrList(x.split(',')))
    eDf['exon_list'] = eDf['exon_list'].apply(f)
    return eDf

def getTranscripts(gtfDf):
    ## Get the exon list for each transcript
    eDf = getExons(gtfDf)

    ## Get all transcripts and join tables
    cond = (gtfDf['feature'] == 'transcript')
    tDf  = gtfDf[cond][['start', 'end', 'seqname', 'strand', 'transcript_id']]
    tDf  = tDf.merge(eDf, how='left', on='transcript_id')
    return tDf

def getGeneTranscriptPairs(gtfDf):
    ## Create a map of (geneId, transcriptId) pairs and join the tables
    ## to find transcripts associated with each gene
    gtDf = gtfDf[['gene_id', 'transcript_id']]
    gtDf = gtDf.drop_duplicates().dropna().reset_index(drop=True)
    return gtDf

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
