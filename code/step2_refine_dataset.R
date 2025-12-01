# Set the path
setwd("/Users/Jady/project")

#import the dataset
cps_clean <- read.csv("cps_clean_ready_GitHub.csv")

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
write.csv(cps_clean, "cps_clean_ready_GitHub.csv", row.names = FALSE)
