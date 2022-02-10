#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=ont_identify_proteins-%j.out

############################################################## 

# Script Name:        ont_identify_proteins.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for identifying proteins
#              based on peptides identified in MS/MS searches against
#              sequences derived from Oxford Nanopore MinION transcripts.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

identifyProteins() {
    local proteotypicFilePath=$1
    local specificDirPath=$2
    local gxfFilePath=$3
    local outputFilePrefix=$4

    ## Get peptide summary - Join proteotypic and specific tables
    psFilePath=$(getPeptideSummary $proteotypicFilePath $specificDirPath $outputFilePrefix)

    ## Create a GXF file containing identified proteins / proteoforms
    getProteins $gxfFilePath $psFilePath $outputFilePrefix
    getProteoforms $gxfFilePath $psFilePath $outputFilePrefix
}

getPeptideSummary() {
    local proteotypicFilePath=$1
    local specificDirPath=$2
    local outputFilePrefix=$3

    ## Setup some temporary files
    local outputFilePrefix=${outputFilePrefix}_peptide_summary
    local outputFilePath=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}.txt

    python util/get_peptides.py \
        --proteotypic $proteotypicFilePath \
        --specific $specificDirPath/*.csv \
        --outputfile $outputFilePath

    echo $outputFilePath
}

getProteins() {
    local gxfFilePath=$1
    local psFilePath=$2
    local outputFilePrefix=$3

    local outputFilePrefix=${outputFilePrefix}_proteins
    local outputFilePath=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}.gtf

    ## Setup some temporary files (for parallelisation)
    local temp1=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_temp1
    local temp2=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_temp2

    ## Find all proteins we identified
    cut -f1 $psFilePath | tail -n +2 \
        | sed 's/_[0-9]\+$//g' \
        | sed 's/$/"/g' | sed 's/^/"/g' \
        | sed 's/_/./g' | sort | uniq \
        > ${temp1}.txt
    grep -Ff ${temp1}.txt ${gxfFilePath} > ${temp2}.txt

    ## Reheader GTF file
    grep '^#' ${gxfFilePath} > ${temp1}.txt
    cat ${temp1}.txt ${temp2}.txt > ${outputFilePath}

    ## Clean up
    rm ${PROTEOMES_OUTPUT_DIR}/${outputFilePrefix}_temp*
}

getProteoforms() {
    local gxfFilePath=$1
    local psFilePath=$2
    local outputFilePrefix=$3
    local pspFilePath=$(getProteotypicSpecificPeptides $psFilePath $outputFilePrefix)

    local outputFilePrefix=${outputFilePrefix}_proteoforms
    local outputFilePath=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}.gtf

    ## Setup some temporary files (for parallelisation)
    local temp1=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_temp1
    local temp2=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_temp2

    ## Find all proteoforms we identified
    cut -f1 $pspFilePath | tail -n +2 \
        | sed 's/$/"/g' | sed 's/^/"/g' \
        | sed 's/_/./g' | sort | uniq \
        > ${temp1}.txt
    grep -Ff ${temp1}.txt ${gxfFilePath} > ${temp2}.txt

    ## Reheader GTF file
    grep '^#' ${gxfFilePath} > ${temp1}.txt
    cat ${temp1}.txt ${temp2}.txt > ${outputFilePath}

    ## Clean up
    rm ${PROTEOMES_OUTPUT_DIR}/${outputFilePrefix}_temp*
}

getProteotypicSpecificPeptides() {
    local psFilePath=$1
    local outputFilePrefix=$2

    local outputFilePrefix=${outputFilePrefix}_proteotypic_specific_peptides
    local outputFilePath=$PROTEOMES_OUTPUT_DIR/${outputFilePrefix}.txt

    awk '$3>0.9' $psFilePath | cut -f1,2,5 \
        | grep -v 'False' | sed 's/_[0-9]\+\t/\t/g' \
        | cut -f1,2 | sort | uniq \
        > $outputFilePath

    echo $outputFilePath
}

############################ Main #############################

echo "Identifying proteins"

identifyProteins \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered_proteotypic.txt \
    $PEPTIDES_OUTPUT_DIR/ont_peptides_filtered_specificity \
    $TRANSCRIPTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie.gtf \
    ont
