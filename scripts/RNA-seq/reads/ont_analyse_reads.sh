#!/bin/bash

##############################################################

# Script Name:        ont_analyse_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for analysing the quality of
#              RNA-seq FASTQ reads from Oxford Nanopore MinION

################### Workspace & Notes #########################

# fastqc/0.11.8
# bbtools/38.37
# nanopack/1.0.3

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

#################### Main #####################################

echo "Analysing FASTQ reads"

## Results before filtering
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/ADM5153_5056_guppy_merged.fastq \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4430_guppy_merged.fastq \
    $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4712_guppy_merged.fastq

## Results after filtering
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt.fastq \
    $READS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt.fastq \
    $READS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt.fastq

## Results after merging
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/ont_guppy_merged_nanofilt.fastq

## Results after U -> T substitutions
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_noUs.fastq \
    $READS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_noUs.fastq \
    $READS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_noUs.fastq

## Extra sequencing statistics
NanoStat \
    --readtype 1D \
    --fastq $READS_OUTPUT_DIR/ont_guppy_merged_nanofilt.fastq \
    > $READS_OUTPUT_DIR/ont_guppy_merged_nanofilt_nanostat.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/ont_guppy_merged_nanofilt.fastq \
    qin=33 \
    out=$READS_OUTPUT_DIR/ont_guppy_merged_nanofilt_bbtools.txt
