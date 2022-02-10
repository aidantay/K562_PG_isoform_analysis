#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import math
import sys

# External imports
import pandas as pd
import pyspark.sql.functions as sparkF
import pyspark.sql.types as sparkT
from pyspark.sql import SparkSession
from pyspark.sql import Row

# Internal imports
from src import xam
from src import io
from src.util import params
from src.util import spark

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Private Classes & Functions ------------#

def parseXamRec(xamRec):
    name         = xamRec.query_name
    isInvalid    = (xamRec.is_secondary or xamRec.is_supplementary or xamRec.is_unmapped)
    query_length = xamRec.query_length
    cigarString  = xamRec.cigarstring
    mdTag        = xamRec.get_tag('MD')
    return (name, isInvalid, query_length, cigarString, mdTag)

def estimateAlignmentAccuracy(*xamInfo):
    (name, isInvalid, query_length, cigarString, mdTag) = xamInfo
    clipDict     = getClipCountDict(cigarString)
    mutCountDict = getMutationCountDict(cigarString, mdTag)
    rrLen        = query_length + clipDict['hardClipCount']
    arLen        = rrLen - clipDict['totalClips']
    perMap       = (arLen / rrLen) * 100
    mutRateDict  = getMutationRateDict(mutCountDict, arLen)

    aa = {'read_id':name, **clipDict, **mutCountDict, **mutRateDict,
          'rawReadLength':rrLen, 'alignedReadLength':arLen,
          'percentMapped':perMap}

    ## To quantify the error rate of reads, we COULD also produce an error
    ## metric. For example, the 'total percent error', which refers to the
    ## perecntage of a read that is inaccurate due to mismatched, inserted
    ## and deleted bases. Such bases are missing from the read but present
    ## in the reference.
    ## See: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4722697/
    ##
    ## Important to note that we're NOT calculating this error metric as
    ## i'm not sure what will be the most intuitive way of presenting this.
    return aa

def getClipCountDict(cigarString):
    sClipCount = xam.getSoftClipCount(cigarString)
    hClipCount = xam.getHardClipCount(cigarString)
    tClipCount = sClipCount + hClipCount
    clipDict   = {'softClipCount':sClipCount, 'hardClipCount':hClipCount,
                  'totalClips':tClipCount}
    return clipDict

def getMutationCountDict(cigarString, mdTag):
    m        = xam.getMatches(mdTag)
    mCount   = sum(m)
    avgMLen  = 0 if mCount == 0 else (mCount / len(m))

    ## Mismatches
    mmBases  = xam.getMismatches(mdTag)
    mm       = [len(x) for x in mmBases]
    mmCount  = sum(mm)
    minMmLen = 0 if mmCount == 0 else min(mm)
    maxMmLen = 0 if mmCount == 0 else max(mm)
    avgMmLen = 0 if mmCount == 0 else (mmCount / len(mm))

    ## Insertions
    i        = xam.getInsertions(cigarString)
    iCount   = sum(i)
    minILen  = 0 if iCount == 0 else min(i)
    maxILen  = 0 if iCount == 0 else max(i)
    avgILen  = 0 if iCount == 0 else (iCount / len(i))

    ## Deletions
    d        = xam.getDeletions(cigarString)
    dCount   = sum(d)
    minDLen  = 0 if dCount == 0 else min(d)
    maxDLen  = 0 if dCount == 0 else max(d)
    avgDLen  = 0 if dCount == 0 else (dCount / len(d))

    mutCountDict = {'matchCount':mCount, 'mismatchCount':mmCount,
        'insertionCount':iCount, 'deletionCount':dCount,
        'minMismatchLen':minMmLen, 'maxMismatchLen':maxMmLen, 'avgMismatchLen':avgMmLen,
        'minInsertionLen':minILen, 'maxInsertionLen':maxILen, 'avgInsertionLen':avgILen,
        'minDeletionLen':minDLen, 'maxDeletionLen':maxDLen, 'avgDeletionLen':avgDLen}

    return mutCountDict

def getMutationRateDict(mutCountDict, arLen):
    mRate       = (mutCountDict['matchCount'] / arLen) * 100
    mmRate      = (mutCountDict['mismatchCount'] / arLen) * 100
    iRate       = (mutCountDict['insertionCount'] / arLen) * 100
    dRate       = (mutCountDict['deletionCount'] / arLen) * 100
    mutRateDict = {'matchRate':mRate, 'mismatchRate':mmRate,
                   'insertionRate':iRate, 'deletionRate':dRate}
    return mutRateDict

def outputAlignmentAccuracy(aasDf, oFile, tDir):
    ## Print the whole table out if required
    if (tDir is not None):
        df = aasDf.coalesce(10)
        df.write.csv(tDir, mode='overwrite', sep='\t', header=True)

    with open(oFile, "w") as f:
        ## Part 1
        cols = ['percentMapped',
                'mismatchCount', 'avgMismatchLen',
                'insertionCount', 'avgInsertionLen',
                'deletionCount', 'avgDeletionLen']

        for c in cols:
            df = aasDf.select(
                    sparkF.min(c).alias("Min"),
                    sparkF.max(c).alias("Max"),
                    sparkF.mean(c).alias("Mean"))
            (minV, maxV, meanV) = df.collect()[0]
            medianV = aasDf.approxQuantile(c, [0.5], 0)[0]

            f.write("Min {}\t{}\n".format(c, minV))
            f.write("Max {}\t{}\n".format(c, maxV))
            f.write("Mean {}\t{}\n".format(c, meanV))
            f.write("Median {}\t{}\n\n".format(c, medianV))

        ## Part 2
        cols = ['matchRate', 'mismatchRate', 'insertionRate', 'deletionRate']
        for c in cols:
            df    = aasDf.select(sparkF.mean(c).alias("Mean"))
            meanV = df.collect()[0][0]
            f.write("Mean {}\t{}\n".format(c, meanV))

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--xam", help="SAM/BAM file",
        nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--outputfile", help="Output file",
        nargs=1, required=True)
    argParser.add_argument("--tabledir", help="Directory containing numericals",
        nargs=1)
    args = argParser.parse_args()

    xamFile = args.xam
    oFile   = args.outputfile[0]
    tDir    = args.tabledir[0] if args.tabledir is not None else None

    ## **********
    ## *** Run - Estimate the overall accuracy of an alignment file
    ## **********
    with spark.getSparkSession() as ss:
        with ss.sparkContext as sc:
            ## Read XAM files
            xamRdd = sc.parallelize(xamFile)
            xamRdd = xamRdd.flatMap(io.xam.read).map(parseXamRec) \
                           .filter(lambda x: not x[1])

            ## Repartition. Supposedly improves efficiency
            nParts = math.floor(xamRdd.count() / 10000)
            nParts = max(sc.defaultParallelism, nParts)
            print("NUM PARTITIONS:\t{}".format(nParts))
            xamRdd = xamRdd.repartition(nParts)

            ## Calculate accuracy metrics for each alignment
            aasDf =  xamRdd.map(lambda x: estimateAlignmentAccuracy(*x)) \
                           .map(lambda x: Row(**x)).toDF()

            ## Summarise accuracy for the whole dataset
            outputAlignmentAccuracy(aasDf, oFile, tDir)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
