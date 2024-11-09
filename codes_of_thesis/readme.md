# Overview of the Coding Sample

This repository contains the full code for my Master's thesis, which also serves as my writing sample. The thesis explores fertility trends in China, focusing on two main research topics.

## Research Topics

1. **Effect of Sibling Number on Reproductive Decisions**
   - In this section, I analyze how the number of siblings affects individuals' reproductive choices using **Logit regressions**.

2. **Analysis of the "Comprehensive Two-Child Policy"**
   - This section examines the policy's impact on fertility behavior using **Difference-in-Differences (DID) regressions with fixed effects**.

## Data

The data used in this thesis comes from the **China Family Panel Study (CFPS)**, which collects data every two years from 2010 to 2020. Some key features of the data include:

- Over **1,000 questions** are asked annually in the survey.
- The survey includes both **quantitative and qualitative data**, much of which is in **Chinese**.
- **Variable names and questions** may change over time.
- **Translations** have been added where necessary for clarity.

## File Descriptions

### `coding_sample.do`
- **Purpose**: Contains all the code for the entire thesis. Running this file will execute the analysis for both parts of the thesis.

### `Data_clean_siblings.do`
- **Purpose**: Handles data cleaning for the first part of the thesis (analyzing the effect of sibling number on reproductive decisions).
- **Additional Notes**: I used **R** to impute missing values. The R code for this step is included as comments within the file. For the full analysis, please copy the R code into an R environment for execution.

### `regression_siblings.do`
- **Purpose**: Contains the **Logit regression** analysis for the first part of the thesis.

### `Getting_IDs.do`
- **Purpose**: Prepares the treatment and control groups for the second part of the analysis, focusing on the policy effect of the "Comprehensive Two-Child Policy".

### `main_DID_regression_tests.do`
- **Purpose**: Includes the **Difference-in-Differences (DID) regression** and related tests for analyzing the policy's effect.

### `DID_robust.do`
- **Purpose**: Contains **robustness tests** for the DID analysis in the second part of the thesis.

### `More_discussion.do`
- **Purpose**: Contains the code for generating the graphs used in the "More Discussion" section of the thesis.

## Graphs

The graphs for this thesis were created using **R**. All the R code used for generating these graphs is contained in the `graphs.r` file.

---

Feel free to review and run the code as needed. If you have any questions or need further assistance, don't hesitate to contact me.


