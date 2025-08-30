
# 🚀 HackBio Stage Zero Projects

This repository contains my **Stage 0 projects** from the [HackBio Internship](https://thehackbio.com). The work demonstrates practical skills in **Linux command-line (Bash)** and **bioinformatics software installation** using `conda`.

## 📂 Project Overview

The script (`stage_0.sh`) combines two main tasks:

### **Project 1: Bash Basics**

* Creating and managing directories.
* Downloading sequence files from online repositories.
* Moving, renaming, and deleting files.
* Identifying DNA motifs (`tata` vs `tatatata`) to distinguish wildtype vs mutant sequences.
* Extracting useful information from GenBank (`.gbk`) files such as sequence length, source organism, and gene names.

### **Project 2: Installing Bioinformatics Software**

* Setting up a dedicated conda environment (`funtools`).
* Installing and verifying the following bioinformatics tools:

  * [Figlet](http://www.figlet.org/) (for fun text banners 🎉)
  * [BWA](http://bio-bwa.sourceforge.net/)
  * [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi)
  * [Samtools](http://www.htslib.org/)
  * [Bedtools](https://bedtools.readthedocs.io/)
  * [SPAdes](https://cab.spbu.ru/software/spades/)
  * [Bcftools](http://samtools.github.io/bcftools/)
  * [Fastp](https://github.com/OpenGene/fastp)
  * [MultiQC](https://multiqc.info/)

Each installation step is followed by a **version check** to confirm successful setup.

---

## ⚙️ Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/muigenius/Learning_projects/tree/c8c11bb96ff263719576be254d174206c289b93a/Hackbio/Stage_Zero/stage_0.sh
   cd Learning_projects/Hackbio/Stage_Zero/
   ```

2. Make the script executable:

   ```bash
   chmod +x stage_0.sh
   ```

3. Run the script:

   ```bash
   ./stage_0.sh
   ```

---

## 📝 Notes

* Ensure you have **Conda** (Miniconda or Anaconda) installed before running the script.
* Some installations may require internet access and sufficient disk space.
* Tested on Ubuntu/Linux environment.

---

## 🌟 Acknowledgement

These projects were completed as part of the **HackBio Internship (Stage Zero)** with **Team Rosalind**.

