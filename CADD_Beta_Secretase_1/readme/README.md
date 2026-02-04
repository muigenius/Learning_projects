# Computational Drug Discovery: BACE1 Inhibitors

This project focuses on the computational drug discovery process for **Beta-secretase 1 (BACE1)**, a prime therapeutic target for Alzheimer's disease. It employs machine learning techniques to predict the bioactivity of chemical compounds against BACE1.

The project is divided into three main parts, implemented as Jupyter Notebooks.

## Project Structure

### 1. Data Collection and Preprocessing
**Notebook:** `Part-1-BACE1-CDD-Data-Preprocessing.ipynb`

*   **Data Source:** Retrieves bioactivity data for Human BACE1 (ChEMBL ID: CHEMBL4822) from the ChEMBL Database using the `chembl_webresource_client`.
*   **Cleaning:** Filters for standard IC50 values, handles missing data, and removes duplicates.
*   **Normalization:** Converts IC50 values to pIC50 scale (-log10(IC50)) for better distribution.
*   **Labeling:** Classifies compounds into bioactivity classes (Active, Inactive, Intermediate) based on pIC50 thresholds.

### 2. Exploratory Data Analysis (EDA)
**Notebook:** `Part-2-BACE1-CDD-Exploratory-Data-Analysis.ipynb`

*   **Descriptor Calculation:** Computes Lipinski's Rule of Five descriptors (Molecular Weight, LogP, NumHDonors, NumHAcceptors) using `rdkit`.
*   **Chemical Space Analysis:** Visualizes the distribution of active vs. inactive compounds using scatter plots and box plots.
*   **Statistical Testing:** Performs Mann-Whitney U tests to determine statistical significance of the descriptors between bioactivity classes.
*   **Data Refinement:** Filters the dataset to keep only 'Active' and 'Inactive' classes for binary classification.

### 3. Model Building and Evaluation
**Notebook:** `Part-3-BACE1-CDD-Descriptor-Calculation-and-Classification-Random-Forest.ipynb`

*   **Feature Engineering:** Calculates molecular fingerprints (Substructure fingerprints) using `padelpy`.
*   **Feature Selection:** Removes low-variance features to reduce dimensionality.
*   **Model Training:** Trains a **Random Forest Classifier** to predict bioactivity.
*   **Evaluation:** Assesses model performance using:
    *   Matthews Correlation Coefficient (MCC)
    *   Confusion Matrix
    *   Precision-Recall Curve
    *   Cross-validation scores

## Prerequisites

This project requires Python 3 and the following libraries:

*   `chembl_webresource_client`
*   `rdkit`
*   `padelpy`
*   `pandas`
*   `numpy`
*   `seaborn`
*   `matplotlib`
*   `scipy`
*   `scikit-learn`

## Installation & Usage

1.  Clone this repository.
2.  Install the required dependencies.
3.  Run the notebooks in sequential order:
    1.  `Part-1-BACE1-CDD-Data-Preprocessing.ipynb`
    2.  `Part-2-BACE1-CDD-Exploratory-Data-Analysis.ipynb`
    3.  `Part-3-BACE1-CDD-Descriptor-Calculation-and-Classification-Random-Forest.ipynb`

## Acknowledgements

*   **ChEMBL Database** for bioactivity data.
*   **RDKit** and **PaDEL** for cheminformatics functionality.