#!/bin/python

#------------------- Description & Notes --------------------#

'''
python compare_proteomes.py \
    --gxf ../../output/MS/proteomes/ont_ensembl_proteoforms.gtf \
    ../../output/MS/proteomes/illumina_R1_bbduk_Reads1_ensembl_proteoforms.gtf \
    ../../output/MS/proteomes/illumina_R1_bbduk_Reads2_ensembl_proteoforms.gtf \
    --refgxf ../../output/MS/proteomes/ont_ensembl_proteoforms.gtf \
    --metric proteoform \
    --format known \
    --outputcount count.txt \
    --outputdata data.txt
'''

## For all intent and purposes:
## * A protein broadly refers to the product of a gene.
##   Gene -> Transcript -> Protein
## * A proteoform refers to an individual product of a gene.
##   Gene -> Transcript1 -> Proteoform1 \
##        -> Transcript2 -> Proteoform2 -- Protein
##        -> Transcript3 -> Proteoform3 /

#------------------- Dependencies ---------------------------#

# Standard library imports
import functools

# External imports

# Internal imports
from src import gxf
from src import io
from src import ops
from src.util import params

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def identifyProteoforms(k, v, refGxf, refTdf):
    pDf = compareTranscripts([v, refTdf], [k, refGxf])[1]
    pDf = pDf[~(pDf[k].isna())]
    pDf = pDf.rename(columns={k:'transcript_id', refGxf: 'ref_transcript_id'})
    return pDf

def compareTranscripts(tDfs, gxfFiles):
    ## Two transcripts are the same if they have the same genomic coordinates
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

def identifyKnownProteoforms(pDf, gtRefDf):
    ## Find known proteoforms
    cond = pDf['ref_transcript_id'].isna()
    pDf  = pDf[~cond].copy()

    ## Explode reference IDs and join tables so that we can distinguish
    ## between proteoforms
    ## Not sure why MERGE works but not JOIN...
    pDf['ref_transcript_id'] = pDf['ref_transcript_id'].str.split(',')
    pDf = pDf.explode('ref_transcript_id')
    pDf = pDf.merge(gtRefDf, on='ref_transcript_id', how='left')
    pDf = pDf.reset_index()
    return pDf

def getProteins(pDf):
    pDf = pDf.drop(columns=['ref_transcript_id']).drop_duplicates()
    f  = lambda x: ','.join(set(x))
    pDf = pDf.groupby(['ref_gene_id'])['transcript_id'].apply(f)
    pDf = pDf.reset_index()
    return pDf

def getProteoforms(pDf):
    f  = lambda x: ','.join(set(x))
    pDf = pDf.groupby(['ref_gene_id', 'transcript_id'])['ref_transcript_id'].apply(f)
    pDf = pDf.reset_index()
    pDf = pDf[['ref_gene_id', 'ref_transcript_id', 'transcript_id']]
    return pDf

def getASProteoforms(pDf):
    ## Count how many unique proteoforms we have per gene
    tCount = pDf['ref_gene_id'].value_counts().reset_index()
    tCount.columns = ['ref_gene_id', 'num_identified_ref_transcript_ids']
    pDf = pDf.merge(tCount, on='ref_gene_id', how='left')

    ## Remove those with only a single proteoform
    cond = (pDf['num_identified_ref_transcript_ids'] > 1)
    pDf  = pDf[cond].copy()
    pDf  = pDf.drop(columns=['num_identified_ref_transcript_ids']) \
        .reset_index(drop=True)
    return pDf

def getASGenes(pDf):
    pDf = pDf.drop(columns=['ref_transcript_id'])
    f  = lambda x: ','.join(set(x))
    pDf = pDf.groupby(['ref_gene_id'])['transcript_id'].apply(f)
    pDf = pDf.reset_index()
    return pDf

