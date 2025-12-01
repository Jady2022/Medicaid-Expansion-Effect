# Medicaid Expansion and Income: A Difference-in-Differences Analysis

## Overview

This project analyzes the impact of the 2014 Medicaid expansion on individual income using IPUMS-CPS microdata (2012–2016).
Methods include OLS, Difference-in-Differences (DiD), Two-Way Fixed Effects (TWFE), and Triple Differences (DDD).
Findings show no significant overall income effects, but meaningful gains for low-to-middle-income groups in the DDD model.

## Repository Structure

```
code/
dataclean.R # Data cleaning script
model build.R # Modeling and regression script

data/
cps_clean_ready_GitHub.csv # Cleaned CPS dataset (18–64, valid income, etc.)

docs/
Medicaid_Expansion_CPS_Analysis_Deck.pdf # Presentation slides
Medicaid_Expansion_CPS_Analysis_Report_Github_APA7.pdf # Full written report

README.md # Project overview and documentation

```

## Data Source

Raw microdata: IPUMS-CPS, University of Minnesota
https://doi.org/10.18128/D030.V11.0

Raw data not included due to size and licensing restrictions.
Variables used: YEAR, STATEFIP, AGE, SEX, RACE, ASECWT, EMPSTAT, LABFORCE, EDUC, INCWAGE, INCTOT, HIUFPGBASE.

## Dataset Overview

* Total rows: 6,068,055
* Total variables: 12
* Years covered: 2012–2025
* Geographic coverage: All U.S. states and DC
* File size: ~194MB (uncompressed)


## Cleaned Dataset

The cleaned dataset (`cps_clean_ready_GitHub.csv`) includes working-age adults (18–64) with valid income, education, employment, and state identifiers.

Cleaning steps:

* Filtered AGE 18–64
* Removed NIU/invalid codes (STATEFIP ≥ 99, SEX=9, RACE=999, EMPSTAT=00, LABFORCE=0, EDUC=001)
* Removed IPUMS missing-value income codes (999999998, 999999999)
* Removed negative/missing income values

## Methods & Findings

* OLS: positive but likely biased
* DiD/TWFE: no significant overall effect
* DDD: +$567 income gain for low-to-middle-income individuals
* Interpretation: Medicaid expansion benefits economically vulnerable groups more than the general population

## Key Findings

* Overall effects become statistically insignificant after adding controls and fixed effects.
* Low-to-middle-income individuals show a significant income gain (+$567) after expansion.
* Results align with the view that Medicaid expansion benefits economically vulnerable groups more than the general population.

## Limitations

* State self-selection into expansion may introduce endogeneity.
* Possible omitted variables (health status, informal work).
* Measurement issues (mobility, reporting errors).
* Parallel trends assumption only partially testable.

## Reproducibility

1. Download IPUMS extract
2. Run `dataclean.R`
3. Run `model_build.R`
4. Refer to the report and slides for model specifications and interpretation

## Acknowledgment

Data provided by IPUMS-CPS, University of Minnesota.
