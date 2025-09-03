#!/bin/bash


# Project 1: Bash Basic

#--STEP 1: Printing my name
echo "Muyideen Sadibo"

#--STEP 2: Creating a directory on my name
mkdir Muyideen_Sadibo
ls Muyideen_Sadibo #Check if folder exits

#--STEP 3: Creating another directory titled 'biocomputing' and changing to the directory
mkdir biocomputing && cd biocomputing/
ls -d ../biocomputing #confirm directory creation

#--STEP 4: downloading three files using the wget command
wget https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.fna
ls wildtype.fna #confirm file downloaded

wget https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk
ls wildtype.gbk #confirm file downloaded

wget https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk -O wildtype2.gbk
ls wildtype2.gbk #confirm duplicate downloaded
ls -lh #to check information about the files

#--STEP 5: moving the '.fna' file to Muyideen_Sadibo folder
mv wildtype.fna ../Muyideen_Sadibo

#--STEP 6: Deleting the duplicate '.gbk' file
rm wildtype2.gbk
ls #check if the duplicate was removed successfuly

#--STEP 7: confirming if the '.fna' file is a mutant or wild type. The presence of 'tatatata' sequence signifies mutant type while 'tata' sequence signifies the wild or normal type.
#it must also be confirmed that both types of sequence are not present in the '.fna' file
cd ../Muyideen_Sadibo #navigating to the directory where the '.fna' file was moved to.
ls #to be certain the file is present

grep "tatatata" wildtype.fna
grep "tata" wildtype.fna

if grep -q "tatatata" wildtype.fna; then
    echo "Mutant sequence 'tatatata' found."
elif grep -q "tata" wildtype.fna; then
    echo "Wildtype sequence 'tata' found."
elif grep -e "tatatata" -e "tata" wildtype.fna
    echo "Wildtype sequence 'tata' found."
else
    echo "Neither 'tatatata' nor 'tata' found."
fi

grep -E "tatatata|tata" wildtype.fna
grep -e "tatatata" -e "tata" wildtype.fna


#--STEP 8: printing all matching lines into a new file because its a mutant
grep "tatatata" wildtype.fna > mutant_wildtype.txt
cat mutant_wildtype.txt #checking the matching lines in the new file

#--STEP 9: counting the number of lines (excluding the header) in the '.gbk'
#These files have a standardized structure. The header section typically contains information like LOCUS, DEFINITION, ACCESSION, and FEATURES. The sequence data itself is usually found after a line that begins with ORIGIN
#The most reliable way is to find the start of the sequence and then count the lines
cd ../biocomputing/ #going to the directory

awk '/ORIGIN/{p=1;next} p' wildtype.gbk | wc -l

#--STEP 10: Printing the sequence length of the .gbk file using the LOCUS tag in the first line
grep "^LOCUS" wildtype.gbk | awk '{print $3}'

#--STEP 11: printing the source organism of the wildtype.gbk file using the 'SOURCE' tag in the first line.
grep "SOURCE" wildtype.gbk | cut -c 13-

grep "SOURCE" wildtype.gbk | awk '{$1=""; print $0}' | sed 's/^ *//' #this line does it better and more reliable

#--STEP 12: listing all gene names in .gbk file
echo "Gene names in wildtype.gbk:"
grep "/gene=" wildtype.gbk

#-- STEP 13: Clear terminal and show command history
clear
echo "Command history:"
history

# ---- STEP 14: List the files in both folders
echo "Files in Muyideen_sadibo/:"
ls ../Muyideen_sadibo/

echo "Files in biocomputing/:"
ls .




# Project 2: Installing Bioinformatics Software on the Terminal

#-- STEP 1: Activate base conda environment

#First we must install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh # To run the installer and Accept the licence and choose the install location

conda init # To make Conda availabale in new shells

#Close and reopen the terminal and check the conda version
conda --version

#You must enable three important channels in a specific order even though Bioinformatics tools are hosted on one (bioconda)
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda activate base

#-- STEP 2: Create a conda environment named funtools
conda deactivate # to deactivate base environment

#Activate the rest of channels
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

conda create -n funtools -y

#-- STEP 3: Activate the funtools environment
conda activate funtools

#-- STEP 4: Install Figlet
conda install -c conda-forge figlet -y || sudo apt-get install figlet -y

#-- STEP 5: Run figlet with your name
figlet "Sadibo Muyideen Enitan"
figlet -v   # version check

#-- STEP 6: Install bwa (via bioconda)
conda install -c bioconda bwa -y
bwa 2>&1 | head -n 1   # version check

#-- STEP 7: Install blast (via bioconda)
conda install -c bioconda blast -y
blastn -version        # version check

#-- STEP 8: Install samtools (via bioconda)
conda install -c bioconda samtools -y
samtools --version     # version check

#-- STEP 9: Install bedtools (via bioconda)
conda install -c bioconda bedtools -y
bedtools --version     # version check

#-- STEP 10: Install spades.py (via bioconda)
conda install -c bioconda spades -y
spades.py --version    # version check

#-- STEP 11: Install bcftools (via bioconda)
conda install -c bioconda bcftools -y
bcftools --version     # version check

#-- STEP 12: Install fastp (via bioconda)
conda install -c bioconda fastp -y
fastp --version        # version check

#-- STEP 13: Install multiqc (via bioconda)
conda install -c bioconda multiqc -y
multiqc --version      # version check

#Final message
echo "All requested bioinformatics tools have been installed successfully in the 'funtools' environment."
