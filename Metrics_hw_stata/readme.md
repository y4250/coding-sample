# Metrics Homework

This repository contains part of the code for my Metrics homework, primarily written in Stata. Below is a summary of the key files and their objectives and methods.

## `ps2.do`

### Purpose:
- Demonstrates the Central Limit Theorem (CLT) using simulated sample means from binomial and chi-square distributions. Shows how sample means converge to a normal distribution as sample size increases.

### Method:
- Simulates sample means from binomial and chi-square distributions with varying sample sizes.
- Visualizes convergence with histograms and overlays of the normal distribution to confirm the CLT’s implications.

## `ps3.do`

### Purpose:
- Verifies the properties of the projection matrix in a regression context.

### Method:
- Performs matrix-based checks to confirm that the projection matrix follows its theoretical properties.

## `ps5.do`

### Purpose:
- Performs linear regression on two datasets (`TeachingRatings.dta` and `caschool.dta`), calculates coefficient estimates, and tests specific hypotheses.

### Method:
- Calculates regression coefficients.
- Creates matrices for hypothesis testing and conducts F-tests to evaluate hypotheses about parameter combinations.

## `ps6.do`

### Purpose:
- Conducts regression analyses and hypothesis tests on multiple datasets. Tests for parameter equality and performs robust regressions.

### Method:
- Calculates log differences for economic variables, applies constraints, and tests for parameter equality.
- Performs robust regressions and creates matrices for error calculations and variance estimation.

## `ps7.do`

### Purpose:
- Performs 2SLS instrumental variable regressions and conducts diagnostic tests to validate the robustness of the estimates.

### Method:
- Uses 2SLS regression with specific instruments.
- Performs diagnostic tests, including joint significance, endogeneity, and instrument validity tests.

## `ps8.do`

### Purpose:
- Analyzes panel data using fixed and random effects models, compares these models using the Hausman test, and interprets the results.

### Method:
- Runs fixed and random effects regressions on democracy index with GDP per capita.
- Conducts Hausman tests, calculates predictions, confidence intervals, and uses clustered standard errors for robust results.
