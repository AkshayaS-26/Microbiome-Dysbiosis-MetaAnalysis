# Microbiome-Dysbiosis-MetaAnalysis
Meta-analysis of gut microbiome dysbiosis across metabolic disorders using QIIME2, LEfSe, R, and Random Forest machine learning.

## Project Overview
This project investigates gut microbiome dysbiosis across metabolic disorders including Type 1 Diabetes (T1D), Type 2 Diabetes (T2D), and Non-Alcoholic Fatty Liver Disease (NAFLD) using publicly available 16S rRNA sequencing datasets.

The study integrates microbiome profiling, diversity analysis, differential abundance analysis, and machine learning approaches to identify disease-associated microbial signatures.

---

## Objectives
- Analyze gut microbiome alterations across metabolic disorders.
- Identify microbial biomarkers associated with health and disease states.
- Develop a Random Forest model to classify healthy and diseased samples.

---

## Dataset
- Source: NCBI Sequence Read Archive (SRA), GMrepo
- Total samples: 786
  - Diseased: 413
  - Healthy controls: 373

---

## Methodology

### 1. Data Processing
- Downloaded 16S rRNA sequencing data from SRA.
- Quality assessment using FastQC and MultiQC.
- Denoising and feature table construction using DADA2 in QIIME2.

### 2. Diversity Analysis
- Alpha diversity:
  - Shannon Index
  - Faith's Phylogenetic Diversity
- Beta diversity:
  - Bray-Curtis distance
  - UniFrac distance
  - PCoA visualization

### 3. Taxonomic Analysis
- Taxonomic assignment using Greengenes database.
- Relative abundance analysis.

### 4. Differential Abundance Analysis
- LEfSe analysis was performed to identify significant microbial biomarkers.

### 5. Machine Learning
- Random Forest classifier was implemented to distinguish healthy and diseased samples.

---

## Key Findings
- Reduced microbial diversity was observed in metabolic disorders.
- Healthy-associated taxa:
  - Clostridium_T
  - Blautia_A
  - Collinsella
  - Romboutsia_B

- Disease-associated taxa:
  - Phocaeicola vulgatus
  - Prevotella copri

- Random Forest model achieved:
  - Training Accuracy: 96.82%
  - Test Accuracy: 63.29%
  - Test AUC: 0.699

---

## Tools and Technologies
- QIIME2
- DADA2
- FastQC
- MultiQC
- LEfSe
- Python
- R
- Scikit-learn
- Linux/Bash

---

## Repository Structure
Microbiome-Dysbiosis-MetaAnalysis/
│
├── README.md
├── data/
├── scripts/
│ ├── Python/
│ ├── R/
│ └── Bash/
├── results/
│ ├── Figures/
│ ├── Diversity_analysis/
│ ├── LEfSe/
│ └── Machine_learning/
└── docs/
└── project_report.pdf


## Author
**Akshaya S**  
M.Sc. Bioinformatics Graduate  
Skills: Microbiome Analysis | Metagenomics | Machine Learning | Python | R | Linux
