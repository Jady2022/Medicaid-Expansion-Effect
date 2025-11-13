# Medicaid Expansion & Income: A Difference-in-Differences (DID) Analysis  
### BUAN 6312 – Applied Econometrics & Time Series Analysis  
### University of Texas at Dallas  

---

## 📌 Overview  
This project analyzes the **causal impact of the 2014 Medicaid expansion** on personal income using **IPUMS-CPS microdata (2012–2016)**.  
We apply econometric methods including:

- **Naïve OLS**
- **Difference-in-Differences (DID)**
- **Two-Way Fixed Effects DID (TWFE)**
- **Triple Differences (DDD)**

Our analysis identifies heterogenous treatment effects, showing that Medicaid expansion produced **significant income gains for low-income individuals**, even though aggregate effects remain statistically weak.

---

## 📂 Repository Structure  







# 📦 **Data Availability (Raw CPS Microdata)**

The raw CPS microdata used in this project is obtained from **IPUMS CPS**.
Due to GitHub’s file size limit (25MB) and IPUMS licensing restrictions, the full raw dataset (**≈194MB, 6,068,055 rows**) cannot be uploaded to this repository.

Instead, users can reproduce the data extract by following the instructions below.

---

## 🔄 **How to Reproduce the Dataset**

1. Visit **IPUMS CPS**:
   [https://cps.ipums.org](https://cps.ipums.org)

2. Create a free IPUMS account (required for downloading CPS microdata).

3. Create a new extract and include the following variables:

```
YEAR
STATEFIP
ASECWT
AGE
SEX
RACE
EMPSTAT
LABFORCE
EDUC
INCTOT
INCWAGE
HIUFPGBASE
```

4. Choose CSV as the output format.

5. After the extract is ready, download the file and place it in the following directory of this repository:

```
data/cps_00006.csv
```

---

## 📊 **Dataset Overview**

**Total rows:** 6,068,055
**Total variables:** 12
**Years covered:** 2012–2025
**Geographic coverage:** All U.S. states and DC
**File size:** ~194MB (uncompressed)

---

## 🧩 **Important Notes About the CPS Microdata**

* Includes **top-coded income values** (e.g., `999999999` for INCTOT, `99999999` for INCWAGE)
* Contains **NIU (Not In Universe) codes** that must be cleaned
* Survey weights (`ASECWT`) vary widely (up to 44,424)
* Some variables contain **millions of missing or NIU entries**
* The dataset includes individuals aged **0 to 85**, but the project restricts to **working-age adults (18–64)**

The cleaned dataset used for analysis (`cps_clean_ready.csv`) **is included in this repository** to ensure reproducibility without requiring users to download the raw 194MB file.
