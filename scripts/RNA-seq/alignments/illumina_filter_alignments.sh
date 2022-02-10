#!/bin/bash

##############################################################

# Script Name:        illumina_filter_alignments.sh
# Author:             Aidan Tay

# Description: Pipeline for getting high-confidence alignments.
#              This is done by filtering out secondary alignments
#              of RNA-seq FASTQ reads from Illumina NextSeq

################### Workspace & Notes #########################

################### Dependencies ##############################

# samtools/1.10.0

################### Global Variables ##########################

################### Functions #################################

filterAlignments() {
    local filepath=$1

    filteredFilepath=$(removeAlignments $filepath)
    sortedFilepath=$(sortAlignments $filteredFilepath)
    convertAlignments $sortedFilepath
    indexAlignments $sortedFilepath
}

removeAlignments() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.bam||g")

    local outputFilePrefix=${inputFilePrefix}_filtered
    local outputFilepath=$ALIGNMENTS_OUTPUT_DIR/${outputFilePrefix}.sam

    ## Remove unmapped alignments
    local tmpLFilepath=$ALIGNMENTS_OUTPUT_DIR/tempLReads.sam
    samtools view -@ 16 -f 65 -h $inputFilepath > $tmpLFilepath
    local tmpLMappedFilepath=$ALIGNMENTS_OUTPUT_DIR/tempLReadsMapped.sam
    samtools view -@ 16 -G 69 -h $tmpLFilepath > $tmpLMappedFilepath

    local tmpRFilepath=$ALIGNMENTS_OUTPUT_DIR/tempRReads.sam
    samtools view -@ 16 -f 129 -h $inputFilepath > $tmpRFilepath
    local tmpRMappedFilepath=$ALIGNMENTS_OUTPUT_DIR/tempRReadsMapped.sam
    samtools view -@ 16 -G 137 -h $tmpRFilepath > $tmpRMappedFilepath

    ## Merge paired alignments
    local tmpPEMappedFilepath=$ALIGNMENTS_OUTPUT_DIR/tempPEMapped.sam
    samtools merge -@ 16 -c \
        $tmpPEMappedFilepath \
        $tmpLMappedFilepath $tmpRMappedFilepath

    ## Remove unproper paired alignments
    samtools view -@ 16 -f 3 -h $tmpPEMappedFilepath > $outputFilepath

    rm $ALIGNMENTS_OUTPUT_DIR/temp*.sam
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

filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_hisat.bam

filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat.bam

filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat.bam
filterAlignments $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat.bam
