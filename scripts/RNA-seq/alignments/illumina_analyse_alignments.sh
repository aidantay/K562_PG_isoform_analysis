#!/bin/bash

##############################################################

# Script Name:        illumina_analyse_alignments.sh
# Author:             Aidan Tay

# Description: Pipeline for analysing the quality of RNA-seq mapping
#              of FASTQ reads from Illumina NextSeq

################### Workspace & Notes #########################

################### Dependencies ##############################

# samtools/1.10.0

################### Global Variables ##########################

################### Functions #################################

analyseAlignments() {
    local inputFilePath=$1
    local inputFilePrefix=$(basename ${inputFilePath} | sed "s|.bam||g")

    local outputFilePrefix=${inputFilePrefix}_alignment_accuracy
    local outputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}_summary.txt
    local tableDirPath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}

    python $SCRIPTS_DIR/dev/estimate_alignment_accuracy.py \
        --xam $inputFilePath \
        --outputfile $outputFilepath \
        --tabledir $tableDirPath
}

############################ Main #############################

echo "Analysing alignments"

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk_hisat_filtered_sorted.bam

## Results before & after filtering
## Requires too much resources (time & memory) to process
#analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_hisat.bam
#analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat_filtered_sorted.bam


## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat_filtered_sorted.bam

