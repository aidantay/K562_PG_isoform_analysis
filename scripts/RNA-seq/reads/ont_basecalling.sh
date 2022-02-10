#!/bin/bash

##############################################################

# Script Name:        ont_basecalling.sh
# Author:             Aidan Tay

# Description: Script for running guppy (basecaller) on FAST5 files
#              from Oxford Nanopore MinION

################### Workspace & Notes #########################

#guppy_basecaller (1d basecaller)
# * Requires flowcell and kit number.

# Guppy version: ont-guppy-cpu_3.6.0_linux64.tar.gz

################### Dependencies ##############################

################### Global Variables ##########################

################### Functions #################################

runGuppy() {
    local inputDir=$1

    local f5Dir=$inputDir/fast5
    local fqDir=$inputDir/fastq
    echo $f5Dir
    echo $fqDir

    # Run Guppy on all FAST5 reads, regardless of "pass" or "fail"
    # Output multiple FASTQ files
    ${HOME}/ont-guppy-cpu/bin/guppy_basecaller \
        -i $inputDir \
        --save_path $fqDir \
        --flowcell FLO-MIN106 \
        --kit SQK-RNA001 \
        --num_callers 10 \
        --cpu_threads_per_caller 16 \
        --disable_pings \
        --records_per_fastq 0 \
        --recursive
}

############################ Main #############################

echo "Running Guppy"

runGuppy $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4430A1
runGuppy $TRANSCRIPTOME_DATA_DIR/fastq/ont/LAI4712A1
runGuppy $TRANSCRIPTOME_DATA_DIR/fastq/ont/ADM5153_5056A1
runGuppy $TRANSCRIPTOME_DATA_DIR/fastq/ont/ADM5153_5056
