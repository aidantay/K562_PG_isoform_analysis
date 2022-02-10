#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=32gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --output=illumina_construct_transcripts-%j.out

##############################################################

# Script Name:        illumina_construct_transcripts.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       31-01-2018


# Description: Pipeline for constructing transcripts based on the
#              the alignment of RNA-seq FASTQ reads from
#              Illumina NextSeq

################### Workspace & Notes #########################

## Having a reference will assemble reads into transcripts better.

#################
### StringTie ###
#################
## -a = 1 Vs -a = 10 (default) doesnt seem to have any significant impact

## -c > 1 is likely to give us good results given that we got lots of reads
## However, just use the default since it work pretty well

## --rf should be used since Illumina protocol is stranded.
## Both --rf and --fr give the same results...

################### Dependencies ##############################

module load stringtie/1.3.4d

################### Global Variables ##########################

#################### Functions ################################

constructTranscripts() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|.bam||g")

    local outputFilePrefix=${inputFilePrefix}

    stringtie \
        -G $GENOME_DATA_DIR/gtf/Homo_sapiens.GRCh38.100.chr.gtf \
        -p 16 \
        --rf \
        -C $TRANSCRIPTS_OUTPUT_DIR/${outputFilePrefix}_stringtie_ref_transcripts.txt \
        -A $TRANSCRIPTS_OUTPUT_DIR/${outputFilePrefix}_stringtie_gene_abundance.txt \
        -o $TRANSCRIPTS_OUTPUT_DIR/${outputFilePrefix}_stringtie.gtf \
        $inputFilepath
}

############################ Main #############################

echo "Constructing transcripts"

constructTranscripts $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L001_R1_001_bbduk_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L002_R1_001_bbduk_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L003_R1_001_bbduk_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/LAI4430_S1_L004_R1_001_bbduk_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_hisat_filtered_sorted.bam

constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat_filtered_sorted.bam

constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat_filtered_sorted.bam
constructTranscripts $ALIGNMENTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat_filtered_sorted.bam
