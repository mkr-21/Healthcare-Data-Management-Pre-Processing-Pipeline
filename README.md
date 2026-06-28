# Healthcare Data Management & Pre-Processing Pipeline

## 📌 Project Overview
This project demonstrates an end-to-end data management and pre-processing pipeline for a synthetic Healthcare Dataset comprising 55,000 patient records. The objective is to transition raw, noisy healthcare data into a clean, normalized, and encoded dataset ready for predictive modeling and operational analytics.

**Primary Business Goals:**
*   **Resource Optimization:** Analyzing admission trends (e.g., Emergency vs. Elective) to assist in hospital staff and resource scheduling.
*   **Billing Validation:** Formulating data validation rules to detect and eliminate financial anomalies (e.g., negative billing amounts).
*   **Clinical Insights:** Preparing data to evaluate patient recovery rates and high-risk demographic clusters.

## 🛠 Tech Stack
*   **Language & Environment:** SAS Studio
*   **Techniques Applied:** Exploratory Data Analysis (EDA), Outlier Detection, Feature Engineering, Label Encoding, Min-Max Normalization, Data Reduction.

## 📂 Repository Structure
*   `/data`: Contains the raw and final cleaned datasets (Note: large files may be added to `.gitignore`).
*   `/src`: Contains the complete, end-to-end SAS scripts for all pipeline phases.
*   `/research`: Contains an individual research report on the application of K-Means and K-Means++ clustering algorithms in healthcare.
*   `/docs`: Project documentation and original assignment rubrics.

## 👨‍💻 Authorship & Contributions
This project was developed collaboratively by a team of four, where I served as the **Group Leader**. The complete pipeline is provided in this repository to demonstrate the end-to-end workflow. 

**My Specific Technical Contributions Include:**
1.  **Project Architecture & Leadership:** Coordinated the integration of all pipeline stages to ensure seamless data flow.
2.  **Numerical & Cost Attribute EDA:** Authored the SAS scripts (using `PROC MEANS`, `PROC UNIVARIATE`, `PROC SGPLOT`) to analyze continuous variables like `Age` and `Billing Amount`, assessing central tendency, dispersion, and data symmetry.
3.  **Data Cleaning & Validation Rules:** Engineered the conditional SAS logic to handle anomalies, including:
    *   Biological plausibility checks (Age bound between 1 and 120).
    *   Financial accuracy (Enforcing positive billing amounts and removing -$2,008.49 errors).
    *   Chronological consistency (Ensuring discharge dates sequentially follow admission dates).
4.  **Data Mining Research:** Authored an independent research paper on utilizing K-Means Clustering and K-Means++ to segment patient demographics and enable precision medicine pathways. *(See `/research/KMeans_Healthcare_Research.md`)*.

## 🚀 Pipeline Phases

### 1. Exploratory Data Analysis (EDA)
*   Conducted univariate and bivariate analysis on nominal, ordinal, ratio, and interval attributes.
*   Visualized data distributions and detected severe outliers utilizing histograms, box plots, and stacked bar charts.

### 2. Data Cleaning
*   Verified the absence of missing values (`NMISS`) across all 15 features.
*   Applied strict validation rules, dropping inconsistent records.
*   Removed exact and logical duplicate patient episodes using `PROC SORT` with `NODUPKEY`, resulting in a final clean dataset of 49,904 records.

### 3. Data Transformation & Reduction
*   **Feature Engineering:** Derived operational variables such as `Length_of_Stay` and `Billing_Per_Day`.
*   **Label Encoding:** Converted ordinal text variables (Admission Type, Test Results) into numerical formats (0, 1, 2) for machine learning compatibility.
*   **Normalization:** Applied Min-Max scaling to `Length_of_Stay` (0-1 range) to prevent scale dominance in future predictive models.
*   **Dimensionality Reduction:** Dropped high-cardinality and redundant attributes to streamline the dataset.

## ⚙️ How to Run
1. Clone this repository to your local machine.
2. Open SAS Studio and set your library path to the `/data` folder.
3. Run the scripts in the `/src` folder in sequential order (EDA -> Cleaning -> Transformation).
