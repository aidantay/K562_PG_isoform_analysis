#!/bin/bash

##############################################################

# Script Name:        ont_align_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for aligning RNA-seq FASTQ reads
#              from Oxford Nanopore MinION onto a human
#              reference genome / transcriptome

################### Workspace & Notes #########################

# minimap2/2.16
# samtools/1.10.0

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

alignReads() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.fastq||g")

    local outputFilePrefix=${inputFilePrefix}_minimap
    local samOutputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.sam
    local bamOutputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.bam

    minimap2 \
        -x splice \
        -k 15 \
        -u f \
        -a \
        -t 16 \
        $GENOME_DATA_DIR/fasta/all_chromosomes.fa \
        $inputFilepath \
        > $samOutputFilepath

    samtools view \
        -b \
        -@ 16 \
        -o $bamOutputFilepath \
        < $samOutputFilepath
}

############################ Main #############################

echo "Aligning FASTQ reads"

alignReads $READS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt.fastq
alignReads $READS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt.fastq
alignReads $READS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt.fastq
alignReads $READS_OUTPUT_DIR/ont_guppy_merged_nanofilt.fastq
