#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=compare_peptides-%j.out

############################################################## 

# Script Name:        compare_peptides.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for counting the number of unique / common peptides
#              identified in MS/MS ion searches.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

comparePeptides() {
    local ontFilepath=$1
    local illuminaFilepath=$2
    local outputFilePrefix=$3

    python $SCRIPTS_DIR/dev/compare_peptides.py \
        --inputfile $ontFilepath \
            $illuminaFilepath \
        --outputcount $PEPTIDES_OUTPUT_DIR/${outputFilePrefix}_peptide_count.txt \
        --outputdata $PEPTIDES_OUTPUT_DIR/${outputFilePrefix}_peptide_data.txt
}

############################ Main #############################

echo "Comparing peptides"

comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk


comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Bases1
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Bases2
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Bases3
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Bases4
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Bases5


comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Reads1
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Reads2
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Reads3
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Reads4
comparePeptides \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered.txt \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_peptides_filtered.txt \
    ont_vs_illumina_R1_bbduk_Reads5
