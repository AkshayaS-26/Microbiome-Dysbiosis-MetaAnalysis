#!/bin/bash

###############################################################################
# Project: Gut Microbiome Dysbiosis Meta-analysis Across Metabolic Disorders
#
# Description:
# Bash workflow for 16S rRNA microbiome analysis using SRA Toolkit,
# FastQC, MultiQC, and QIIME2.
# Steps:
# - FASTQ download
# - Quality control
# - DADA2 denoising
# - Feature table construction
# - Diversity analysis
# - Taxonomic classification
# - Relative abundance calculation
#
# This pipeline was adapted from official QIIME2 documentation and
# customized for the analysis of publicly available metabolic disorder
# microbiome datasets.
#
# Workflow adapted and organized by:
# Akshaya Sundaravelu
#
# References:
# QIIME2 Documentation: https://docs.qiime2.org/
###############################################################################

###############################################################################
# STEP 1: DOWNLOAD FASTQ FILES FROM NCBI SRA
###############################################################################
#FOR DOWNLOAD THE FASTQ SEQUENCE (srr_id.txt contains the srr accession numbers)
#CONDA ENVIRONMENT sra-tools
for id in $(cat srr_id.txt ); do fastq-dump --split-3 --gzip --defline-qual '+' $id;done

###############################################################################
# STEP 2: QUALITY CHECK WITH FASTQC AND MULTIQC
###############################################################################
#QUALITY CHECK WITH FASTQC AND MULTIQC
#CONDA ENVIRONMENT fastqc
fastqc *.fastq.gz -o fastqc_out #output stores in the fastqc_out directory
#CONDA ENVIRONMENT multiqc-env
multiqc .

###############################################################################
# STEP 3: IMPORT INTO QIIME2
###############################################################################
#IMPORT INTO QIIME2
#CREATE MANIFEST FILE
#CONDA ENVIRONMENT qiime2 AND qiime2-amplicon-2024.5
#NOTE: FOR SINGLE END SEQUENCE
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest.tsv \
  --output-path single-end-demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

#NOTE: FOR PAIRED END SEQUENCE
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.tsv \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

#DEMUX FILE VISUALIZATION
qiime demux summarize \
  --i-data single-end-demux.qza \
  --o-visualization demux-single-end.qzv 

###############################################################################
# STEP 4: DADA2 denoising
###############################################################################
#DADA2 - DENOISING AND FILTERING
#FOR SINGLE END READS
qiime dada2 denoise-single \
  --i-demultiplexed-seqs single-end-demux.qza \
  --p-trim-left 0 \
  --p-trunc-len 240 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table-dada2.qza \
  --o-denoising-stats stats-dada2.qza

#FOR PAIRED END READS
qiime dada2 denoise-paired \
	--i-demultiplexed-seqs paired-end-demux.qza \
	--p-trim-left-f 0 \
	--p-trim-left-r 0 \
	--p-trunc-len-f 250 \
	--p-trunc-len-r 250 \
	--o-representative-sequences rep-seqs-dada2.qza \
	--o-table table-dada2.qza \
	--o-denoising-stats stats-dada2.qza

#FOR VISUALIZATION
qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats.qzv

###############################################################################
# STEP 5: Feature table construction
###############################################################################
#FEATURE TABLE CONSTRUCTION
qiime feature-table summarize \
  --i-table table-dada2.qza \
  --m-sample-metadata-file manifest.tsv \
  --o-visualization table-dada2.qzv
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2.qza \
  --o-visualization rep-seqs.qzv

###############################################################################
# STEP 6: Diversity analysis
###############################################################################
#PHYLOGENETIC DIVERSITY ANALYSIS
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-dada2.qza \
  --output-dir phylogeny-align-to-tree-mafft-fasttree
  
#ALPHA RAREFRACTION PLOTTING
qiime diversity alpha-rarefaction \
  --i-table table-dada2.qza \
  --i-phylogeny phylogeny-align-to-tree-mafft-fasttree/rooted_tree.qza \
  --p-max-depth 4000 \
  --m-metadata-file manifest.tsv \
  --o-visualization alpha-rarefaction.qzv
  
#ALPHA AND BETA DIVERSITY ANALYSIS  
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny phylogeny-align-to-tree-mafft-fasttree/rooted_tree.qza \
  --i-table table-dada2.qza \
  --p-sampling-depth 1200 \
  --m-metadata-file manifest.tsv \
  --output-dir core-metrics-results

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file manifest.tsv \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file manifest.tsv \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest.tsv \
  --m-metadata-column subject \
  --o-visualization core-metrics-results/unweighted-unifrac-subject-group-significance.qzv \
  --p-pairwise
  
###############################################################################
# STEP 7: Taxonomic classification
###############################################################################
#TAXONOMY ANALYSIS
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs-dada2.qza \
  --o-classification taxonomy.qza
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
  
qiime taxa barplot \
  --i-table table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization taxa-bar-plots.qzv

qiime taxa collapse \
  --i-table table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 7 \
  --o-collapsed-table species-table.qza

###############################################################################
# STEP 8: Relative abundance calculation
###############################################################################
qiime feature-table relative-frequency \
--i-table species-table.qza \
--o-relative-frequency-table rel-species-table.qza

qiime tools export --input-path  rel-species-table.qza --output-path rel-species-table

#BIOM TABLE TO TSV
biom convert -i rel-species-table/feature-table.biom -o rel-species-table.tsv --to-tsv

  
