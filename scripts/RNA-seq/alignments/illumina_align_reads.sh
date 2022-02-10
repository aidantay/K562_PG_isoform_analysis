#!/bin/bash

##############################################################

# Script Name:        illumina_align_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for aligning RNA-seq FASTQ reads
#              from Illumina NextSeq onto a human
#              reference genome / transcriptome

################### Workspace & Notes #########################

################### Dependencies ##############################

# hisat/2.1.0
# samtools/1.10.0

################### Global Variables ##########################

################### Functions #################################

alignReads() {
    local inputLFilepath=$1
    local inputRFilepath=$2
    local inputFilePrefix=$(basename ${inputLFilepath} | sed "s|.fastq||g")

    local outputFilePrefix=${inputFilePrefix}_hisat
    local samOutputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.sam
    local bamOutputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.bam

    hisat2 \
        --rna-strandness RF \
        --dta \
        --known-splicesite-infile Homo_sapiens.GRCh38.100.chr.ss \
        -p 16 \
        -x $GENOME_DATA_DIR/fasta/all_chromosomes \
        -1 $inputLFilepath \
        -2 $inputRFilepath \
        -S $samOutputFilepath

    samtools view \
        -b \
        -@ 16 \
        -o $bamOutputFilepath \
        < $samOutputFilepath
}

############################ Main #############################

echo "Aligning FASTQ reads"

alignReads $READS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk.fastq $READS_OUTPUT_DIR/LAI4430_S1_L001_R2_001_bbduk.fastq
alignReads $READS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk.fastq $READS_OUTPUT_DIR/LAI4430_S1_L002_R2_001_bbduk.fastq
alignReads $READS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk.fastq $READS_OUTPUT_DIR/LAI4430_S1_L003_R2_001_bbduk.fastq
alignReads $READS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk.fastq $READS_OUTPUT_DIR/LAI4430_S1_L004_R2_001_bbduk.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk.fastq

alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases1.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases1.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases2.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases2.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases3.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases3.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases4.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases4.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Bases5.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Bases5.fastq

alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads1.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads1.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads2.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads2.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads3.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads3.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads4.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads4.fastq
alignReads $READS_OUTPUT_DIR/illumina_R1_bbduk_Reads5.fastq $READS_OUTPUT_DIR/illumina_R2_bbduk_Reads5.fastq
