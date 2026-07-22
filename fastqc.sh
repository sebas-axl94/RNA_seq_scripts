#!/bin/bash

set -euo pipefail

mkdir -p ./reportes/fastqc_pre
mkdir -p ./secuencias_trimadas
mkdir -p ./reportes/fastqc_post

echo "=============================================="
echo "Inicio, procesamiento con Fastqc y Trimmomatic"
echo "=============================================="
for condition in HBR UHR
do
   for replica in 1 2 3
   do
     sample="${condition}_${replica}"

     if [ "$MODO" == "single" ]; then

       #Analisis con Fastqc antes de trimar
        echo "Analisis fastqc de ${sample} pre-procesamiento"
        fastqc ./reads/${sample}.fq.gz -o ./reportes/fastqc_pre

       #Trimado de secuencias
        echo "Limpieza de secuencias"
        TrimmomaticSE ./reads/${sample}.fq.gz \
         ./secuencias_trimadas/${sample}_trimada.fq.gz \
         SLIDINGWINDOW:4:30 \
         MINLEN:50
         #ILLUMINACLIP:nextera.fa:2:30:5

       #Analisis con Fastqc despues de trimar
        echo "Analisis fastqc de ${sample} post-procesamiento"
        fastqc ./secuencias_trimadas/${sample}_trimada.fq.gz  -o ./reportes/fastqc_post

     else 
       #Directorio para unpaired:
       mkdir -p ./secuencias_trimadas_unpaired

       #Analisis con Fastqc antes de trimar
        echo "Analisis fastqc de ${sample}_R1 y ${sample}_R2 pre-procesamiento"
        fastqc ./reads/${sample}_R1.fq.gz ./reads/${sample}_R2.fq.gz -o ./reportes/fastqc_pre

       #Trimado de secuencias
        echo "Limpieza de secuencias"
        TrimmomaticPE ./reads/${sample}_R1.fq.gz ./reads/${sample}_R2.fq.gz \
         ./secuencias_trimadas/${sample}_R1_trimada.fq.gz ./secuencias_trimadas_unpaired/${sample}_R1_trimada_unpaired.fq \
         ./secuencias_trimadas/${sample}_R2_trimada.fq.gz ./secuencias_trimadas_unpaired/${sample}_R2_trimada_unpaired.fq \
         SLIDINGWINDOW:4:30 \
         MINLEN:50
         #ILLUMINACLIP:nextera.fa:2:30:5

        #Analisis con Fastqc despues de trimar
        echo "Analisis fastqc de ${sample}_R1 y ${sample}_R2 post-procesamiento"
        fastqc ./secuencias_trimadas/${sample}_R1_trimada.fq.gz ./secuencias_trimadas/${sample}_R2_trimada.fq.gz -o ./reportes/fastqc_post
     fi
   done
done


echo "=============================================="
echo "Fin, procesamiento con Fastqc y Trimmomatic"
echo "=============================================="

