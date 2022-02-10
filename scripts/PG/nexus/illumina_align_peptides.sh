#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=illumina_align_peptides-%j.out

############################################################## 

# Script Name:        illumina_align_peptides.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for running PG Nexus pipeline using
#              the results of MS/MS ion searches.
#              Searches were performed against sequences derived from
#              Illumina NextSeq transcripts.

################### Workspace & Notes #########################

################### Dependencies ##############################

module load amazon-corretto/8.262.10.1
export _JAVA_OPTIONS="-Xmx128g -XX:+UseSerialGC"

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

alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk.txt



alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases1.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases1.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases2.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases2.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases3.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases3.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases4.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases4.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases5.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases5.txt



alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads1.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads1.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads2.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads2.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads3.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads3.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads4.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads4.txt
alignPeptides $SEARCHES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_Proteins_Peptides_PSMs.dat \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads5.gff \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads5.txt
