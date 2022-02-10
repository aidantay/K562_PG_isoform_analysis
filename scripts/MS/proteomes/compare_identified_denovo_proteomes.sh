#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=compare_identified_denovo_proteomes-%j.out

############################################################## 

# Script Name:        compare_identified_denovo_proteomes.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for counting the number of unique / common
#              novel (de novo) proteins identified in MS/MS ion searches.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

compareIdentifiedProteomes() {
    local ensemblGtfFilePath=$1
    local ontGtfFilePath=$2
    local illuminaGtfFilePath=$3
    local outputFilePrefix=$4

    compareIdentifiedProteins proteoform $ensemblGtfFilePath $ontGtfFilePath \
        $illuminaGtfFilePath ${outputFilePrefix}_proteoform
}

compareIdentifiedProteins() {
    local metric=$1
    local ensemblGtfFilePath=$2
    local ontGtfFilePath=$3
    local illuminaGtfFilePath=$4
    local outputFilePrefix=$5

    python $SCRIPTS_DIR/dev/compare_proteomes.py \
        --gxf $ensemblGtfFilePath \
              $ontGtfFilePath \
              $illuminaGtfFilePath \
        --refgxf $ensemblGtfFilePath \
        --metric $metric \
        --format novel \
        --outputcount $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_count.txt \
        --outputdata $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_data.txt
}

############################ Main #############################

echo "Comparing identified proteomes"

compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_denovo



compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Bases1_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Bases2_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Bases3_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Bases4_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Bases5_denovo



compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Reads1_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Reads2_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Reads3_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Reads4_denovo
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont_proteoforms.gtf \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_proteoforms.gtf \
    ont_vs_illumina_R1_bbduk_Reads5_denovo
