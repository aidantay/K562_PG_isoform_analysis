#!/bin/bash

##############################################################

# Script Name:        illumina_identify_denovo_transcripts.sh
# Author:             Aidan Tay

# Description: Pipeline for identifying novel (de novo) transcripts
#              based on the RNA-seq mapping of FASTQ reads
#              from Illumina NextSeq

################### Workspace & Notes #########################

################### Dependencies ##############################

# samtools/1.10.0

################### Global Variables ##########################

################### Functions #################################

identifyTranscripts() {
    local xamFilePath=$1
    local gxfFilePath=$2
    local outputFilePrefix=$3   

    ## Find transcript-specific reads
    tsrDirPath=$(getTranscriptSpecificReads $xamFilePath $gxfFilePath $outputFilePrefix)

    ## Create a GXF file containing identified transcripts
    getTranscripts $gxfFilePath $tsrDirPath $outputFilePrefix

    ## Get the transcript-specific read alignments
    getReadAlignments $xamFilePath $tsrDirPath $outputFilePrefix 
}

getTranscriptSpecificReads() {
    local xamFilePath=$1
    local gxfFilePath=$2
    local outputFilePrefix=$3

    local outputDirPrefix=${outputFilePrefix}_transcript_specific_reads
    local outputDirPath=$TRANSCRIPTOMES_OUTPUT_DIR/${outputDirPrefix}

    python $SCRIPTS_DIR/dev/identify_transcript_specific_reads.py \
        --gxf $gxfFilePath \
        --xam $xamFilePath \
        --outputfile $outputDirPath

    echo $outputDirPath
}

getTranscripts() {
    local gxfFilePath=$1
    local tsrDirPath=$2
    local outputFilePrefix=$3

    local outputFilePrefix=${outputFilePrefix}_transcripts
    local outputFilePath=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}.gtf

    ## Setup some temporary files (for parallelisation)
    local temp1=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_temp1
    local temp2=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_temp2

    ## Find all transcripts we identified
    cat $tsrDirPath/*.csv | tail -n +2 | cut -f3 \
        | sed 's/$/"/g' | sed 's/^/"/g' \
        | sort | uniq \
        > ${temp1}.txt
    grep -Ff ${temp1}.txt ${gxfFilePath} > ${temp2}.txt

    ## Reheader GTF file
    grep '^#' ${gxfFilePath} > ${temp1}.txt
    cat ${temp1}.txt ${temp2}.txt > ${outputFilePath}

    ## Clean up
    rm ${TRANSCRIPTOMES_OUTPUT_DIR}/${outputFilePrefix}_temp*
}

getReadAlignments() {
    local xamFilePath=$1
    local tsrDirPath=$2
    local outputFilePrefix=$3

    local outputFilePrefix=${outputFilePrefix}_read_alignments
    local outputFilePath=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}.bam

    ## Setup some temporary files (for parallelisation)
    local temp1=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_temp1
    local temp2=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_temp2
    local temp3=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_temp3
    local header_temp=$TRANSCRIPTOMES_OUTPUT_DIR/${outputFilePrefix}_header_temp

    ## Find all transcripts we identified
    cat $tsrDirPath/*.csv | tail -n +2 | cut -f1 \
        | sort | uniq \
        > ${temp1}.txt
    samtools view -h $xamFilePath | grep -Ff ${temp1}.txt > ${temp2}.sam

    ## Reheader, sort and index alignment files
    samtools view -H $xamFilePath > ${header_temp}.sam
    cat ${header_temp}.sam ${temp2}.sam > ${temp3}.sam
    samtools sort -@ 16 -o ${temp2}.bam -O BAM < ${temp3}.sam
    mv ${temp2}.bam ${outputFilePath}
    samtools index -@ 16 ${outputFilePath}

    ## Clean up
    rm ${TRANSCRIPTOMES_OUTPUT_DIR}/${outputFilePrefix}_temp*
}

############################ Main #############################

echo "Identifying novel (de novo) transcripts"

identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_denovo


identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Bases1_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Bases2_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Bases3_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Bases4_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Bases5_denovo


identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Reads1_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Reads2_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Reads3_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Reads4_denovo
identifyTranscripts \
    $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat_filtered_sorted.bam \
    $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat_filtered_sorted_stringtie.gtf \
    illumina_R1_bbduk_Reads5_denovo
