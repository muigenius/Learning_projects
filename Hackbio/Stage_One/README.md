
# Clinical Case Study: Whole-Genome Sequencing Analysis for Cystic Fibrosis

This repository contains the code and documentation for a bioinformatics project focusing on the analysis of Whole-Genome Sequencing (WGS) data for a clinical case suspected of having Cystic Fibrosis (CF). The core task involved performing a comprehensive germline variant discovery pipeline on WGS data from a child and their father, specifically targeting the $CFTR$ gene.

## Project Scope and Objectives

The primary goal of this project was to leverage standard bioinformatics tools and best practices to process raw sequencing reads and identify pathogenic variants.

1.  **Data Processing & Quality Control (QC):** Assess raw read quality and perform necessary trimming.
2.  **Alignment & BAM Preparation:** Map cleaned reads to the human reference genome (GRCh38) and refine BAM files (Read Group assignment, Duplicate Marking, BQSR).
3.  **Variant Calling & Joint Genotyping:** Execute the GATK Best Practices pipeline (HaplotypeCaller, CombineGVCFs, GenotypeGVCFs) on a family duo (child and father).
4.  **Targeted Analysis & Annotation:** Filter the resulting VCF for the $CFTR$ locus (chromosome 7q31.2) and annotate variants using external resources (e.g., VEP) to determine pathogenicity and inheritance patterns.

## Technical Execution and Workflow

The entire analysis was scripted using **Bash** and executed using a robust set of open-source bioinformatics tools, primarily following the **GATK Best Practices** recommendations for Germline Variant Discovery.

| Phase | Key Tools Used | Description |
| :--- | :--- | :--- |
| **QC & Pre-processing** | `fastqc`, `fastp` | Initial quality assessment and adapter/low-quality base trimming. |
| **Alignment** | `BWA mem`, `Samtools` | Mapping reads to GRCh38 and converting/sorting the output to BAM format. |
| **BAM Refinement** | `GATK AddOrReplaceReadGroups`, `MarkDuplicates` | Standardizing metadata and removing PCR-induced artifacts. |
| **Recalibration** | `GATK BaseRecalibrator`, `ApplyBQSR` | Correcting systematic sequencing errors for improved variant confidence. |
| **Variant Calling** | `GATK HaplotypeCaller` (GVCF mode), `CombineGVCFs`, `GenotypeGVCFs` | Calling variants across the duo for highly accurate, joint-genotyped VCF. |
| **Filtering & Indexing** | `GATK VariantFiltration`, `BuildBamIndex` | Applying hard filters (e.g., QD, FS) and finalizing BAM indexing. |

## Learning Outcomes and Valuable Skills

This project provided invaluable, hands-on experience in critical areas of production-level genomics and bioinformatics.

### 1. Mastering the GATK Best Practices Pipeline
The successful execution of this project required a deep understanding of the sequential steps in the GATK workflow, including the importance of **Base Quality Score Recalibration (BQSR)** and the power of **Joint Genotyping** for improving the sensitivity and specificity of variant detection in family studies.

### 2. Clinical Data Interpretation Workflow
The shift from a raw VCF file to a clinically meaningful conclusion involved:
* **Targeted Filtering:** Efficiently isolating a specific genetic region ($CFTR$) from whole-genome data.
* **Variant Annotation:** Using tools like **VEP (Variant Effect Predictor)** to translate genetic coordinates into functional consequences (e.g., missense, nonsense, frameshift) and integrate data from authoritative sources like **ClinVar**.

### 3. Scripting and Automation
The entire workflow is captured in a single, well-commented Bash script (`stage_1.sh`). This demonstrates proficiency in **pipeline automation**, ensuring the analysis is reproducible, scalable, and auditable—essential qualities in a regulated biotech environment.

### 4. Handling Family Inheritance Patterns
The comparative analysis between the child and father underscored the necessity of **segregation analysis** to distinguish between variants inherited from the tested parent, those likely inherited from the untested parent, and potential *de novo* mutations, providing a robust framework for genetic counseling.

## Repository Contents

* **`stage_1.sh`**: The complete Bash script that executes all QC, alignment, and variant calling steps.


***

**Author:** \[Muyideen Enitan Sadibo]
**Date:** \[September 2025]
