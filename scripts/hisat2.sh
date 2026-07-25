#!/bin/bash

set -euo pipefail

function bam_conversor {
   samtools sort -o ./reports/bam/${sample}.bam ./reports/sam/${sample}.sam
   rm ./reports/sam/${sample}.sam
 return
}

function bam_index {
   samtools index ./reports/bam/${sample}.bam
 return
}

mkdir -p ./reports/sam 
mkdir -p ./reports/bam

echo "===================================================="
echo "~~~~~~~~~Reference genome index with HISAT2~~~~~~~~~"
echo "===================================================="

#For splicing sites
echo "Extraction splice sites from the reference genome file"
hisat2_extract_splice_sites.py ./refs/*.gtf > ./refs/file.ss

echo "Extraction exon sites from the reference genome file"
#For exon sites
hisat2_extract_exons.py ./refs/*.gtf > ./refs/file.exons

#Genome index
# -p: threads | --ss: splice sites | --exon: exon sites | reference genome | index prefix
hisat2-build \
 -p 4 \
 --ss ./refs/file.ss \
 --exon ./refs/file.exons \
 ./refs/*.{fa,fasta} \
 ./refs/index


echo "====================================================="
echo "~Aligning reads to the reference genome using HISAT2~"
echo "====================================================="

for condition in HBR UHR
 do
  for replica in 1 2 3 
   do
    sample="${condition}_${replica}"

    if [ "$MODO" == "single" ]; then

       echo "========================================================"
       echo "~~~~~~~~~~~~~~~~~~~~Aligning $sample~~~~~~~~~~~~~~~~~~~~"
       echo "========================================================"

       hisat2 \
         -p 4 \
         -x ./refs/index \
         -U ./trimmed_seqs/${sample}_trimmed.fq.gz \
         -S ./reports/sam/${sample}.sam

       echo "=========================================================="
       echo "~~~~Converting $sample.sam to $sample.bam and indexing~~~~"
       echo "=========================================================="

       bam_conversor
       bam_index

    else

       echo "========================================================"
       echo "~~~~~~~~~~~~~~~~~~~~~Aligning $sample~~~~~~~~~~~~~~~~~~~"
       echo "========================================================"

       hisat2 \
         -p 4 \
         -x ./refs/index \
         -1 ./trimmed_seqs/${sample}_R1_trimmed.fq.gz \
         -2 ./trimmed_seqs/${sample}_R2_trimmed.fq.gz \
         -S ./reports/sam/${sample}.sam

       echo "=========================================================="
       echo "~~~~Converting $sample.sam to $sample.bam and indexing~~~~"
       echo "=========================================================="

       bam_conversor
       bam_index

    fi

   done
done   

echo "========================================================="
echo "~~~~~~~~~~~~~~~~~~~~Analysis Completed~~~~~~~~~~~~~~~~~~~"
echo "========================================================="

