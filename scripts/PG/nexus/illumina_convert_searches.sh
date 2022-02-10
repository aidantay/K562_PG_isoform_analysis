#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=illumina_convert_searches-%j.out

###############################################################

# Script Name:        illumina_convert_searches.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for converting MS/MS ion search results from
#              ProteomeDiscoverer into Mascot DAT files for use in the PG Nexus.
#              Searches were performed against sequences derived from
#              Illumina NextSeq transcripts.

################### Workspace & Notes #########################

## We also:
## * Remove PSMs, Peptides & Proteins < 1% FDR
## * Remove peptides that mapped to contaminant proteins
## * Remove duplicate peptide sequences

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

filterSearches() {
    local psmFilepath=$1
    local peptideFilepath=$2
    local proteinFilepath=$3

    local inputFilePrefix=$(basename ${proteinFilepath} | sed "s|.txt||g")
    local outputFilePrefix=${inputFilePrefix}_Peptides_PSMs
    local outputFilepath=$SEARCHES_OUTPUT_DIR/${outputFilePrefix}.dat

    python $SCRIPTS_DIR/dev/convert_PD_to_dat.py \
        --psmfile $psmFilepath \
        --peptidefile $peptideFilepath \
        --proteinfile $proteinFilepath \
        --outputfile $outputFilepath
}

############################ Main #############################

echo "Filtering ProteomeDiscoverer searches"

filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk/illumina_R1_bbduk_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk/illumina_R1_bbduk_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk/illumina_R1_bbduk_Proteins.txt

filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases1/illumina_R1_bbduk_Bases1_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases1/illumina_R1_bbduk_Bases1_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases1/illumina_R1_bbduk_Bases1_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases2/illumina_R1_bbduk_Bases2_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases2/illumina_R1_bbduk_Bases2_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases2/illumina_R1_bbduk_Bases2_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases3/illumina_R1_bbduk_Bases3_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases3/illumina_R1_bbduk_Bases3_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases3/illumina_R1_bbduk_Bases3_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases4/illumina_R1_bbduk_Bases4_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases4/illumina_R1_bbduk_Bases4_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases4/illumina_R1_bbduk_Bases4_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases5/illumina_R1_bbduk_Bases5_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases5/illumina_R1_bbduk_Bases5_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Bases5/illumina_R1_bbduk_Bases5_Proteins.txt

filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads1/illumina_R1_bbduk_Reads1_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads1/illumina_R1_bbduk_Reads1_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads1/illumina_R1_bbduk_Reads1_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads2/illumina_R1_bbduk_Reads2_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads2/illumina_R1_bbduk_Reads2_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads2/illumina_R1_bbduk_Reads2_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads3/illumina_R1_bbduk_Reads3_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads3/illumina_R1_bbduk_Reads3_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads3/illumina_R1_bbduk_Reads3_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads4/illumina_R1_bbduk_Reads4_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads4/illumina_R1_bbduk_Reads4_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads4/illumina_R1_bbduk_Reads4_Proteins.txt
filterSearches $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads5/illumina_R1_bbduk_Reads5_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads5/illumina_R1_bbduk_Reads5_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/illumina/illumina_R1_bbduk_Reads5/illumina_R1_bbduk_Reads5_Proteins.txt
