#!/bin/bash

set -euo pipefail 

mkdir -p ./counts

 
function cleaner {
 sed "1d" ./counts/counts_matrix.txt | cut -f 1,7-12 | tr '\t' ',' | sed "1s/\.\/reports\/bam\///g" | sed "1s/\.bam//g" > ./counts/counts_matrix.csv
return
}

function visualizer {
 column -t -s ',' ./counts/counts_matrix.csv | head -n 15 || true
return
}



if [ "$MODO" == "single" ]; then
   
     echo "Counts matrix for single-end"
     featureCounts -a ./refs/*.gtf -t exon -g gene_id -o ./counts/counts_matrix.txt ./reports/bam/*.bam

     echo "Cleaning matrix and transform to .csv"
     cleaner

     echo "============================================================"
     echo "~~~~~~~~~~~~~~~~~~~~~~~Preview matrix~~~~~~~~~~~~~~~~~~~~~~~"
     echo "============================================================"
     visualizer

 else

     echo "Counts matrix for paired-end"
     featureCounts -p -a ./refs/*.gtf -t exon -g gene_id -o ./counts/counts_matrix.txt ./reports/bam/*.bam

     echo "Cleaning matrix and transform to .csv"
     cleaner

     echo "============================================================"
     echo "~~~~~~~~~~~~~~~~~~~~~~~Preview matrix~~~~~~~~~~~~~~~~~~~~~~~"
     echo "============================================================"
     visualizer
fi


#Experimental design file
     echo "============================================================="
     echo "~~~~~~~~~~~~~Experimental design file generation~~~~~~~~~~~~~"
     echo "============================================================="
mkdir -p ./metadata
design_file=./metadata/design.csv

echo "sample,condition" > $design_file

for condition in HBR UHR
 do
   for replica in 1 2 3
   do
     sample="${condition}_${replica}"
     echo "${sample},${condition}" >> $design_file
   done
 done

echo "Experimental design file generated in: ./metadata"














