#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import itertools

# External imports
import pandas as pd
import pyspark.sql.functions as sparkF
import pyspark.sql.types as sparkT
from pyspark.sql import SparkSession

# Internal imports
from src import gxf
from src import io
from src import ops
from src import xam
from src.util import params
from src.util import spark

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def parseXamRec(xamRec):
    query_name  = xamRec.query_name
    readId      = 1 if xamRec.is_read1 else 2
    strand      = '-' if xamRec.is_reverse else '+'
    ref_name    = xamRec.reference_name
    ref_pos     = xamRec.reference_start + 1
    cigarTuples = xamRec.cigartuples
    return ((query_name, readId, ref_name, strand), (ref_pos, cigarTuples))

def getXamDf(xamRdd):
    ss = SparkSession.getActiveSession()
    if (ss is None):
        raise EnvironmentError("Must have an active Spark session")

    ## We're unable to repartition before mapping
    sc     = ss.sparkContext
    xamRdd = xamRdd.repartition(sc.defaultParallelism)

    ## Convert the cigar string into genomic coordinates
    ## so that we can get the position of exons and exon-exon junctions
    f = lambda x: xam.cigartuplesToGenomicCoordinates(x[0], x[1])
    g = lambda x: (x, ops.exonStrListToJunctionStrList(x))
    xamRdd = xamRdd.mapValues(f).mapValues(g)

    ## Get the start and end coordinates of the read
    f = lambda x: (int(ops.getStart(x[0])), int(ops.getEnd(x[0])), *x)
    g = lambda x: (*x[0], *x[1])
    xamRdd = xamRdd.mapValues(f).map(g)

    ## Construct the schema for the Spark DataFrame
    colNames = ['query_name', 'readId', 'ref_name', 'strand',
                'rStart', 'rEnd', 'exon_list', 'junction_list']
    colTypes = [sparkT.StringType(), sparkT.IntegerType(),
                sparkT.StringType(), sparkT.StringType(),
                sparkT.IntegerType(), sparkT.IntegerType(),
                sparkT.ArrayType(sparkT.StringType()),
                sparkT.ArrayType(sparkT.StringType())]
    cols     = [sparkT.StructField(c, t) for c, t in zip(colNames, colTypes)]
    schema   = sparkT.StructType(cols)

    ## Construct a Spark DataFrame of XAM records
    xamDf    = ss.createDataFrame(xamRdd, schema)
    return xamDf

def getGxfDf(gtDf):
    ss = SparkSession.getActiveSession()
    if (ss is None):
        raise EnvironmentError("Must have an active Spark session")

    ## Construct the schema for the Spark DataFrame
    colNames = ['gene_id', 'transcript_id',
                'tStart', 'tEnd', 'seqname', 'strand',
                'exon_list', 'junction_list']

    colTypes = [sparkT.StringType(), sparkT.StringType(),
                sparkT.IntegerType(), sparkT.IntegerType(),
                sparkT.StringType(), sparkT.StringType(),
                sparkT.ArrayType(sparkT.StringType()),
                sparkT.ArrayType(sparkT.StringType())]
    cols     = [sparkT.StructField(c, t) for c, t in zip(colNames, colTypes)]
    schema   = sparkT.StructType(cols)

    ## Construct a Spark DataFrame of XAM records
    gtDf     = ss.createDataFrame(gtDf, schema)
    return gtDf

def identifyUniqueTranscripts(xamDf, gtDf, ssFlag):
    ## Find transcripts that overlap with each read
    tDf = identifyTranscripts(xamDf, gtDf, ssFlag)

    ## Find transcript-specific reads
    tsrDf = identifyTranscriptSpecificReads(tDf)

    ## Join tables to retrieve IDs
    df  = tDf.join(tsrDf, ['query_name', 'readId'], 'right')
    df  = df.select(df.query_name, df.readId, df.transcript_id) \
            .sort(df.transcript_id, df.query_name, df.readId)
    return df

def identifyTranscripts(xamDf, gtDf, ssFlag):
    cond = [xamDf.ref_name == gtDf.seqname,
            xamDf.rStart >= gtDf.tStart, xamDf.rEnd <= gtDf.tEnd]

    if (ssFlag):
        ssCond = (xamDf.strand == gtDf.strand)
        cond.append(ssCond)

    tDf  = xamDf.join(gtDf, cond, 'inner')

    ## Check whether the genomic coordinates of the read
    ## matches with the genomic coordinates of the transcript
    tDf  = tDf.withColumn('isAligned',
        hasReadAlignment(xamDf.exon_list, xamDf.junction_list,
            gtDf.exon_list, gtDf.junction_list))

    ## If there's a match, then we have 'some evidence' for the transcript
    ## We still need to check whether the read uniquely maps to the transcript
    tDf  = tDf.select(xamDf.query_name, xamDf.readId,
        gtDf.gene_id, gtDf.transcript_id, 'isAligned')
    tDf  = tDf.filter(tDf.isAligned == True)
    return tDf

