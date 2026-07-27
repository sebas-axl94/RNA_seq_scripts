# ===========================================================
#R script for RNA-seq count matrix analysis and visualization
#By: sebas-axl94
# ===========================================================

#Libraries 

library(DESeq2)
library(tidyverse)
library(ggrepel)
library(AnnotationDbi)
library(org.Hs.eg.db)


# ------------------------

counts <- read.csv("counts_matrix.csv", row.names = 1)
metadata <- read.csv("design.csv", row.names = 1)

all(colnames(counts) == rownames(metadata))

#Convert condition to factor
metadata$condition <- factor(metadata$condition)
is.factor(metadata$condition)

metadata$condition <- relevel(metadata$condition, ref = "HBR")
levels(metadata$condition)

#Create a DESeqDataSet object
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = metadata,
  design = ~ condition
)

#Keep genes with, at least, 10 counts
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep, ]

#Run DESeq2
dds <- DESeq(dds)

#Extract results table
results <- results(dds)
results

ordered_results <- as.data.frame(results) |> 
  rownames_to_column(var = "gene_id") |> 
  mutate(gene_id = str_remove(gene_id, "[.].*")) #gene_id without version number

#A new column, about significant based in padj and log2FC values.
ordered_results <- ordered_results |>                                       
  mutate(significant = case_when(                                  
    padj <= 0.05 & log2FoldChange >= 1 ~ "Upregulated",
    padj <= 0.05 & log2FoldChange <= -1 ~ "Downregulated",
    TRUE ~ "Not significant")) |> 
  mutate(padj_adj = ifelse(padj == 0, .Machine$double.xmin, padj)) |> 
  relocate(padj_adj, .after = padj)
    
    
write.csv(ordered_results, "results_DESEq2", row.names = FALSE)


#Top DEGs
DEGs <- ordered_results |> 
  arrange(desc(abs(log2FoldChange))) |> 
  filter(padj <= 0.05) |> 
  head(n = 15) |> 
  pull(gene_id) 

DEGs

#Which genes do those gene IDs correspond to? 
#Important, the next code only works for Homo sapiens (due to org.Hs.eg.db)
mapped_genes <- mapIds(org.Hs.eg.db,
                keys    = DEGs,
                column  = "SYMBOL",     
                keytype = "ENSEMBL",    
                multiVals = "first")    

mapped_table<- tibble(
  gene_id = names(mapped_genes),  
  symbol  = unname(mapped_genes)  
)

results_table <- ordered_results |> 
  left_join(mapped_table, by = "gene_id") |> 
  mutate(gene_label = ifelse(is.na(symbol), gene_id, symbol)) |> 
  relocate(gene_label, .after = gene_id)

# ------------
#VISUALIZATION

# 1. VOLCANO PLOT
ggplot(data = results_table, mapping = aes(x = log2FoldChange, y = -log10(padj_adj),
                                                          size = significant,
                                                          alpha = significant)) +
  geom_text_repel(data = results_table %>%
                    filter(gene_id %in% DEGs),
                  aes(x = log2FoldChange, y = -log10(padj_adj), label = symbol),
                  nudge_y = 0.5, hjust = 0.5, direction = "y",
                  segment.color="gray") +
  geom_point(aes(colour = significant)) +
  scale_size_manual(values = c(2, 1, 2), guide = "none") +
  scale_alpha_manual(values = c(1, 0.5, 1), guide = "none") +
  scale_color_manual(values = c("deeppink4", "gray", "seagreen")) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  geom_vline(xintercept = - 1, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "gray40", linewidth = 0.8) +
  scale_x_continuous(breaks = c(-10, -5, -1, 0, 1, 5, 10)) +
  labs(title = "Volcano Plot", 
       x = "Log2FC", 
       y = "-Log10(padj)", 
       color = "DEGs") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.title = element_text(face = "bold"),
        axis.text = element_text(size = 10, face = "italic"),
        legend.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom")


# 2. PRINCIPAL COMPONENTS ANALYSIS (PCA)

# Counts transformation with vst function. blind = TRUE ensures that the transformation is unsupervised, therefore, unaffected by the design
vsd <- varianceStabilizingTransformation(dds, blind = TRUE)

# Extract PCs coords table
pca_data <- plotPCA(vsd, intgroup = c("condition"), returnData = TRUE)

# Extract variance % of each PC
percentVar <- round(100 * attr(pca_data, "percentVar"))

ggplot(pca_data, aes(x = PC1, y = PC2, color = condition)) +
  geom_point(size = 4, alpha = 0.8) +
  geom_text_repel(aes(label = name), size = 3, show.legend = FALSE) +   # For sample names
  scale_color_manual(values = c("deeppink4", "seagreen")) + 
  labs(
    x = paste0("PC1: ", percentVar[1], "% variance"),
    y = paste0("PC2: ", percentVar[2], "% variance"),
    title = "PCA - RNA seq Samples",
    color = "Condition"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )




