#!/bin/bash

##############################################################

# Script Name:        illumina_filter_reads.sh
# Author:             Aidan Tay

# Description: Pipeline for getting high-confidence reads. This
#              is done by trimming quality or adpator sequences
#              and filtering out extremely short / long
#              RNA-seq FASTQ reads from Illumina NextSeq

################### Workspace & Notes #########################

################### Dependencies ##############################

# bbtools/38.37
# seqtk/1.2

################### Global Variables ##########################

NUM_READS=455106
NUM_READS_BY_BASES=6414760

################### Functions #################################

sampleReadsByBases() {
    local inputLFilepath=$1
    local inputRFilepath=$2
    local inputLFilePrefix=$(basename ${inputLFilepath} | sed "s|.fastq||g")
    local inputRFilePrefix=$(basename ${inputRFilepath} | sed "s|.fastq||g")

    local i=1
    local iEnd=6
    while [ ${i} -lt ${iEnd} ]; do
        local outputLFilePrefix=${inputLFilePrefix}_Bases${i}
        local outputRFilePrefix=${inputRFilePrefix}_Bases${i}

        local outputLFilepath=$READS_OUTPUT_DIR/${outputLFilePrefix}.fastq
        local outputRFilepath=$READS_OUTPUT_DIR/${outputRFilePrefix}.fastq

        local random=$(($RANDOM % 100))

        seqtk sample \
            -s $random \
            $inputLFilepath \
            $NUM_READS_BY_BASES \
            > $outputLFilepath

        seqtk sample \
            -s $random \
            $inputRFilepath \
            $NUM_READS_BY_BASES \
            > $outputRFilepath

        i=$(($i+1))
    done
}

sampleReadsByReads() {
    local inputLFilepath=$1
    local inputRFilepath=$2
    local inputLFilePrefix=$(basename ${inputLFilepath} | sed "s|.fastq||g")
    local inputRFilePrefix=$(basename ${inputRFilepath} | sed "s|.fastq||g")

    local i=1
    local iEnd=6
    while [ ${i} -lt ${iEnd} ]; do
        local outputLFilePrefix=${inputLFilePrefix}_Reads${i}
        local outputRFilePrefix=${inputRFilePrefix}_Reads${i}

        local outputLFilepath=$READS_OUTPUT_DIR/${outputLFilePrefix}.fastq
        local outputRFilepath=$READS_OUTPUT_DIR/${outputRFilePrefix}.fastq

        local random=$(($RANDOM % 100))

        seqtk sample \
            -s $random \
            $inputLFilepath \
            $NUM_READS \
            > $outputLFilepath

        seqtk sample \
            -s $random \
            $inputRFilepath \
            $NUM_READS \
            > $outputRFilepath

        i=$(($i+1))
    done
}

#################### Main #####################################

echo "Filtering FASTQ reads"

bbduk.sh \
    -Xmx64g \
    overwrite=t \
    in1=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L001_R1_001.fastq.gz \
    in2=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L001_R2_001.fastq.gz \
    out1=$READS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk.fastq \
    out2=$READS_OUTPUT_DIR/LAI4430_S1_L001_R2_001_bbduk.fastq \
    threads=16 \
    ref=util/adapters.fa \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo

bbduk.sh \
    -Xmx64g \
    overwrite=t \
    in1=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L002_R1_001.fastq.gz \
    in2=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L002_R2_001.fastq.gz \
    out1=$READS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk.fastq \
    out2=$READS_OUTPUT_DIR/LAI4430_S1_L002_R2_001_bbduk.fastq \
    threads=16 \
    ref=util/adapters.fa \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo

bbduk.sh \
    -Xmx64g \
    overwrite=t \
    in1=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L003_R1_001.fastq.gz \
    in2=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L003_R2_001.fastq.gz \
    out1=$READS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk.fastq \
    out2=$READS_OUTPUT_DIR/LAI4430_S1_L003_R2_001_bbduk.fastq \
    threads=16 \
    ref=util/adapters.fa \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo

bbduk.sh \
    -Xmx64g \
    overwrite=t \
    in1=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L004_R1_001.fastq.gz \
    in2=$TRANSCRIPTOME_DATA_DIR/fastq/illumina/LAI4430_S1_L004_R2_001.fastq.gz \
    out1=$READS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk.fastq \
    out2=$READS_OUTPUT_DIR/LAI4430_S1_L004_R2_001_bbduk.fastq \
    threads=16 \
    ref=util/adapters.fa \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo

## Create a merged set of reads
cat $READS_OUTPUT_DIR/LAI4430_S1_L00*_R1_001_bbduk.fastq \
    > $READS_OUTPUT_DIR/illumina_R1_bbduk.fastq

cat $READS_OUTPUT_DIR/LAI4430_S1_L00*_R2_001_bbduk.fastq \
    > $READS_OUTPUT_DIR/illumina_R2_bbduk.fastq

## Subsample raw reads
sampleReadsByBases \
    $READS_OUTPUT_DIR/illumina_R1_bbduk.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk.fastq

## Subsample raw reads
sampleReadsByReads \
    $READS_OUTPUT_DIR/illumina_R1_bbduk.fastq \
    $READS_OUTPUT_DIR/illumina_R2_bbduk.fastq
