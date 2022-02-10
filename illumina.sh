#!/bin/bash

##############################################################

# Script Name:        illumina.sh
# Author:             Aidan Tay

# Description: Script for analysing Illumina NextSeq RNA-seq data.

################### Workspace & Notes #########################

# Transcriptome assembly of short paired-end reads
# required several tools:
# * BBTools (bbduk.sh, readlength.sh)
# * FastQC
# * HISAT2
# * Samtools
# * StringTie
# See individual scripts for more info

# Querying proteomic data of K562 cells against assembled transcriptome
# required several tools:
# * RAWConverter
# * Proteome Discoverer
# * PeptideSieve
# See individual scripts for more info

# Co-analysis and co-visualisation of proteomic and transcriptomic
# data required several tools:
# * PG Nexus (Samifier & Results_analyser)
# * IGV
# See individual scripts for more info

################### Dependencies ##############################

set -e

. scripts/config.sh

################### Global Variables ##########################

################### Functions #################################

############################ Main #############################

## Construct directories to hold all the data we create
mkdir -p $READS_OUTPUT_DIR
mkdir -p $ALIGNMENTS_OUTPUT_DIR
mkdir -p $TRANSCRIPTS_OUTPUT_DIR

## Read filtering with BBTools (bbduk.sh) and subsampling with seqtk
. RNA-seq/reads/illumina_filter_reads.sh

## Read quality analysis with FastQC & BBTools (readlength.sh)
. RNA-seq/reads/illumina_analyse_reads.sh

## Read alignment to reference genome with HISAT2
. RNA-seq/alignments/illumina_align_reads.sh

## Alignment filtering with Samtools
. RNA-seq/alignments/illumina_filter_alignments.sh

## Alignment quality analysis (Custom script)
. RNA-seq/alignments/illumina_analyse_alignments.sh

## Reference-based transcriptome assembly with StringTie
. RNA-seq/transcripts/illumina_construct_transcripts.sh

## Identify novel transcripts (Custom script)
. RNA-seq/transcriptomes/illumina_identify_denovo_transcripts.sh

## Identify Ensembl transcripts (Custom script)
. RNA-seq/transcriptomes/illumina_identify_ensembl_transcripts.sh

##########
##########
##########

## Construct directories to hold all the data we create
mkdir -p $DATABASES_OUTPUT_DIR
mkdir -p $PEPTIDES_OUTPUT_DIR
mkdir -p $PROTEOMES_OUTPUT_DIR

## Construct protein sequence database from assembled transcripts (Custom script)
. MS/database/illumina_construct_database.sh

## **********
## *** Raw files from MS converted into
## *** Mascot Generic Format (MGF) using RawConverter UI
## **********

## **********
## *** MS/MS searches against RNA-seq derived databases
## *** performed on ProteomeDiscoverer
## **********

## Peptide filtering
. MS/peptides/illumina_filter_peptides.sh

## Determine peptide specificity (Custom script) and proteotypic (PeptideSieve)
. MS/peptides/illumina_classify_peptides.sh

## Identify (novel & Ensembl) proteins and proteoforms (Custom script)
. MS/proteomes/illumina_identify_proteins.sh

##########
##########
##########

## Construct directories to hold all the data we create
mkdir -p $NEXUS_OUTPUT_DIR

## Convert Proteome Discoverer output to Mascot .dat (Custom script)
. nexus/searches/illumina_convert_searches.sh

## Co-analyse peptides and RNA-seq reads with Samifier and ResultsAnalyser
. nexus/searches/illumina_align_peptides.sh

## **********
## *** Co-visualise peptides and RNA-seq reads using IGV
## **********
