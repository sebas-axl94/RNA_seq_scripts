#!/bin/bash

set -euo pipefail

mkdir -p ./reports/fastqc_pre
mkdir -p ./trimmed_seqs
mkdir -p ./reports/fastqc_post

echo "==============================================="
echo "~~~~~~~Fastqc and Trimmomatic processing~~~~~~~"
echo "==============================================="
for condition in HBR UHR
do
   for replica in 1 2 3
   do
     sample="${condition}_${replica}"

     if [ "$MODO" == "single" ]; then

       #Fastqc analysis prior trimming
        echo "${sample} FASTQC analysis before trimming"
        fastqc ./reads/${sample}.fq.gz -o ./reports/fastqc_pre

       #Trimming
        echo "Sequence Trimming"
        TrimmomaticSE ./reads/${sample}.fq.gz \
         ./trimmed_seqs/${sample}_trimmed.fq.gz \
         SLIDINGWINDOW:4:30 \
         MINLEN:50
         #ILLUMINACLIP:nextera.fa:2:30:5

       #Fastqc analysis after trimming
        echo "${sample} FASTQC analysis after trimming"
        fastqc ./trimmed_seqs/${sample}_trimmed.fq.gz  -o ./reports/fastqc_post

     else 
       #Unpaired sequences directory:
       mkdir -p ./trimmed_seqs_unpaired

       #Fastqc analysis prior trimming
        echo "${sample}_R1 and ${sample}_R2 FASTQC analysis before trimming"
        fastqc ./reads/${sample}_R1.fq.gz ./reads/${sample}_R2.fq.gz -o ./reports/fastqc_pre

       #Trimming
        echo "Sequence Trimming"
        TrimmomaticPE ./reads/${sample}_R1.fq.gz ./reads/${sample}_R2.fq.gz \
         ./trimmed_seqs/${sample}_R1_trimmed.fq.gz ./trimmed_seqs_unpaired/${sample}_R1_trimmed_unpaired.fq.gz \
         ./trimmed_seqs/${sample}_R2_trimmed.fq.gz ./trimmed_seqs_unpaired/${sample}_R2_trimmed_unpaired.fq.gz \
         SLIDINGWINDOW:4:30 \
         MINLEN:50
         #ILLUMINACLIP:nextera.fa:2:30:5

        #Fastqc analysis after trimming
        echo "${sample}_R1 and ${sample}_R2 FASTQC analysis before trimming"
        fastqc ./trimmed_seqs/${sample}_R1_trimmed.fq.gz ./trimmed_seqs/${sample}_R2_trimmed.fq.gz -o ./reports/fastqc_post
     fi
   done
done


echo "==============================================="
echo "~~~~~~~Analysis and Processing Completed~~~~~~~"
echo "==============================================="

