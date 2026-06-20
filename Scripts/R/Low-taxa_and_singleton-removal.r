#Load-table-in-tsv
otu <- read.table("G_and_S_PRJNA607849_T2D.tsv", sep = "\t", header = TRUE, check.names = FALSE) 
#If taxa are in columns and samples in rows, you may need to transpose it
#otu <- t(otu)
str(otu)
rownames(otu) <- make.unique(otu[[1]])  # Make first column unique
otu <- otu[, -1]                        # Drop the first column after using it as row names
nrow(otu)
View(otu)
ncol(otu)
#Remove-singletons
otu_no_singletons <- otu[rowSums(otu) > 1, ] #(singletons = taxa with total abundance of 1 across all samples)
View(otu_no_singletons)
nrow(otu_no_singletons)
ncol(otu_no_singletons)
#Remove-lowest-10%taxa (by total abundance)
# Calculate total abundance for each taxon
taxa_totals <- rowSums(otu_no_singletons)

# Find the cutoff for the bottom 10%
cutoff <- quantile(taxa_totals, probs = 0.10)

# Filter out taxa below the cutoff
otu_filtered <- otu_no_singletons[taxa_totals > cutoff, ]

#save-the-filtered-table-in.tsv
write.table(otu_filtered, "filtered_abundance_table_PRJNA607849_T2D.tsv", sep = "\t", quote = FALSE)
