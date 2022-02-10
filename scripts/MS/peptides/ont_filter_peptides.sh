#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=128gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --output=ont_filter_peptides-%j.out

############################################################## 

# Script Name:        ont_filter_peptides.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for filtering peptides identified in MS/MS searches
#              against sequences derived from Oxford Nanopore MinION transcripts.

################### Workspace & Notes #########################

## We:
## * Remove PSMs, Peptides & Proteins < 1% FDR
## * Remove peptides that mapped to contaminant proteins
## * Remove duplicate peptide sequences

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

filterPeptides() {
    local psmFilepath=$1
    local peptideFilepath=$2
    local proteinFilepath=$3

    local inputFilePrefix=$(basename ${proteinFilepath} | sed "s|_Proteins.txt||g")
    local outputFilePrefix=${inputFilePrefix}_peptides_filtered
    local outputFilepath=$PEPTIDES_OUTPUT_DIR/${outputFilePrefix}.txt

    python $SCRIPTS_DIR/dev/filter_PD.py \
        --psmfile $psmFilepath \
        --peptidefile $peptideFilepath \
        --proteinfile $proteinFilepath \
        --outputfile $outputFilepath
}

############################ Main #############################

echo "Filtering peptides"

filterPeptides \
    $PROTEOME_DATA_DIR/pd/ont/ont_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/ont/ont_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/ont/ont_Proteins.txt
