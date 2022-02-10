#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=compare_proteotypic_specific_peptides-%j.out

############################################################## 

# Script Name:        compare_proteotypic_specific_peptides.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for counting the number of unique / common
#              proteotypic-specific peptides identified in MS/MS ion searches.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

comparePeptides() {
    local ontFilePath=$1
    local illuminaFilePath=$2
    local outputFilePrefix=$3

    python $SCRIPTS_DIR/dev/compare_peptides.py \
        --inputfile $ontFilePath \
            $illuminaFilePath \
        --outputcount $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_proteotypic_specific_peptide_count.txt \
        --outputdata $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_proteotypic_specific_peptide_data.txt
}

############################ Main #############################

echo "Comparing proteotypic-specific peptides"

comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk


comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Bases1
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Bases2
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Bases3
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Bases4
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Bases5


comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Reads1
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Reads2
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Reads3
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Reads4
comparePeptides \
    $PROTEOMES_OUTPUT_DIR/ont_proteotypic_specific_peptides.txt \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_proteotypic_specific_peptides.txt \
    ont_vs_illumina_R1_bbduk_Reads5