def compareKnownProteomes(pDict, oMetric):
    ## Ideally, proteins/proteoforms should be compared based on their genomic
    ## coordinates of the GENE, and the protein sequence. But given the current
    ## data, its a bit tricky to do. Instead, we'll just compare them
    ## based on their gene and transcript IDs (which is a proxy for the protein).
    pDict = {k:pDf[['ref_transcript_id', 'ref_gene_id', 'transcript_id']]
        for k, pDf in pDict.items()}

    ## Filter and collapse IDs depending on whether we're looking for
    ## proteins/proteoforms or genes
    if (oMetric == 'PROTEIN'):
        ## Select the columns we want and collapse IDs because we only
        ## care about the product of a gene, regardless of transcript origin.
        ## * RefGene -> [Transcript]
        pDict  = {k:getProteins(pDf) for k, pDf in pDict.items()}
        pFiles = pDict.keys()
        pDfs   = pDict.values()

        ## How many proteins are present in each dataset?
        (cDf, dDf) = compareProteins(pDfs, pFiles)

    elif (oMetric == 'PROTEOFORM'):
        ## Collapse IDs because we only want unique proteoforms
        ## * (RefTranscript, RefGene) -> [Transcript]
        pDict  = {k:getProteoforms(pDf) for k, pDf in pDict.items()}
        pFiles = pDict.keys()
        pDfs   = pDict.values()

        ## How many proteoforms are present in each dataset?
        (cDf, dDf) = compareProteoforms(pDfs, pFiles)

    elif (oMetric == 'ASPROTEOFORM'):
        ## Find genes that have more than 1 unique proteoform
        ## * (RefTranscript, RefGene) -> [Transcript]
        pDict  = {k:getProteoforms(pDf) for k, pDf in pDict.items()}
        pDict  = {k:getASProteoforms(pDf) for k, pDf in pDict.items()}
        pFiles = pDict.keys()
        pDfs   = pDict.values()

        ## * How many (AS) proteoforms are present in each dataset? 
        (cDf, dDf) = compareProteoforms(pDfs, pFiles)

    elif (oMetric == 'ASGENE'):
        ## Select the columns we want, then collapse IDs because we only
        ## care about the product of a gene, regardless of transcript origin.
        ## * RefGene -> [Transcript]
        pDict  = {k:getProteoforms(pDf) for k, pDf in pDict.items()}
        pDict  = {k:getASProteoforms(pDf) for k, pDf in pDict.items()}
        pDict  = {k:getASGenes(pDf) for k, pDf in pDict.items()}
        pFiles = pDict.keys()
        pDfs   = pDict.values()

        ## * How many genes expressing (AS) proteoforms are present in each dataset? 
        (cDf, dDf) = compareProteins(pDfs, pFiles)

    return (cDf, dDf)

def compareProteins(tDfs, gxfFiles):
    ## Two proteins are the same if they are associated with the same GENE.
    cols = ['ref_gene_id']

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

def compareProteoforms(tDfs, gxfFiles):
    ## Two proteoforms are the same if they are derived from the same GENE
    cols = ['ref_gene_id', 'ref_transcript_id']

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

def identifyNovelProteoforms(pDf, gtfDf):
    ## Find the closest known gene/transcript IDs for each proteoform
    cond  = (gtfDf['feature'] == 'transcript')
    gtfDf = gtfDf[cond][['transcript_id', 'ref_gene_id', 'reference_id']]

    ## Find the novel proteoforms
    cond = pDf['ref_transcript_id'].isna()
    pDf  = pDf[cond].copy()
    pDf  = pDf.drop(columns=['ref_transcript_id'])
    pDf  = pDf.merge(gtfDf, on='transcript_id', how='left')
    pDf  = pDf.reset_index(drop=True)

    ## We should be exploding before we join the tables, but I'm not
    ## sure whether it'll be significant enough to bother doing it
    # ## Explode reference IDs and join tables so that we can distinguish
    # ## between proteoforms
    # pDf['transcript_id'] = pDf['transcript_id'].str.split(',')
    # pDf = pDf.explode('transcript_id')
    return pDf