def identifyTranscriptSpecificReads(tDf):
    ## Find reads that are transcript-specific
    ## Reads are considered transcript-specific if it overlaps with exactly
    ## 1 transcript of a gene.
    tsDf = tDf.groupby('query_name', 'readId', 'gene_id').count()
    tsDf = tsDf.select('query_name', 'readId',
        sparkF.col('count').alias('transcript_count'))

    ## (Long) reads may potentially span across multiple genes
    ## and therefore multiple transcripts. Therefore, find reads that
    ## are gene-specific
    ## Reads are considered gene-specific if it overlaps with exactly 1 gene.
    gsDf = tsDf.groupby('query_name', 'readId').count()
    gsDf = gsDf.select('query_name', 'readId',
        sparkF.col('count').alias('gene_count'))

    ## Join tables
    tsrDf = tsDf.join(gsDf, ['query_name', 'readId'], 'full')
    tsrDf = tsrDf.filter((tsrDf.gene_count == 1) & (tsrDf.transcript_count == 1))
    return tsrDf

@sparkF.udf(returnType=sparkT.BooleanType())
def hasReadAlignment(rexStrList, rjunStrList, texStrList, tjunStrList):
    (rStart, rEnd) = (ops.getStart(rexStrList), ops.getEnd(rexStrList))
    (tStart, tEnd) = (ops.getStart(texStrList), ops.getEnd(texStrList))

    ## Check whether the read is smaller than the transcript
    if (hasOverlap((rStart, rEnd), (tStart, tEnd))):
        rexs = [ops.exonStrToTuple(rEx) for rEx in rexStrList]
        texs = [ops.exonStrToTuple(tEx) for tEx in texStrList]

        ## Check whether every 'exon' and 'junction' of the read
        ## aligns with the transcript.
        eOverlaps = [any(hasOverlap(rEx, tEx) for tEx in texs)
                     for rEx in rexs]
        jOverlaps = [any((rJun == tJun) for tJun in tjunStrList)
                     for rJun in rjunStrList]
        overlaps  = itertools.chain(eOverlaps, jOverlaps)
        if (all(list(overlaps))):
            return True

    return False

def hasOverlap(rEx, tEx):
    if (rEx[0] >= tEx[0] and rEx[1] <= tEx[1]):
        return True

    return False

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--gxf", help="GTF file",
        nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--xam", help="SAM/BAM file",
        nargs='+', type=argParser.isFile, required=True)
    argParser.add_argument("--outputfile", help="Output file",
        nargs=1, required=True)
    argParser.add_argument("--ss", help="Reads must match strand of transcript. \
        Mainly for ONT Direct RNA-seq reads", action='store_true')
    args = argParser.parse_args()

    gxfFile  = args.gxf
    xamFiles = args.xam
    oFile    = args.outputfile[0]
    ssFlag   = args.ss

    ## **********
    ## *** Run - Unambigous identification of transcripts from RNA-seq reads
    ## **********
    gxfDf = list(io.gxf.read(*gxfFile))[0]
    tDf   = gxf.getTranscripts(gxfDf)
    gtDf  = gxf.getGeneTranscriptPairs(gxfDf)
    gtDf  = gtDf.merge(tDf, on='transcript_id', how='left')
    gtDf['exon_list']     = gtDf['exon_list'].str.split(',')
    gtDf['junction_list'] = gtDf['exon_list'].apply(ops.exonStrListToJunctionStrList)

    with spark.getSparkSession() as ss:
        with ss.sparkContext as sc:
            ## Read XAM files
            xamRdd = sc.parallelize(xamFiles)
            xamRdd = xamRdd.flatMap(io.xam.read).map(parseXamRec)

            ## Construct Spark XAM DataFrame
            xamDf  = getXamDf(xamRdd)
            xamDf.persist()

            ## Construct Spark GXF DataFrame
            gtDf   = getGxfDf(gtDf)
            gtDf.persist()

            ## Uniquely identify transcripts.
            ## For unambiguous identification, transcripts must
            ## have at least 1 distinct read.
            tsrDf  = identifyUniqueTranscripts(xamDf, gtDf, ssFlag)
            tsrDf  = tsrDf.coalesce(1)
            tsrDf.write.csv(oFile, mode='overwrite', sep='\t', header=True)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
