#!/bin/bash

#------------------------------------------------------------------------------

## Run this script before running any batch scripts in this project.

#------------------- Dependencies ---------------------------#

## External dependencies

## Internal dependencies

#------------------- Global Variables -----------------------#

## Core directories
DATA_DIR=${PWD}/data
OUTPUT_DIR=${PWD}/output

## Data directories
GENOME_DATA_DIR=${DATA_DIR}/data/genomes
PROTEOME_DATA_DIR=${DATA_DIR}/data/proteomes
TRANSCRIPTOME_DATA_DIR=${DATA_DIR}/data/transcriptomes

## Output directories
RNASEQ_OUTPUT_DIR=${OUTPUT_DIR}/RNA-seq
MS_OUTPUT_DIR=${OUTPUT_DIR}/MS
PG_OUTPUT_DIR=${OUTPUT_DIR}/PG

## Result directories
READS_OUTPUT_DIR=${RNASEQ_OUTPUT_DIR}/reads
ALIGNMENTS_OUTPUT_DIR=${RNASEQ_OUTPUT_DIR}/alignments
TRANSCRIPTS_OUTPUT_DIR=${RNASEQ_OUTPUT_DIR}/transcripts
TRANSCRIPTOMES_OUTPUT_DIR=${RNASEQ_OUTPUT_DIR}/transcriptomes

DATABASES_OUTPUT_DIR=${MS_OUTPUT_DIR}/databases
PEPTIDES_OUTPUT_DIR=${MS_OUTPUT_DIR}/peptides
PROTEOMES_OUTPUT_DIR=${MS_OUTPUT_DIR}/proteomes

NEXUS_OUTPUT_DIR=${PG_OUTPUT_DIR}/nexus

#------------------- Classes & Functions --------------------#

#------------------- Main -----------------------------------#

###############################################################################
