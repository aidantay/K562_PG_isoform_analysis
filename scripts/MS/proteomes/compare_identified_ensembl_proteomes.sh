#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=compare_identified_ensembl_proteomes-%j.out

############################################################## 

# Script Name:        compare_identified_ensembl_proteomes.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for counting the number of unique / common
#              known (Ensembl) proteins identified in MS/MS ion searches.

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

compareIdentifiedProteomes() {
    local ensemblGtfFilePath=$1
    local ontFilePrefix=$2
    local illuminaFilePrefix=$3
    local outputFilePrefix=$4

    ontGtfFilePath=${ontFilePrefix}_proteins.gtf
    illuminaGtfFilePath=${illuminaFilePrefix}_proteins.gtf
    compareIdentifiedProteins protein $ensemblGtfFilePath $ontGtfFilePath \
        $illuminaGtfFilePath ${outputFilePrefix}_protein

    ontGtfFilePath=${ontFilePrefix}_proteoforms.gtf
    illuminaGtfFilePath=${illuminaFilePrefix}_proteoforms.gtf
    compareIdentifiedProteins proteoform $ensemblGtfFilePath $ontGtfFilePath $ontPepFilePath \
        $illuminaGtfFilePath $illuminaPepFilePath ${outputFilePrefix}_proteoform

    compareIdentifiedProteins asproteoform $ensemblGtfFilePath $ontGtfFilePath $ontPepFilePath \
        $illuminaGtfFilePath $illuminaPepFilePath ${outputFilePrefix}_asproteoform

    compareIdentifiedProteins asgene $ensemblGtfFilePath $ontGtfFilePath $ontPepFilePath \
        $illuminaGtfFilePath $illuminaPepFilePath ${outputFilePrefix}_asgene
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
        --format known \
        --outputcount $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_count.txt \
        --outputdata $PROTEOMES_OUTPUT_DIR/${outputFilePrefix}_data.txt
}

############################ Main #############################

echo "Comparing identified proteomes"

compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk \
    ont_vs_illumina_R1_bbduk_ensembl



compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases1 \
    ont_vs_illumina_R1_bbduk_Bases1_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases2 \
    ont_vs_illumina_R1_bbduk_Bases2_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases3 \
    ont_vs_illumina_R1_bbduk_Bases3_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases4 \
    ont_vs_illumina_R1_bbduk_Bases4_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases5 \
    ont_vs_illumina_R1_bbduk_Bases5_ensembl



compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads1 \
    ont_vs_illumina_R1_bbduk_Reads1_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads2 \
    ont_vs_illumina_R1_bbduk_Reads2_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads3 \
    ont_vs_illumina_R1_bbduk_Reads3_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads4 \
    ont_vs_illumina_R1_bbduk_Reads4_ensembl
compareIdentifiedProteomes \
    $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    $PROTEOMES_OUTPUT_DIR/ont \
    $PROTEOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads5 \
    ont_vs_illumina_R1_bbduk_Reads5_ensembl