def compareNovelProteomes(pDict, oMetric):
    ## Although we have some idea about the gene of novel transcripts,
    ## it's actually a bit hard establish which gene they are from.
    ## So we'll essentially compare the transcripts.
    pFiles = pDict.keys()
    pDfs   = pDict.values()
    (cDf, dDf) = compareTranscripts(pDfs, pFiles)
    return (cDf, dDf)

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--gxf", help="GTF file",
        nargs='+', type=argParser.isFile, required=True)
    argParser.add_argument("--refgxf", help="Reference GTF file",
        nargs=1, required=True)
    argParser.add_argument("--metric", help="[Protein], [Proteoform], \
        [ASProteoform] or [ASGene]", nargs=1, required=True)
    argParser.add_argument("--format", help="[Known] or [Novel]",
        nargs=1, required=True)
    argParser.add_argument("--outputcount", help="Output count file",
        nargs=1, required=True)
    argParser.add_argument("--outputdata", help="Output data file",
        nargs=1, required=True)
    args = argParser.parse_args()

    gxfFiles   = args.gxf
    refGxf     = args.refgxf[0]
    oMetric    = args.metric[0].upper()
    oFormat    = args.format[0].upper()
    oCountFile = args.outputcount[0]
    oDataFile  = args.outputdata[0]

    if (oMetric != 'PROTEIN' and oMetric != 'PROTEOFORM'
        and oMetric != 'ASPROTEOFORM' and oMetric != 'ASGENE'):
        raise ValueError('Invalid option.')

    if (oFormat != 'KNOWN' and oFormat != 'NOVEL'):
        raise ValueError('Invalid option.')

    ## **********
    ## *** Run - Compare unique proteins
    ## **********
    ## Find the unique proteoforms in each dataset based on
    ## the genomic coordinates of transcripts
    gxfDfs = list(io.gxf.read(*gxfFiles))
    tDfs   = [gxf.getTranscripts(gxfDf) for gxfDf in gxfDfs]
    tDfs   = [gxf.transcript.dropDuplicates(tDf) for tDf in tDfs]
    tDict  = {f:tDf for f, tDf in zip(gxfFiles, tDfs)}

    ## Compare each non-reference dataset with the
    ## reference to identify proteoforms
    pDict = {k:identifyProteoforms(k, v, refGxf, tDict[refGxf])
        for k, v in tDict.items() if k != refGxf}

    ## Identified known proteoforms will be assigned a reference ID
    ## Identified novel proteoforms will not be assigned a reference ID
    if (oFormat == 'KNOWN'):
        ## To identify known proteins/proteoforms, we have to assign the gene IDs
        idx     = gxfFiles.index(refGxf)
        gtRefDf = gxfDfs.pop(idx)
        gtRefDf = gxf.getGeneTranscriptPairs(gtRefDf)
        gtRefDf = gtRefDf.rename(columns={'gene_id':'ref_gene_id',
            'transcript_id':'ref_transcript_id'})

        ## Find known proteoforms
        pDict = {k:identifyKnownProteoforms(pDf, gtRefDf) for k, pDf in pDict.items()}

        ## Compare identified proteomes
        (cDf, dDf) = compareKnownProteomes(pDict, oMetric)
        cDf.to_csv(oCountFile, sep='\t', index=False)
        dDf.to_csv(oDataFile, sep='\t', index=False)

    else:
        ## To identify novel proteins/proteoforms, we have to assign the 
        ## closest known gene/transcript IDs. So we need the original GXF table
        gDict = {f:gxfDf for f, gxfDf in zip(gxfFiles, gxfDfs) if f != refGxf}

        ## Find novel proteoforms
        pDict = {k:identifyNovelProteoforms(pDf, gDict[k]) for k, pDf in pDict.items()}

        ## Compare identified proteomes
        (cDf, dDf) = compareNovelProteomes(pDict, oMetric)
        cDf.to_csv(oCountFile, sep='\t', index=False)
        dDf.to_csv(oDataFile, sep='\t', index=False)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
