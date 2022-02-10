#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=128gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --output=illumina_construct_database-%j.out

###############################################################

# Script Name:        illumina_construct_database.sh
# Author:             Aidan Tay
# Version:            v1.00
# Date created:       04-10-2018

# Description: Pipeline for constructing protein sequence
#              databases for MS/MS ion searches based on the
#              transcriptome assemblies from Illumina NextSeq

################### Workspace & Notes #########################

## NextProt protein sequences can be downloaded from the website.
## Run the following command to format the file into FASTA format:
## grep 'NX' nextprot_sequence_md5.txt \
## | cut -f1,3 \
## | sed 's/^/>/g' \
## | sed 's/\t/\n/g' \
## | sed 's/\(.\{60\}\)/\1\n/g' > nextprot.fasta

################### Dependencies ##############################

module load amazon-corretto/8.212.04.2

################### Global Variables ##########################

#################### Functions ################################

constructDatabase() {
    local inputFilepath=$1
    local inputFilePrefix=$(basename ${inputFilepath} | sed "s|_hisat.*.gtf||g")
    local outputFilePrefix=${inputFilePrefix}

    local tmpFilepath=$(formatGtf $inputFilepath)
    translateTranscripts $tmpFilepath $outputFilePrefix
    rearrangeIDs $DATABASES_OUTPUT_DIR/${outputFilePrefix}.fasta
    outputAccession $DATABASES_OUTPUT_DIR/${outputFilePrefix}.fasta
    rm $DATABASES_OUTPUT_DIR/tempIllumina.gtf
}

formatGtf() {
    local inputFilepath=$1

    grep -v '^#' $inputFilepath \
    | sed 's/transcript_id "STRG.\([0-9]\+\).\([0-9]\+\)";/transcript_id "STRG_\1_\2";/g' \
    | sed 's/^/chr/g' \
    > $DATABASES_OUTPUT_DIR/tempIllumina.gtf

    echo $DATABASES_OUTPUT_DIR/tempIllumina.gtf
}

translateTranscripts() {
    local inputFilepath=$1
    local outputFilePrefix=$2

    java -jar util/3frame.jar \
        -q $inputFilepath \
        -s $inputFilepath \
        -t util/standard_code_translation_table.txt \
        -c $GENOME_DATA_DIR/fasta/chromosomes_relabeled \
        -d $outputFilePrefix \
        -o $DATABASES_OUTPUT_DIR/${outputFilePrefix}.fasta \
        -l $DATABASES_OUTPUT_DIR/${outputFilePrefix}.log \
        -p $DATABASES_OUTPUT_DIR/${outputFilePrefix}.gff
}

rearrangeIDs() {
    local inputFilepath=$1

    ## We need to format the sequence header for use in PD
    sed -i 's/\(gn1\)|\([a-zA-Z0-9_]\+\)|\(STRG[0-9_]\+\)/\2|\3|\3/g' $inputFilepath

    ## PD doesnt like *'s in the protein sequences!
    ## Replace them with X's
    sed -i 's/\*/X/g' $inputFilepath
}

outputAccession() {
    local inputFilepath=$1
    local outputFilePrefix=$(basename ${inputFilepath} | sed "s|.fasta||g")

    grep '>' $inputFilepath \
    | sed 's/.*|\(.*\)|.*/\1\t\1\t\1/g' > $DATABASES_OUTPUT_DIR/${outputFilePrefix}.txt
}


#################### Main #####################################

echo "Generating protein sequence databases"

constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_hisat_filtered_sorted_stringtie.gtf

constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases1_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases2_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases3_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases4_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Bases5_hisat_filtered_sorted_stringtie.gtf

constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads1_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads2_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads3_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads4_hisat_filtered_sorted_stringtie.gtf
constructDatabase $TRANSCRIPTS_OUTPUT_DIR/illumina_R1_bbduk_Reads5_hisat_filtered_sorted_stringtie.gtf
