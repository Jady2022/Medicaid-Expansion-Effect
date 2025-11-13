# Set the path
setwd("/Users/jady/Desktop/UTD/Semester Spring 2025/BUAN6312 Time Series/proposal examples")

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
#dataset after clearing:

summary(cps_clean)
nrow(cps_clean)
write.csv(cps_clean, "cps_clean_ready.csv", row.names = FALSE)

#Setting treatment group and control group
#There are 10 states did not adopt the medicaid expansion decision till now: WY, KS, TX, WI, TN, MS, AL, GA, SC, FL





