#!/bin/bash

# - Full Germline Variant Discovery Pipeline (GATK Best Practices) -
# This script performs the following sequential steps:
# 1. Initial Quality Control (fastqc)
# 2. Read Trimming and QC (fastp)
# 3. Alignment (BWA) and Coordinate Sorting (samtools)
# 4. Add Read Groups (GATK)
# 5. Duplicate Marking (GATK)
# 6. Base Quality Score Recalibration (BQSR, GATK)
# 7. Single-Sample Variant Calling (GATK HaplotypeCaller)
# 8. Combine GVCFs (GATK)
# 9. Joint Genotyping (GATK GenotypeGVCFs)
# 10. Hard Filtering (GATK VariantFiltration)
# 11. Final BAM Indexing (GATK)

# Exit immediately if a command exits with a non-zero status.
set -e

# - Configuration -
SAMPLES=("child" "father")
THREADS=4 # Adjust this value based on your system's resources.
REF_GENOME="/data/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
DBSNP="/data/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
KNOWN_INDELS="/data/Homo_sapiens_assembly38.known_indels.vcf.gz" # User-specified path


# - 1. Initial Quality Control with fastqc -
echo "1. Starting Initial Quality Control with fastqc"
mkdir -p qc || { echo "Error: Failed to create directory 'qc'. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    IN_R1="/data/human_stage_1/${SAMPLE}_1.fastq.gz"
    IN_R2="/data/human_stage_1/${SAMPLE}_2.fastq.gz"
    [[ ! -f "$IN_R1" || ! -f "$IN_R2" ]] && { echo "Error: Missing input files for ${SAMPLE}. Skipping fastqc."; continue; }
    fastqc "$IN_R1" "$IN_R2" -o qc/ --threads "$THREADS"
done
echo "Initial QC with fastqc complete."

# --- 2. Quality Trimming with fastp ---
echo "--- 2. Starting Quality Trimming with fastp ---"
mkdir -p trim || { echo "Error: Failed to create directory 'trim'. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    IN_R1="/data/human_stage_1/${SAMPLE}_1.fastq.gz"
    IN_R2="/data/human_stage_1/${SAMPLE}_2.fastq.gz"
    OUT_R1="trim/${SAMPLE}_1.trim.fastq.gz"
    OUT_R2="trim/${SAMPLE}_2.trim.fastq.gz"
    REPORT_HTML="trim/${SAMPLE}_fastp_report.html"
    [[ ! -f "$IN_R1" || ! -f "$IN_R2" ]] && { echo "Error: Missing input files for ${SAMPLE}. Skipping."; continue; }
    fastp -i "$IN_R1" -I "$IN_R2" -o "$OUT_R1" -O "$OUT_R2" --html "$REPORT_HTML" --thread "$THREADS"
done
echo "--- fastp QC and Trimming complete. ---"

# --- 3. Alignment with BWA and Sorting with Samtools ---
echo "--- 3. Starting Alignment with BWA and Sorting with Samtools ---"
mkdir -p alignment || { echo "Error: Failed to create directory 'alignment'. Exiting."; exit 1; }
[ ! -f "$REF_GENOME" ] && { echo "Error: Reference genome not found at $REF_GENOME. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    TRIM_R1="trim/${SAMPLE}_1.trim.fastq.gz"
    TRIM_R2="trim/${SAMPLE}_2.trim.fastq.gz"
    BAM_OUTPUT="alignment/${SAMPLE}_sample.sorted.bam"
    [[ ! -f "$TRIM_R1" || ! -f "$TRIM_R2" ]] && { echo "Error: Trimmed files for ${SAMPLE} not found. Skipping alignment."; continue; }
    # BWA alignment, SAM to BAM conversion, and coordinate sorting (piped for efficiency)
    bwa mem -t "$THREADS" "$REF_GENOME" "$TRIM_R1" "$TRIM_R2" | \
    samtools view -b -@ "$THREADS" | \
    samtools sort -o "$BAM_OUTPUT" -@ "$THREADS" -
done
echo "--- Alignment and Sorting complete. ---"

# --- 4. Add Read Groups with GATK ---
echo "--- 4. Starting AddOrReplaceReadGroups with GATK ---"
mkdir -p alignment_rg || { echo "Error: Failed to create directory 'alignment_rg'. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="alignment/${SAMPLE}_sample.sorted.bam"
    OUTPUT_BAM="alignment_rg/${SAMPLE}_sample.sorted.rg.bam"
    [ ! -f "$INPUT_BAM" ] && { echo "Error: Input BAM not found at ${INPUT_BAM}. Skipping."; continue; }
    gatk AddOrReplaceReadGroups -I "$INPUT_BAM" -O "$OUTPUT_BAM" --RGID "$SAMPLE" --RGLB "lib1" --RGPL "illumina" --RGSM "$SAMPLE" --RGPU "unit1"
done
echo "--- Adding Read Groups complete. ---"

# --- 5. Mark Duplicates with GATK MarkDuplicates ---
echo "--- 5. Starting Duplicate Marking with GATK MarkDuplicates ---"
mkdir -p marked || { echo "Error: Failed to create directory 'marked'. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="alignment_rg/${SAMPLE}_sample.sorted.rg.bam"
    OUTPUT_BAM="marked/${SAMPLE}_sample.sorted.marked.bam"
    METRICS_FILE="marked/${SAMPLE}_markdup_metrics.txt"
    [ ! -f "$INPUT_BAM" ] && { echo "Error: Input BAM not found at ${INPUT_BAM}. Skipping."; continue; }
    gatk MarkDuplicates -I "$INPUT_BAM" -O "$OUTPUT_BAM" -M "$METRICS_FILE"
done
echo "--- Duplicate Marking complete. ---"

# --- 6. Base Quality Score Recalibration (BQSR) with GATK ---
echo "--- 6. Starting Base Quality Score Recalibration (BQSR) with GATK ---"
mkdir -p BQSR || { echo "Error: Failed to create directory 'BQSR'. Exiting."; exit 1; }
[[ ! -f "$DBSNP" || ! -f "$KNOWN_INDELS" ]] && { echo "Error: One or more known sites VCFs not found. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="marked/${SAMPLE}_sample.sorted.marked.bam"
    RECAL_TABLE="BQSR/${SAMPLE}_recal.table"
    OUTPUT_BAM="BQSR/${SAMPLE}_recal.bam"
    [ ! -f "$INPUT_BAM" ] && { echo "Error: Input BAM not found at ${INPUT_BAM}. Skipping BQSR."; continue; }
    
    # Generate the recalibration table
    gatk BaseRecalibrator -I "$INPUT_BAM" -R "$REF_GENOME" --known-sites "$DBSNP" --known-sites "$KNOWN_INDELS" -O "$RECAL_TABLE"
    
    # Apply BQSR to create the final BAM file
    gatk ApplyBQSR -I "$INPUT_BAM" -R "$REF_GENOME" --bqsr-recal-file "$RECAL_TABLE" -O "$OUTPUT_BAM"
done
echo "--- BQSR complete. ---"

# --- 7. Single-Sample Variant Calling with GATK HaplotypeCaller ---
echo "--- 7. Starting Variant Calling with GATK HaplotypeCaller (GVCF mode) ---"
mkdir -p VCF || { echo "Error: Failed to create directory 'VCF'. Exiting."; exit 1; }
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="BQSR/${SAMPLE}_recal.bam"
    OUTPUT_VCF="VCF/${SAMPLE}_variants.g.vcf.gz"
    [ ! -f "$INPUT_BAM" ] && { echo "Error: Input BAM not found at ${INPUT_BAM}. Skipping variant calling."; continue; }
    # -ERC GVCF is used for scalable joint genotyping
    gatk HaplotypeCaller -I "$INPUT_BAM" -R "$REF_GENOME" -O "$OUTPUT_VCF" -ERC GVCF
done
echo "HaplotypeCaller complete."

# - 8. Combine GVCFs with GATK CombineGVCFs -
echo "8. Starting CombineGVCFs with GATK"
CHILD_VCF="VCF/child_variants.g.vcf.gz"
FATHER_VCF="VCF/father_variants.g.vcf.gz"
COMBINED_GVCF="VCF/duo_combined.g.vcf.gz"
[[ ! -f "$CHILD_VCF" || ! -f "$FATHER_VCF" ]] && { echo "Error: Missing GVCF files for combination. Exiting."; exit 1; }
gatk CombineGVCFs -R "$REF_GENOME" -V "$CHILD_VCF" -V "$FATHER_VCF" -O "$COMBINED_GVCF"
echo "Successfully combined GVCFs into $COMBINED_GVCF."
echo "CombineGVCFs complete."

# - 9. Joint Genotyping with GATK GenotypeGVCFs -
echo "9. Starting Joint Genotyping with GATK GenotypeGVCFs"
RAW_VCF="VCF/duo_raw_variants.vcf.gz"
gatk GenotypeGVCFs -R "$REF_GENOME" -V "$COMBINED_GVCF" -O "$RAW_VCF"
echo "Successfully generated raw VCF: $RAW_VCF."
echo "Joint Genotyping complete."

# - 10. Hard Filtering with GATK VariantFiltration -
echo "--- 10. Starting Hard Filtering with GATK VariantFiltration ---"
FILTERED_VCF="VCF/duo_filtered_variants.vcf.gz"
[ ! -f "$RAW_VCF" ] && { echo "Error: Raw VCF not found. Exiting filtering step."; exit 1; }

# Apply hard filters to the raw VCF (common GATK criteria for germline SNP and Indel)
gatk VariantFiltration \
-R "$REF_GENOME" \
-V "$RAW_VCF" \
-O "$FILTERED_VCF" \
--filter-expression "QUAL < 30.0 || QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
--filter-name "FAIL_SNP_FILTERS" \
--genotype-filter-expression "DP < 10" \
--genotype-filter-name "LowCoverage"

echo "Successfully applied hard filters to $RAW_VCF, saved to $FILTERED_VCF."
echo "Hard Filtering complete."

# - 11. Final BAM Indexing with GATK -
echo "11. Starting Final BAM Indexing with GATK BuildBamIndex"
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="BQSR/${SAMPLE}_recal.bam"
    [ ! -f "$INPUT_BAM" ] && { echo "Error: Input BAM not found at ${INPUT_BAM}. Skipping indexing."; continue; }
    # The index must be generated on the final, BQSR-applied BAM.
    gatk BuildBamIndex -I "$INPUT_BAM"
done
echo "Final BAM Indexing complete."

echo "Pipeline finished successfully! 🎉 The final filtered variants are in $FILTERED_VCFCF."
