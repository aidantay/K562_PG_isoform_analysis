#!/bin/bash

##############################################################

# Script Name:        illumina_analyse_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for analysing the quality of
#              RNA-seq FASTQ reads from Illumina NextSeq

################### Workspace & Notes #########################

################### Dependencies ##############################

# fastqc/0.11.8
# bbtools/38.37

################### Global Variables ##########################

################### Functions #################################

#################### Main #####################################

## Results before filtering
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L001_R1_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L001_R2_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L002_R1_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L002_R2_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L003_R1_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L003_R2_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L004_R1_001.fastq.gz \
    $TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L004_R2_001.fastq.gz

## Results after filtering
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L001_R2_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L002_R2_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L003_R2_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk.fastq \
    $READS_OUTPUT_DIR/LAI4430_S1_L004_R2_001_bbduk.fastq

## Results after merging
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk.fastq \

## Extra sequencing statistics
readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_bbtools.txt

## Results of subsampling by bases
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases1.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases1.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases2.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases2.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases3.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases3.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases4.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases4.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases5.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases5.fastq \

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Bases1.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Bases1.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Bases1_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Bases2.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Bases2.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Bases2_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Bases3.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Bases3.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Bases3_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Bases4.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Bases4.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Bases4_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Bases5.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Bases5.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Bases5_bbtools.txt


## Results of subsampling by reads
fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads1.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads1.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads2.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads2.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads3.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads3.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads4.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads4.fastq \

fastqc \
    --outdir $READS_OUTPUT_DIR \
    --threads 16 \
    $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads5.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads5.fastq \

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Reads1.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Reads1.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Reads1_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Reads2.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Reads2.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Reads2_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Reads3.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Reads3.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Reads3_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Reads4.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Reads4.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Reads4_bbtools.txt

readlength.sh \
    in=$READS_OUTPUT_DIR/illumina_R1_bbduk_Reads5.fastq \
    in2=$READS_OUTPUT_DIR/illumina_R2_bbduk_Reads5.fastq \
    out=$READS_OUTPUT_DIR/illumina_bbduk_Reads5_bbtools.txt
