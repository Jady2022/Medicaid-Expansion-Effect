## Medicaid Expansion and Income: A Difference-in-Differences Analysis


### ⭐ **Project Summary (Quick Overview)**

This project analyzes the income effects of the **2014 Medicaid Expansion** using **6M+ CPS microdata (2012–2016)**.
It follows a full causal inference workflow:

* Data cleaning (NIU removal, variable filtering, income fixes)
* Exploratory diagnostics (distribution, age/education income patterns)
* Treatment/control selection
* Parallel trends validation
* DID / TWFE / DDD estimation

**Key Skills Demonstrated**

* Handling large datasets efficiently
* Building reproducible pipelines (step1 → step2 → step3)
* Causal modeling with fixed effects
* Clear documentation for reproducibility

**Main Insight:**
Although overall income effects are insignificant, **low-to-middle-income individuals gained +$567** after expansion (DDD model).



### 👤 **About Me (For Recruiters & Hiring Managers)**

Hi, I'm **Ruocheng Jiang** — Master’s student in **Business Analytics @ UT Dallas** (Graduating Dec 2025).

I specialize in:

* Large-scale data analysis (6M+ CPS microdata, manufacturing analytics, etc.)
* Econometrics & causal inference (DID / TWFE / DDD)
* AI & applied analytics for business decision-making
* Building clean, modular, reproducible pipelines
* Communicating technical insights clearly to non-technical audiences

If you're a recruiter/hiring manager:

👉 **This project demonstrates my ability to handle messy real-world data, validate causal assumptions, and run advanced causal models end-to-end.**
Happy to connect!

📧 **Email:** [jrc3699@outlook.com](mailto:jrc3699@outlook.com)
🔗 **LinkedIn:** [https://www.linkedin.com/in/ruocheng-jiang/](https://www.linkedin.com/in/ruocheng-jiang/)




### Repository Structure

```
code/
  step1_dataclean.R        # Basic data cleaning on raw CPS extract
  step2_refine_dataset.R   # EDA and construction of analytic sample
  step3_analysis.R         # T/C selection, parallel trend checks, DID/TWFE/DDD models

data/
  cps_clean_ready_GitHub.csv   # Cleaned dataset (18–64, valid income, NIU removed)

docs/
  Medicaid_Expansion_CPS_Analysis_Deck.pdf       # Presentation slides
  Medicaid_Expansion_CPS_Analysis_Report.pdf     # Full written report

README.md


```

### Data Source

Raw microdata is obtained from **IPUMS-CPS, University of Minnesota**:
[https://doi.org/10.18128/D030.V11.0](https://doi.org/10.18128/D030.V11.0)

Raw data is **not included** due to size and licensing restrictions.
Variables used in this analysis:

```
YEAR, STATEFIP, AGE, SEX, RACE, ASECWT,
EMPSTAT, LABFORCE, EDUC, INCWAGE, INCTOT, HIUFPGBASE
```

To reproduce raw results, users must download the CPS extract from IPUMS using their own account.

### Dataset Overview

* Total rows: 6,068,055
* Total variables: 12
* Years: 2012–2016
* Coverage: All U.S. states + DC
* File size: ~194MB (uncompressed)


### Cleaned Dataset

The cleaned dataset (`cps_clean_ready_GitHub.csv`) includes working-age adults (18–64) with valid income, education, employment, and state identifiers.

Cleaning steps:

* Filtered AGE 18–64
* Removed NIU/invalid codes (STATEFIP ≥ 99, SEX=9, RACE=999, EMPSTAT=00, LABFORCE=0, EDUC=001)
* Removed IPUMS missing-value income codes (999999998, 999999999)
* Removed negative/missing income values

### Methods & Findings

`step3_analysis.R` performs:

* Construction of treatment and control groups
* Pre-treatment parallel trend diagnostics
* DID, TWFE, and DDD estimation

Summary of results:

* OLS suggests a positive association but is likely biased.
* DiD and TWFE show **no significant overall income effect**.
* DDD identifies **~$567 in income gains** for low-to-middle-income individuals.
* Interpretation: Medicaid expansion primarily benefits economically vulnerable groups rather than the overall population.

### Limitations

* State self-selection may introduce endogeneity concerns.
* Some variables (health status, informal work, mobility) are unobserved in CPS.
* CPS income variables include measurement error.
* Parallel trends assumption can only be partially validated.

### How to Run the Project

#### **Option A — Full Replication (requires raw CPS extract)**

```
1. Download the raw CPS extract from IPUMS-CPS.
2. Place the extract in the /data directory.
3. Run `step1_dataclean.R` to generate the cleaned dataset.
4. Run `step2_refine_dataset.R` for EDA and analytic sample construction.
5. Run `step3_analysis.R` to reproduce all models.
```

#### **Option B — Run Only the Causal Models (no IPUMS required)**

```
1. Use the provided `cps_clean_ready_GitHub.csv`.
2. Skip step1 and step2.
3. Run `step3_analysis.R` to generate all DID/TWFE/DDD results.
```

#### Outputs include:

* Regression results for all models
* Parallel trend diagnostics
* Final treatment/control states
* Summary tables (in console output)
* Full interpretation in the report and slide deck

### Project Highlights

* **Large-scale data processing:** Cleaned and analyzed a 6M+ row CPS microdataset.
* **Causal inference pipeline:** Implemented complete DID → TWFE → DDD workflow.
* **Parallel trends diagnostics:** Custom slope analysis and visualization.
* **Reproducible structure:** Modular 3-step R scripts.
* **Effective communication:** Includes both report and slide deck.


### Acknowledgment

Data provided by IPUMS-CPS, University of Minnesota.
Users who wish to reproduce the entire workflow must download the original CPS extract directly from IPUMS-CPS. 
IPUMS requires users to obtain data through their own registered account.

