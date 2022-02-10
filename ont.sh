#!/bin/bash

##############################################################

# Script Name:        ont.sh
# Author:             Aidan Tay

# Description: Script for analysing Oxford Nanopore MinION RNA-seq data.

################### Workspace & Notes #########################

# Transcriptome "assembly" of long direct reads
# requires several tools:
# * Guppy
# * FastQC
# * BBTools (readlength.sh)
# * NanoPack (NanoFilt & NanoStat)
# * minimap2
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

## Basecalling with Guppy
. scripts/RNA-seq/reads/ont_basecalling.sh

## Read trimming and filtering with NanoFilt
. scripts/RNA-seq/reads/ont_filter_reads.sh

## Read quality analysis with FastQC, BBTools (readlength.sh) and NanoStat
. scripts/RNA-seq/reads/ont_analyse_reads.sh

# Read alignment to reference genome with minimap2
. scripts/RNA-seq/alignments/ont_align_reads.sh

## Alignment filtering with Samtools
. scripts/RNA-seq/alignments/ont_filter_alignments.sh

## Alignment quality analysis (Custom script)
. scripts/RNA-seq/alignments/ont_analyse_alignments.sh

## Reference-based transcriptome "assembly" with StringTie
. scripts/RNA-seq/transcripts/ont_construct_transcripts.sh

## Identify novel transcripts (Custom script)
. scripts/RNA-seq/transcriptomes/ont_identify_denovo_transcripts.sh

## Identify Ensembl transcripts (custom script)
. scripts/RNA-seq/transcriptomes/ont_identify_ensembl_transcripts.sh

##########
##########
##########

## Construct directories to hold all the data we create
mkdir -p $DATABASES_OUTPUT_DIR
mkdir -p $PEPTIDES_OUTPUT_DIR
mkdir -p $PROTEOMES_OUTPUT_DIR

## Construct protein sequence database from "assembled" transcripts (Custom script)
. MS/database/ont_construct_database.sh

## **********
## *** Raw files from MS converted into
## *** Mascot Generic Format (MGF) using RawConverter UI
## **********

## **********
## *** MS/MS searches against RNA-seq derived databases
## *** performed on ProteomeDiscoverer
## **********

## Peptide filtering
. MS/peptides/ont_filter_peptides.sh

## Determine peptide specificity (Custom script) and proteotypic (PeptideSieve)
. MS/peptides/ont_classify_peptides.sh

## Identify (novel & Ensembl) proteins and proteoforms (Custom script)
. MS/proteomes/ont_identify_proteins.sh

##########
##########
##########

## Construct directories to hold all the data we create
mkdir -p $NEXUS_OUTPUT_DIR

## Convert Proteome Discoverer output to Mascot .dat (Custom script)
. nexus/searches/ont_convert_searches.sh

## Co-analyse peptides and RNA-seq reads with Samifier and ResultsAnalyser
. nexus/searches/ont_align_peptides.sh

## **********
## *** Co-visualise peptides and RNA-seq reads using IGV
## **********
