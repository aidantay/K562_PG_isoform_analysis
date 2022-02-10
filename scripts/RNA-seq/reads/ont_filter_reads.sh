#!/bin/bash

##############################################################

# Script Name:        ont_filter_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for getting high-confidence reads. This
#              is done by trimming quality or adpator sequences
#              and filtering out extremely short / long
#              RNA-seq FASTQ reads from Oxford Nanopore MinION

################### Workspace & Notes #########################

# nanopack/1.0.3

################### Dependencies ##############################

################### Global Variables ##########################

QUALITY=7        ## Mean QScores > 7 are considered accurately basecalled reads
MIN_LENGTH=60    ## Based on Ensembl data, the shortest protein-coding transcript is 63bp
HEAD=10          ## Based on fastQC, the first 10 bases are mostly low quality
                 ## However, NanoFilt performs hard trimming, so reads that
                 ## don't not need trimming will be trimmed anyway.
TAIL=0

################### Functions #################################

convertUtoT() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.fastq||g")

    local outputFilePrefix=${inputFilePrefix}_noUs
    local outputFilepath=$READS_OUTPUT_DIR/${outputFilePrefix}.fastq

    i=0
    while read l; do
        if [ $i -lt 1 ]; then
            i=$(($i+1))
            echo $l

        else
            echo $l | sed 's/U/T/g' 
            read l
            echo $l
            read l
            echo $l
            read l
            echo $l
       fi
    done < $inputFilepath > $outputFilepath
}

filterReads() {
    local inputFilepath=$1
    local inputSummaryFilepath=$2

    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.fastq||g")
    local outputFilePrefix=${inputFilePrefix}_nanofilt
    local outputFilepath=$READS_OUTPUT_DIR/${outputFilePrefix}.fastq

    NanoFilt \
        --summary $inputSummaryFilepath \
        --readtype 1D \
        --quality $QUALITY \
        $inputFilepath \
        > $READS_OUTPUT_DIR/temp.fastq

    NanoFilt \
        --readtype 1D \
        --headcrop $HEAD \
        $READS_OUTPUT_DIR/temp.fastq \
        > $READS_OUTPUT_DIR/temp2.fastq

    NanoFilt \
        --readtype 1D \
        --length $MIN_LENGTH \
        $READS_OUTPUT_DIR/temp2.fastq \
        > $outputFilepath

    rm $READS_OUTPUT_DIR/temp*.fastq
}

#################### Main #####################################

echo "Trimming and Filtering FASTQ reads"

filterReads \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/ADM5153_5056_guppy_merged.fastq \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/ADM5153_5056_sequencing_summary.txt

filterReads \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4430_guppy_merged.fastq \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4430_sequencing_summary.txt

filterReads \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4712_guppy_merged.fastq \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4712_sequencing_summary.txt

## Merge all the reads into a single file
cat $READS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt.fastq \
    $READS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt.fastq \
    $READS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt.fastq \
    > $READS_OUTPUT_DIR/ont_guppy_merged_nanofilt.fastq

## Generate read files with U -> T substitutions
## This is mainly to see whether there is any significant difference
## in results between U and T (which did not occur)
convertUtoT $READS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt.fastq
convertUtoT $READS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt.fastq
convertUtoT $READS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt.fastq
