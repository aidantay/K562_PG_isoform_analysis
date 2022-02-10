#!/bin/bash

############################################################## 

# Script Name:        ont_align_peptides.sh
# Author:             Aidan Tay

# Description: Pipeline for running PG Nexus pipeline using
#              the results of MS/MS ion searches.
#              Searches were performed against sequences derived from
#              Oxford Nanopore MinION transcripts.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

alignPeptides() {
    local datFilepath=$1
    local gffFilepath=$2
    local accFilepath=$3

    runSamifier $datFilepath $gffFilepath $accFilepath
    runResultsAnalyser $datFilepath $gffFilepath $accFilepath
}

runSamifier() {
    local datFilepath=$1
    local gffFilepath=$2
    local accFilepath=$3

    local inputFilePrefix=$(basename ${gffFilepath} | sed "s|.gff||g")
    local outputFilePrefix=${inputFilePrefix}_samifier

    java -jar $NEXUS_DIR/dist/samifier.jar \
        -c $GENOME_DATA_DIR/fasta/chromosomes_relabeled \
        -g $gffFilepath \
        -m $accFilepath \
        -r $datFilepath \
        -b $NEXUS_OUTPUT_DIR/${outputFilePrefix}.bed \
        -l $NEXUS_OUTPUT_DIR/${outputFilePrefix}.log \
        -o $NEXUS_OUTPUT_DIR/${outputFilePrefix}.sam

    sed 's/chr//g' -i $NEXUS_OUTPUT_DIR/${outputFilePrefix}.sam
}

runResultsAnalyser() {
    local datFilepath=$1
    local gffFilepath=$2
    local accFilepath=$3

    local inputFilePrefix=$(basename ${gffFilepath} | sed "s|.gff||g")
    local outputFilePrefix=${inputFilePrefix}_results_analyser

    java -jar $NEXUS_DIR/dist/results_analyser.jar \
        -c $GENOME_DATA_DIR/fasta/chromosomes_relabeled \
        -g $gffFilepath \
        -m $accFilepath \
        -r $datFilepath \
        -o $NEXUS_OUTPUT_DIR/${outputFilePrefix}.txt
}

############################ Main #############################

echo "Aligning peptides"

alignPeptides $SEARCHES_OUTPUT_DIR/ont_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/ont.gff \
    $DATABASES_OUTPUT_DIR/ont.txt
