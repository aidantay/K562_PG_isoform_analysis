#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports
import pandas as pd
import pyspark.sql.functions as sparkF

# Internal imports
from src import io
from src.util import params
from src.util import spark

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Protected Classes & Functions ----------#

#------------------- Private Classes & Functions ------------#

def parsePDPFile(f):
    def getProteinId(df):
        x = df['Accession'].str.split('_', expand=True)
        df['ProteinId'] = x.iloc[:, 0:2].apply(lambda x: '_'.join(x), axis=1)
        return df

    def getProteoformId(df):
        x = df['Accession'].str.split('_', expand=True)
        df['ProteoformId'] = x.iloc[:, 0:3].apply(lambda x: '_'.join(x), axis=1)
        return df

    df  = pd.read_csv(f, sep='\t')

    ## Drop columns we don't need anymore and remove any extra redundancies
    ## i.e., duplicate peptides
    df  = df[['Accession', 'Sequence']]
    df  = df.drop_duplicates().reset_index(drop=True)
    df  = getProteinId(df)
    df  = getProteoformId(df)
    return df

def identifyUniqueProteins(pdDf, uniqDf, countP):
    ## Reformat the Spark and Pandas tables so that it makes sense at different levels
    if (countP == 'PROTEIN'):
        ## Adjust the ID's so that we're looking at only 1 protein for each transcript
        ## ProteinId    == 'STRG_<#>'          i.e., Protein/Gene
        pdDf   = pdDf.withColumn('Accession',
            sparkF.regexp_replace('Accession', '(STRG_[0-9]+)_[0-9]+_[0-9]+', '$1'))
        uniqDf = uniqDf.withColumn('Id',
            sparkF.regexp_replace('Id', '(STRG_[0-9]+)_[0-9]+_[0-9]+', '$1'))

    elif (countP == 'PROTEOFORM'):
        ## Adjust the ID's so that we're looking at only 1 protein for each transcript
        ## ProteoformId == 'STRG_<#>_<#>'      i.e., Proteoform/Transcript
        pdDf   = pdDf.withColumn('Accession',
            sparkF.regexp_replace('Accession', '(STRG_[0-9]+_[0-9]+)_[0-9]+', '$1'))
        uniqDf = uniqDf.withColumn('Id',
            sparkF.regexp_replace('Id', '(STRG_[0-9]+_[0-9]+)_[0-9]+', '$1'))

    elif (countP == 'SUBPROTEOFORM'):
        ## Adjust the ID's so that we're looking at only 1 protein for each transcript
        ## Accession    == 'STRG_<#>_<#>_<#>'  i.e., Possible Proteoform/Translated Transcript
        ## NOTE: We don't need to do anything extra here
        pass

    ## Find peptide sequences that map to only 1 protein sequence
    ## This takes some time, but I'm hoping it works out reasonably efficiently
    ## Since we don't have that many peptide/protein sequences
    uniqDf = uniqDf.select('Id', 'Sequence').distinct()
    uniqDf = uniqDf.groupby('Sequence').count()
    uniqDf = uniqDf.filter(sparkF.col('count') == 1)

    ## Join the tables. This could be an issue if the PSP table is too big
    pspDf = pdDf.join(uniqDf, on='Sequence', how='right')
    pspDf = pspDf.select('Accession', 'Sequence').distinct()
    return pspDf

def main():
    ## **********
    ## *** Parse command-line arguemnts
    ## **********
    argParser = params.ArgParser()
    argParser.add_argument("--inputfile", help="PD Peptide file",
        nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--fastx", help="Fasta file",
        nargs=1, type=argParser.isFile, required=True)
    argParser.add_argument("--outputfile", help="Output file",
        nargs=1, required=True)
    args = argParser.parse_args()

    iFile     = args.inputfile[0]
    fastxFile = args.fastx[0]
    oFile     = args.outputfile[0]

    ## **********
    ## *** Run - Unambigous identification of proteoforms from MS/MS peptides
    ## **********
    pdDf = parsePDPFile(iFile)

    with spark.getSparkSession() as ss:
        with ss.sparkContext as sc:
            ## Read FASTA file
            fastxRdd = sc.parallelize([fastxFile])
            fastxRdd = fastxRdd.flatMap(io.fastx.read) \
                .map(lambda x: (x.id, str(x.seq).upper())) \
                .map(lambda x: (x[0].split('|')[0], x[1]))
            fastxDf  = fastxRdd.toDF(['Id', 'ProSequence'])

            ## Construct a table of (peptide) sequences we want to query
            pdDf     = ss.createDataFrame(pdDf)
            pepSeqDf = pdDf.select('Sequence').distinct()

            ## Join the peptide and protein sequence tables
            ## and find rows that match. Should be at least 1 row per sequence
            ## This table determines the uniqueness of each peptide sequence
            cond   = (sparkF.col('ProSequence').contains(sparkF.col('Sequence')))
            uniqDf = pepSeqDf.join(fastxDf, on=cond, how='left')
            uniqDf = uniqDf.select('Id', 'Sequence').distinct()

            ## Uniquely identify proteins/proteoforms/subproteoforms
            ## For unambigous identification, proteins must have at least 1
            ## distinct peptide.
            proDf    = identifyUniqueProteins(pdDf, uniqDf, 'PROTEIN')
            proDf    = proDf.withColumnRenamed('Accession', 'ProteinId') \
                .withColumn('isProteinSpecific', sparkF.lit(True))

            pFormDf  = identifyUniqueProteins(pdDf, uniqDf, 'PROTEOFORM')
            pFormDf  = pFormDf.withColumnRenamed('Accession', 'ProteoformId') \
                .withColumn('isProteoformSpecific', sparkF.lit(True))

            spFormDf = identifyUniqueProteins(pdDf, uniqDf, 'SUBPROTEOFORM')
            spFormDf = spFormDf.withColumnRenamed('Accession', 'Accession') \
                .withColumn('isSubproteoformSpecific', sparkF.lit(True))

            ## Join the tables into a single table
            ## This gives us an idea of the specificity of each peptide.
            pspDf = pdDf.join(proDf, on=['ProteinId', 'Sequence'], how='left')
            pspDf = pspDf.join(pFormDf, on=['ProteoformId', 'Sequence'], how='left')
            pspDf = pspDf.join(spFormDf, on=['Accession', 'Sequence'], how='left')

            ## Clean up
            pspDf = pspDf.fillna(False).drop('ProteoformId', 'ProteinID')
            pspDf = pspDf.coalesce(1)
            pspDf.write.csv(oFile, mode='overwrite', sep='\t', header=True)

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
