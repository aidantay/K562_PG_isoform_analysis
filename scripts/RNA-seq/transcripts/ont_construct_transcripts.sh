#!/bin/bash

##############################################################

# Script Name:        ont_construct_transcripts.sh
# Author:             Aidan Tay

# Description: Pipeline for constructing transcripts based on the
#              the alignment of RNA-seq FASTQ reads from
#              Oxford Nanopore MinION

################### Workspace & Notes #########################

################### Dependencies ##############################

# stringtie/1.3.4d

################### Global Variables ##########################

################### Functions #################################

############################ Main #############################

echo "Constructing transcripts"

stringtie \
    -G $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    -p 16 \
    --fr \
    -C $TRANSCRIPTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_ref_transcripts.txt \
    -A $TRANSCRIPTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_gene_abundance.txt \
    -o $TRANSCRIPTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie.gtf \
    $ALIGNMENTS_OUTPUT_DIR/ADM5153_5056_guppy_merged_nanofilt_minimap_filtered_sorted.bam

stringtie \
    -G $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    -p 16 \
    --fr \
    -C $TRANSCRIPTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_ref_transcripts.txt \
    -A $TRANSCRIPTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_gene_abundance.txt \
    -o $TRANSCRIPTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie.gtf \
    $ALIGNMENTS_OUTPUT_DIR/LAI4430_guppy_merged_nanofilt_minimap_filtered_sorted.bam

stringtie \
    -G $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    -p 16 \
    --fr \
    -C $TRANSCRIPTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_ref_transcripts.txt \
    -A $TRANSCRIPTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_gene_abundance.txt \
    -o $TRANSCRIPTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie.gtf \
    $ALIGNMENTS_OUTPUT_DIR/LAI4712_guppy_merged_nanofilt_minimap_filtered_sorted.bam

stringtie \
    -G $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
    -p 16 \
    --fr \
    -C $TRANSCRIPTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_ref_transcripts.txt \
    -A $TRANSCRIPTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie_gene_abundance.txt \
    -o $TRANSCRIPTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted_stringtie.gtf \
    $ALIGNMENTS_OUTPUT_DIR/ont_guppy_merged_nanofilt_minimap_filtered_sorted.bam

