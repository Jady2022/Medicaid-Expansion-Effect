#step3_analysis.R
#    ├─ load cleaned dataset
#    ├─ sample refinement (remove states, pick treatment/control)
#    ├─ pre-trend EDA
#    ├─ create final analysis dataset
#    ├─ run DID / TWFE / DDD
#    ├─ export outputs


# Set the path
setwd("/Users/Jady/project")

#import the dataset
cps_clean <- read.csv("cps_clean_ready_GitHub.csv")

summary(cps_clean)
nrow(cps_clean)

#Continue to define the treatment and control groups
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


