#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=128gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --output=illumina_classify_peptides-%j.out

############################################################## 

# Script Name:        illumina_classify_peptides.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for classifing peptide identified in MS/MS searches
#              against sequences derived from Illumina NextSeq transcripts.

################### Workspace & Notes #########################

## Unlike the other scripts, this script cannot be run automatically
## since we need to run PeptideSieve in Windows.

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

classifyPeptides() {
    local inputFilepath=$1
    local databaseFilepath=$2

    classifyProteotypicPeptides $inputFilepath
    classifySpecificPeptides $inputFilepath $databaseFilepath
}

classifyProteotypicPeptides() {
    local inputFilepath=$1

    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.txt||g")
    local outputFilePrefix=${inputFilePrefix}_proteotypic
    local outputFilepath=$PEPTIDES_OUTPUT_DIR/${outputFilePrefix}_temp.txt

    ## Proteotypic peptides are identified using the PeptideSieve software
    ## which is run via Windows command line with the following:
    cut -f1,5 $inputFilepath | tail -n +2 | sort | uniq | sort > ${outputFilepath}

    # ..\..\..\software\peptideSieve\PeptideSieve.exe ^
    #     -P ..\..\..\software\peptideSieve\properties.txt ^
    #     -o ..\..\..\output\MS\peptides\illumina_R1_bbduk_peptides_filtered_proteotypic.txt ^
    #     -f TXT ^
    #     -d PAGE_ESI ^
    #     -p 0.00 ^
    #     ..\..\..\output\MS\peptides\illumina_R1_bbduk_peptides_filtered_proteotypic_temp.txt
}

classifySpecificPeptides() {
    local inputFilepath=$1
    local databaseFilepath=$2

    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.txt||g")
    local outputFilePrefix=${inputFilePrefix}_specificity
    local outputDirpath=$PEPTIDES_OUTPUT_DIR/${outputFilePrefix}

    python $SCRIPTS_DIR/dev/identify_proteoform_specific_peptides.py \
        --inputfile $inputFilepath \
        --fastx $databaseFilepath \
        --outputfile $outputDirpath
}

############################ Main #############################

echo "Classifying peptides"

classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk.fasta


classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases1.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases2.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases3.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases4.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Bases5.fasta


classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads1.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads2.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads3.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads4.fasta
classifyPeptides \
    $PEPTIDES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_peptides_filtered.txt \
    $DATABASES_OUTPUT_DIR/illumina_R1_bbduk_Reads5.fasta
