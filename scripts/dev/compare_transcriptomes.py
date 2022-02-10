#!/bin/python

#------------------- Description & Notes --------------------#

'''
time python compare_trascriptomes.py \
    --gxf ../../output/RNA-seq/transcripts/illumina_R1_bbduk_Reads1_hisat_filtered_sorted_stringtie.gtf \
          ../../output/RNA-seq/transcripts/illumina_R1_bbduk_Reads2_hisat_filtered_sorted_stringtie.gtf \
    --outputcount count.txt \
    --outputdata data.txt
'''

#------------------- Dependencies ---------------------------#

# Standard library imports
import functools
import itertools

# External imports
import pandas as pd

# Internal imports
from src import gxf
from src import io
from src import ops
from src.util import params

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def compareTranscripts(tDfs, gxfFiles):
    ## Two transcripts are the same if they have the same genomic coordinates.
    ## Specifically, transcripts must have:
    ## * The same chromosome
    ## * The same strand/orientation (i.e., Forward / Reverse)
    ## * The same genomic start and end positions
    ## * The same start and end positions for EACH exon (This essentially
    ##   ensures that the above condition is satisified)
    ## The above works OK, but what if transcripts of different genes
    ## have the same genomic coordinates? In this case, we can't do much about
    ## these... However, can be a bit problematic when we consider alternatively
    ## spliced transcripts
    cols = ['start', 'end', 'seqname', 'strand', 'exon_list']

    ## Summarise counts for each data (i.e., Venn diagram)
    tDict = {f:ops.toSet(tDf, cols) for tDf, f in zip(tDfs, gxfFiles)}
    cDf   = ops.compareData(tDict)

    ## Rename columns
    tDfs = [tDf.rename(columns={'transcript_ids':f, 'transcript_id':f})
            for tDf, f in zip(tDfs, gxfFiles)]

    ## Summarise info for each data
    f    = lambda x, y: x.merge(y, on=cols, how='outer')
    dDf  = functools.reduce(f, tDfs)
    return (cDf, dDf)

def printTranscriptsPerGene(df, f):
    df = df.groupby('gene_id').count().reset_index()
    minCount  = df['transcript_ids'].min()
    maxCount  = df['transcript_ids'].max()
    meanCount = df['transcript_ids'].mean()

    print(f)
    print("Min. transcripts:\t{}".format(str(minCount)))
    print("Max. transcripts:\t{}".format(str(maxCount)))
    print("Mean. transcripts:\t{}".format(str(meanCount)))

def compareGenes(tDfs, gxfFiles):
    ## Two genes are the same if they have the same genomic coordinates.
    ## Specifically, genes must have:
    ## * The same chromosome
    ## * The same strand/orientation (i.e., Forward / Reverse)
    ## * The same genomic start and end positions
    ## However, this is actually pretty hard to do without some reference or
    ## 'baseline' (i.e., Ensembl coordinates) since we have to rely on the
    ## genomic coordinates of the transcripts for each gene. The issue is that
    ## the same gene can be defined by different transcripts and hence the underlying
    ## genomic coordinates of the gene will be different in different datasets.
    def f(df):
        df = df[['gene_id', 'transcript_ids']]

        ## Remove duplicates and collapse IDs
        f  = lambda x: ','.join(set(x))
        df = df.groupby('gene_id')['transcript_ids'].apply(f)
        df = df.reset_index()
        return df

    ## Summarise counts for each data (i.e., Venn diagram)
    tDfs  = [f(tDf) for tDf in tDfs]
    cols  = ['gene_id']
    tDict = {f:ops.toSet(tDf, cols) for tDf, f in zip(tDfs, gxfFiles)}
    cDf   = ops.compareData(tDict)

    ## Rename columns and organise table
    tDfs = [tDf.rename(columns={'transcript_ids':f, 'transcript_id':f})
            for tDf, f in zip(tDfs, gxfFiles)]

    ## Summarise info for each data
    f    = lambda x, y: x.merge(y, on=cols, how='outer')
    dDf  = functools.reduce(f, tDfs)
    return (cDf, dDf)

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--gxf", help="GTF file",
        nargs='+', type=argParser.isFile, required=True)
    argParser.add_argument("--metric", help="[Transcript], [ASTranscript] \
        or [ASGene]", nargs=1, required=True)
    argParser.add_argument("--outputcount", help="Output count file",
        nargs=1, required=True)
    argParser.add_argument("--outputdata", help="Output data file",
        nargs=1, required=True)
    args = argParser.parse_args()

    gxfFiles   = args.gxf
    oMetric    = args.metric[0].upper()
    oCountFile = args.outputcount[0]
    oDataFile  = args.outputdata[0]
    if (len(gxfFiles) < 2):
        raise ValueError('Must have at least 2 GXF files to compare.')

    if (oMetric != 'TRANSCRIPT' and oMetric != 'ASTRANSCRIPT' and oMetric != 'ASGENE'):
        raise ValueError('Invalid option.')

    ## **********
    ## *** Run - Compare unique transcripts
    ## **********
    ## Find all transcripts
    gxfDfs = list(io.gxf.read(*gxfFiles))
    tDfs   = [gxf.getTranscripts(gxfDf) for gxfDf in gxfDfs]

    if (oMetric == 'TRANSCRIPT'):
        ## Find all unique transcripts
        tDfs = [gxf.transcript.dropDuplicates(tDf) for tDf in tDfs]

        ## How many transcripts are present in each dataset?
        (cDf, dDf) = compareTranscripts(tDfs, gxfFiles)
        cDf.to_csv(oCountFile, sep='\t', index=False)
        dDf.to_csv(oDataFile, sep='\t', index=False)

    else:
        ## Find all alternatively spliced transcripts
        ## i.e., genes expressing > 1 unique transcript
        gtDfs = [gxf.getGeneTranscriptPairs(gxfDf) for gxfDf in gxfDfs]
        tDfs  = [gxf.transcript.getASTranscripts(tDf, gtDf)
                 for tDf, gtDf in zip(tDfs, gtDfs)]

        ## I suppose there are two question we can ask here:
        ## * How many (AS) transcripts are present in each dataset?
        ## * How many genes expressing AS transcripts are present in each dataset?
        if (oMetric == 'ASTRANSCRIPT'):
            tDfs = [tDf.drop(columns=['gene_id']) for tDf in tDfs]

            ## How many (AS) transcripts are present in each dataset?
            (cDf, dDf) = compareTranscripts(tDfs, gxfFiles)
            cDf.to_csv(oCountFile, sep='\t', index=False)
            dDf.to_csv(oDataFile, sep='\t', index=False)

        elif (oMetric == 'ASGENE'):
            ## This will ONLY work properly if the IDs in each dataset are
            ## the same. See above for reasoning.

            ## How many transcripts per gene in each dataset?
            [printTranscriptsPerGene(tDf, f) for tDf, f in zip(tDfs, gxfFiles)]

            ## How many genes expressing AS transcripts are present in each dataset?
            (cDf, dDf) = compareGenes(tDfs, gxfFiles)
            cDf.to_csv(oCountFile, sep='\t', index=False)
            dDf.to_csv(oDataFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
