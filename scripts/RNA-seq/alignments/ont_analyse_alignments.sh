#!/bin/bash

##############################################################

# Script Name:        ont_analyse_alignments.sh
# Author:             Aidan Tay

# Description: Pipeline for analysing the quality of RNA-seq mapping
#              of FASTQ reads from Oxford Nanopore MinION

################### Workspace & Notes #########################

################### Dependencies ##############################

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
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap_filtered_sorted.bam

## Results before & after filtering
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap.bam
analyseAlignments $ALIGNMENTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted.bam
