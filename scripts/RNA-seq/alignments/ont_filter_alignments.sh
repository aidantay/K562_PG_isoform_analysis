#!/bin/bash

##############################################################

# Script Name:        ont_filter_alignments.sh
# Author:             Aidan Tay

# Description: Pipeline for getting high-confidence alignments.
#              This is done by filtering out secondary alignments
#              of RNA-seq FASTQ reads from Oxford Nanopore MinION

################### Workspace & Notes #########################

# samtools/1.10.0

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

filterAlignments() {
    local filepath=$1

    filteredFilepath=$(removeAlignments $filepath)
    sortedFilepath=$(sortAlignments $filteredFilepath)

    addMDTag $sortedFilepath    ## For calculating the alignment accuracy
    convertAlignments $sortedFilepath
    indexAlignments $sortedFilepath
}

removeAlignments() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.bam||g")

    local outputFilePrefix=${inputFilePrefix}_filtered
    local outputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.sam

    ## Remove unmapped reads
    samtools view \
        -h \
        -F 4 \
        $inputFilepath \
        > $ALIGNMENTS_OUTPUT_DIR/mapped.sam

    ## Remove secondary alignments
    samtools view \
        -h \
        -F 256 \
        $ALIGNMENTS_OUTPUT_DIR/mapped.sam \
        > $outputFilepath

    ## Remove the temporary file
    rm $ALIGNMENTS_OUTPUT_DIR/mapped.sam

    echo $outputFilepath
}

sortAlignments() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.sam||g")

    local outputFilePrefix=${inputFilePrefix}_sorted
    local outputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.sam

    samtools sort \
         -@ 16 \
         -o $outputFilepath \
         < $inputFilepath

    echo $outputFilepath
}

addMDTag() {
    local inputFilepath=$1

    echo "Adding MD Tag"
    samtools calmd \
        -@ 16 \
        $inputFilepath \
        $GENOME_DATA_DIR/fasta/all_chromosomes.fa \
        > $ALIGNMENTS_OUTPUT_DIR/updated.sam

    mv $ALIGNMENTS_OUTPUT_DIR/updated.sam $inputFilepath
}

convertAlignments() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.sam||g")
    local outputFilePrefix=${inputFilePrefix}

    samtools view \
        -b \
        -@ 16 \
        -o $ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.bam \
        < $inputFilepath
}

indexAlignments() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.sam||g")
    local outputFilePrefix=${inputFilePrefix}

    samtools index \
        -@ 16 \
        $ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.bam
}

############################ Main #############################

echo "Filtering alignments"

filterAlignments $ALIGNMENTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap.bam
