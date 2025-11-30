# Set the path
setwd("/Users/RuochengJiang/project")

#import the dataset
cps_data <- read.csv("cps_00006.csv")

str(cps_data)
summary(cps_data)
#Count the dataset rows
nrow(cps_data)
#calculate the NULL rows for each variable
colSums(is.na(cps_data))

#INCWAGE cleaning
library(dplyr)

#remove age smaller than 18 and larger than 64
#remove STATEFIP < 99, it means 'State not identified'
#for SEX=9, it means 'NIU'
sum(cps_data$SEX == 9, na.rm = TRUE)
#for RACE=999, it means 'BLANK'
sum(cps_data$RACE == 999, na.rm = TRUE)
#for EMPSTAT(Employment status) and LABFORCE, 0 means 'NIU'
sum(cps_data$EMPSTAT == 00, na.rm = TRUE)
sum(cps_data$LABFORCE == 0, na.rm = TRUE)
#for EDUC, 001 means 'NIU or blank'
sum(cps_data$EDUC == 001, na.rm = TRUE)
#for INCTOT, Codes999999999 = N.I.U.,999999998 = Missing. (1962-1964 only),Values can be negative.
sum(cps_data$INCTOT == 999999999, na.rm = TRUE)
#for INCWAGE, Codes999999999 = N.I.U.,999999998 = Missing. (1962-1964 only)
#remove INCWAGE = 999999998 or 999999999 or NULL incomewage column, they all means N/A
sum(cps_data$INCWAGE == 999999999, na.rm = TRUE)

cps_clean <- cps_data %>%
  filter(AGE >= 18, AGE <= 64, !is.na(INCWAGE), INCWAGE >= 0,INCWAGE < 999999998, 
         STATEFIP < 99, EMPSTAT != 00, LABFORCE != 0, EDUC != 001, INCTOT < 999999998)
#dataset after clearing (steps executed in the proposal):

summary(cps_clean)
nrow(cps_clean)

#Income Distribution
ggplot(cps_clean, aes(x = INCTOT)) +
  geom_histogram(aes(y = ..density..), bins = 50, fill = "lightblue", color = "black", alpha = 0.7) +
  geom_density(color = "blue", size = 1) +
  scale_x_continuous(limits = c(-20000, 150000)) +
  labs(title = "Income Distribution with Density Curve", x = "Total Income", y = "Density") +
  theme_minimal()


#average income by age group
cps_binned_age <- cps_clean %>%
  filter(INCTOT > 0, AGE <= 64) %>%
  mutate(age_group = cut(AGE, breaks = seq(15, 65, by = 5), right = FALSE, labels = paste(seq(15, 60, by = 5), seq(19, 64, by = 5), sep = "-"))) %>%
  group_by(age_group) %>%
  summarise(mean_income = mean(INCTOT), .groups = 'drop')
