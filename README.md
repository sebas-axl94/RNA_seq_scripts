# RNA_seq Processing Pipeline

A set of bash scripts for the processing and quality control of RNA sequencing (**RNA-seq**) data.
From **raw reads** to **count matrix**: FASTQC → Trimmomatic → HISAT2 → Samtools → featureCounts 

---//---

## Software Requirements
* **Bash**
* **FastQC**
* **Trimmomatic**
* **HISAT2**
* **Samtools**
* **featureCounts**

## Input Requirements

* Before running the pipeline, you need to create two input directories in the project root and place your raw data and reference files inside them:
1. **`reads/`**: Directory containing raw sequencing files in compressed FASTQ format (`.fq.gz`).
2. **`refs/`**: Directory containing the genome reference files:
   * **Only 1 Reference Genome file:** FASTA format (`.fa`).
   * **Only 1 Gene Annotation file:** GTF format (`.gtf`).

---//---

## Repository structure
```text
RNA_seq_scripts/
├── README.md
├── .gitignore
├── pipeline.sh     
└── scripts/
      ├── fastqc.sh           (Processing and Quality Control of raw reads: it uses FASTQC and Trimmomatic (SLIDINGWINDOW:40:30, MINLEN:50, ILLUMINACLIP(if needed))
      ├── hisat2.sh           (Indexing of reference genome; alignment of processed reads (after trimming) to the reference genome; conversion of .sam to .bam: it uses HISAT2 and Samtools) 
      └── featurecounts.sh    (Generation of counts matrix and design file: it uses featureCounts)
```

## Repository directories generated after run pipeline.sh
```text
RNA_seq_scripts/
├── trimmed_seqs/            
├── trimmed_seqs_unpaired/   (Just for paired-end reads)
├── counts/
│      └── counts_matrix.csv            
├── metadata/
│      └── design.csv
└── reports/
       ├── fastqc_pre/
       ├── fastqc_post/
       ├── bam/
       └── sam/            (Empty)
```

# IMPORTANT

This pipeline was built and tested using the standard **Human Brain Reference (HBR)** and **Universal Human Reference (UHR)** RNA-Seq datasets (Paired-end, 3 biological replicates each). 

You can download the raw test reads (/reads) and refs files (/refs) directly into your directory using the following command:

```bash
# Download sample datasets (HBR and UHR reads)
wget http://data.biostarhandbook.com/rnaseq/projects/griffith/griffith-data.tar.gz
# Unpack the content
tar -xvf griffith-data.tar.gz
# In reads/, compress .fq files (generating .fq.gz files)
gzip *.fq
# In refs/, remove the reference genome and annotation file that are not of interest (remove ERCC92.fa and ERCC92.gtf, because this script uses the files 22.fa and 22.gtf located in the same directory)
rm ERCC92*
```


---//---

## Customizing for Your Own Data

The pipeline scripts iterate through samples using nested `for` loops based on condition and replicate names. 

If you are using your own datasets, you **must update the loop parameters** in the sub-scripts (e.g., `fastqc.sh`) to match your experimental design:

```bash
# Adjust these variables inside the scripts according to your samples:
for condition in HBR UHR           # Change to your experimental conditions (e.g., Control Treat)
do
    for replica in 1 2 3           # Change to your replicate numbers or identifiers
    do
        sample="${condition}_${replica}"
        
        # Script execution for $sample
    done
done
```

The loop expects input files inside `reads/` to follow the pattern:
* For **Paired-end sequencing**: `${condition}_${replica}_R{1,2}.fq.gz` (e.g., `HBR_1_R1.fq.gz` and `HBR_1_R2.fq.gz`)
* For **Single-end sequencing**: `${condition}_${replica}.fq.gz` (e.g., `HBR_1.fq.gz`, `UHR_1.fq.gz`)
