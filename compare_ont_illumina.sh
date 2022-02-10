#!/bin/bash

##############################################################

# Script Name:        compare_ont_illumina.sh
# Author:             Aidan Tay

# Description: Script for comparing results of analyses with
#              Oxford Nanopore MinION RNA-seq data and
#              Illumina NextSeq RNA-seq data

################### Workspace & Notes #########################

## Comparisons between long direct reads and short paired-end reads
## must be done AFTER each individual analysis.

################### Dependencies ##############################

set -e

. scripts/config.sh

################### Global Variables ##########################

################### Functions #################################

############################ Main #############################

## Compare novel transcripts (Custom script)
. scripts/RNA-seq/transcriptomes/compare_identified_denovo_transcriptomes.sh

## Compare Ensembl transcripts (custom script)
. scripts/RNA-seq/transcriptomes/compare_identified_ensembl_transcriptome.sh

##########
##########
##########

## Compare peptides (Custom script)
. MS/peptides/compare_peptides.sh

## Compare isoform-specific proteotypic peptides (Custom script)
. MS/proteomes/compare_proteotypic_specific_peptides.sh

## Compare novel proteins and proteoforms (Custom script)
. MS/proteomes/compare_identified_denovo_proteomes.sh

## Compare Ensembl proteins and proteoforms (Custom script)
. MS/proteomes/compare_identified_ensembl_proteomes.sh
