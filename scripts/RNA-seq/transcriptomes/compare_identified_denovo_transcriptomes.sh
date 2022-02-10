#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --output=compare_identified_denovo_transcriptomes-%j.out

##############################################################

# Script Name:        compare_identified_denovo_transcriptomes.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018

# Description: Pipeline for counting the number of unique / common
#              novel (de novo) trancripts and transcripts derived from alignments
#              of RNA-seq FASTA reads from Illumina NextSeq
#              and Oxford Nanopore MinION

################### Workspace & Notes #########################

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

compareIdentifiedTranscriptomes() {
    local ontGtfFilePath=$1
    local illuminaGtfFilePath=$2
    local outputFilePrefix=$3

    compareIdentifiedTranscripts transcript $ontGtfFilePath \
        $illuminaGtfFilePath $outputFilePrefix
}

compareIdentifiedTranscripts() {
    local metric=$1
    local ontGtfFilePath=$2
    local illuminaGtfFilePath=$3
    local outputFilePrefix=$4

    python $SCRIPTS_DIR/dev/compare_transcriptomes.py \
        --gxf $ontGtfFilePath \
              $illuminaGtfFilePath \
        --metric $metric \
        --outputcount $TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_identified_counts.txt \
        --outputdata $TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_identified_data.txt
}

############################ Main #############################

echo "Comparing identified novel (de novo) transcriptomes"

compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_denovo

compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases1_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Bases1_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases2_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Bases2_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases3_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Bases3_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases4_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Bases4_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Bases5_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Bases5_denovo

compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads1_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Reads1_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads2_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Reads2_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads3_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Reads3_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads4_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Reads4_denovo
compareIdentifiedTranscriptomes \
    $TRANSCRIPTOMES_OUTPUT_DIR/ont_denovo_transcripts.gtf \
    $TRANSCRIPTOMES_OUTPUT_DIR/illumina_R1_bbduk_Reads5_denovo_transcripts.gtf \
    ont_vs_illumina_R1_bbduk_Reads5_denovo