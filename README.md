This repository provides code for gap-filling carbon flux data measured with eddy covariance using Marginal Distribution Sampling (MDS) and Extreme Gradient Boosting (XGB), respectively.

![image](https://github.com/YujieLiu666/gapfilling_XGB_vs_MDS/assets/125097061/7d3ecd60-3aa3-453f-af6a-8dd31c450855)

# Environment 
- Folder Environment: python environment for XGBoost

# Input data (input.csv): 
- Flux data for Bartlett Research Forest, siteID: US-Bar, https://ameriflux.lbl.gov/sites/siteinfo/US-Bar


# Workflow
STEP 01 MDS_EProc_object.R
- IQR fitering
- u* filtering
- save RDS object for future use

STEP 02 train_XGB.ipynb
- Input data: input.csv
- XGBoost (XGB) to gapfill FCO2
- 10 fold cross validation is used

STEP 03 MDS_10_CV.Rmd
- Gap filling using MDS, following the same cross-validation (10 fold) to ensure the best comparison between MDS and XGB.

STEP 04 ANN_create_synthetic_data.ipynb
- The script was executed on Google Colab with the purpose of generating synthetic data using an Artificial Neural Network (ANN). The script is adapted Vekuri et al. 2023, https://doi.org/10.1038/s41598-023-28827-2

STEP 05 generate_data_for_scenarios.Rmd
- To generate data for different experimental scenario 1,2 and 3, as described in the manuscript.
- Experimental scenario 1: different gap lengths
- Experimental scenario 2: different gap timing or locations
- Experimental scenario 3: different subset (by year) of input data

STEP 06 repeat STEP 02 and 03 for different scenarios



