#!/bin/bash

###############################################################

# Script Name:        ont_convert_searches.sh
# Author:             Aidan Tay

# Description: Pipeline for converting MS/MS ion search results from
#              ProteomeDiscoverer into Mascot DAT files for use in the PG Nexus.
#              Searches were performed against sequences derived from
#              Oxford Nanopore MinION transcripts.

################### Workspace & Notes #########################

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

echo "Converting ProteomeDiscoverer searches"

filterSearches $PROTEOME_DATA_DIR/pd/ont/ont_PSMs.txt \
    $PROTEOME_DATA_DIR/pd/ont/ont_PeptideGroups.txt \
    $PROTEOME_DATA_DIR/pd/ont/ont_Proteins.txt