ggplot(cps_binned_age, aes(x = age_group, y = mean_income)) +
  geom_col(fill = "skyblue", color = "black") +
  geom_text(aes(label = round(mean_income)), vjust = -0.5, size = 3.5, color = "black") +
  labs(title = "Average Income by Age Group",
       x = "Age Group",
       y = "Average Income ($)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


cps_binned_educ <- cps_clean %>%
  filter(INCTOT > 0, EDUC <= 125) %>%
  group_by(EDUC) %>%
  summarise(mean_income = mean(INCTOT), .groups = 'drop')
ggplot(cps_binned_educ, aes(x = factor(EDUC), y = mean_income)) +
  geom_col(fill = "darkseagreen3", color = "black") +
  geom_text(aes(label = round(mean_income, 0)), vjust = -0.5, size = 3) +
  labs(title = "Average Income by Education Level (EDUC Code)",
       x = "EDUC Code",
       y = "Average Income ($)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


#Sample Construction and Treatment–Control Group Selection

# Remove Early Expansion States
# These states expanded Medicaid before 2014 using Section 1115 waivers
# Source: Sommers et al. (2013)
early_expansion_states <- c(6, 9, 27, 34, 53, 11)  # CA, CT, MN, NJ, WA, DC
# Purpose: Avoid contamination from pre-treatment exposure
cps_clean <- subset(cps_clean, !(STATEFIP %in% early_expansion_states))

# Remove Mid-Period Expansion States (2014 after Jan 1 through 2016)
# Source: KFF rollout timeline
mid_expansion_states <- c(26, 33, 42, 18, 2, 30, 22)  # MI, NH, PA, IN, AK, MT, LA
# Purpose: These states implemented during the observation window, which complicates treatment definition
cps_clean <- subset(cps_clean, !(STATEFIP %in% mid_expansion_states))

# Define control group candidates (never expanded by 2016 OR expanded after 2016)
# Includes known non-expansion states + states with expansion in 2017 or later
control_candidates <- c(
  56, 20, 48, 55, 47, 28, 1, 13, 45, 12,  # classic non-expansion states (as of 2016)
  51, 23, 16, 49, 31, 40, 29, 46, 37      # expanded in 2017 or later
)

# Define treatment group candidates: States that expanded exactly on Jan 1, 2014
treatment_candidates <- c(
  4,   # Arizona
  5,   # Arkansas
  8,   # Colorado
  17,  # Illinois
  21,  # Kentucky
  24,  # Maryland
  32,  # Nevada
  35,  # New Mexico
  38,  # North Dakota
  39,  # Ohio
  41,  # Oregon
  44,  # Rhode Island
  54   # West Virginia
)

# Keep only treatment and control candidate states
valid_candidates <- c(treatment_candidates, control_candidates)
cps_clean <- subset(cps_clean, STATEFIP %in% valid_candidates)

# Final check: number of observations and states
nrow(cps_clean)
length(unique(cps_clean$STATEFIP))
summary(cps_clean)





# save the cleaned dataset
write.csv(cps_clean, "cps_clean_ready_050725.csv", row.names = FALSE)

#Continue to refine the treatment and control groups
#Parallel Trend
#Choose states with similar slopes and levels.
#Use avgincome slope calculation. 
#2012-2013. Choose control states with similar slopes and levels. 

df_pre <- subset(cps_clean, YEAR %in% c(2012, 2013))  # keep only 2012 and 2013
library(dplyr)
income_by_state_year <- df_pre %>%
  group_by(STATEFIP, YEAR) %>%
  summarise(avg_income = mean(INCTOT, na.rm = TRUE))
library(tidyr)
income_wide <- pivot_wider(income_by_state_year,
                           names_from = YEAR,
                           values_from = avg_income,
                           names_prefix = "Y")
income_wide <- mutate(income_wide,
                      slope = Y2013 - Y2012,
                      level_2012 = Y2012)
income_wide <- arrange(income_wide, slope)
income_wide$group <- ifelse(income_wide$STATEFIP %in% treatment_candidates, "treatment", "control")
arrange(income_wide, slope)
print(income_wide, n = Inf)

# Average Income of selected states in 2012 plot
library(ggplot2)
selected_states <- c(17, 29, 41, 12)  # Illinois, Missouri, Oregon, Florida
plot_data <- subset(income_by_state_year, STATEFIP %in% selected_states)
# Add state labels
plot_data$state <- factor(plot_data$STATEFIP,
                          levels = c(17, 29, 41, 12),
                          labels = c("Illinois (T)", "Missouri (C)",
                                     "Oregon (T)", "Florida (C)"))
ggplot(plot_data, aes(x = YEAR, y = avg_income, color = state, group = state)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Average Income Trends (2012–2013)",
       x = "Year",
       y = "Average Income",
       color = "State") +
  theme_minimal()



#Define Control Group and Treatment Group
selected_states <- c(17, 29, 41, 12)  # IL, MO, OR, FL
df_subset <- subset(cps_clean, STATEFIP %in% selected_states)
# Medicaid = 1 if state is treatment AND year >= 2014
df_subset$Medicaid <- ifelse(df_subset$STATEFIP %in% c(17, 41) & df_subset$YEAR >= 2014, 1, 0)


#Naïve Regression (Pooled OLS) 
naive_model <- lm(INCTOT ~ Medicaid, data = df_subset)
summary(naive_model)

# DID regression using feols
library(fixest)
df_subset$Treat <- ifelse(df_subset$STATEFIP %in% c(17, 41), 1, 0)
df_subset$Post <- ifelse(df_subset$YEAR >= 2014, 1, 0)

did_model <- feols(
  INCTOT ~ Post + Treat + Post:Treat,
  data = df_subset,
  cluster = ~STATEFIP
)
summary(did_model)


# TWFE DID model using feols
did_fe_model <- feols(
  INCTOT ~ Treat:Post + AGE + SEX + EDUC | STATEFIP + YEAR,
  data = df_subset,
  cluster = ~STATEFIP
)

summary(did_fe_model)


#DDD model



ggplot(data.frame(INCTOT = income_2012), aes(x = INCTOT)) +
  geom_density(fill = "lightblue", alpha = 0.6) +
  xlim(-10000, 50000) +
  labs(title = "Income Distribution in 2012 (Zoomed In)",
       x = "INCTOT",
       y = "Density") +
  theme_minimal()
#INCTOT: Total pre-tax personal income from all sources during the previous calendar year (Source: IPUMS CPS)



low_income_cutoff <- 11170 #Source: HHS Federal Poverty Guidelines 2012

#Source: Pew Research Center
#Middle-income households are those with incomes two-thirds to double 
#the national median household income, adjusted for household size
middle_income_lower <- 34418
middle_income_upper <- 102742
df_subset$IncomeGroup <- with(df_subset, ifelse(
  INCTOT < low_income_cutoff, "Low",
  ifelse(INCTOT >= middle_income_lower & INCTOT < middle_income_upper, "Middle", NA)
))
df_subset <- subset(df_subset, IncomeGroup %in% c("Low", "Middle"))


df_subset$LowMid <- ifelse(df_subset$IncomeGroup == "Low", 1, 0)
library(fixest)
ddd_model <- feols(
  INCTOT ~ Post * Treat * LowMid,
  data = df_subset,
  cluster = ~STATEFIP
)
summary(ddd_model)


