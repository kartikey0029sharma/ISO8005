# Quick test of the first two scripts
cat("Testing scripts with corrected column names...\n\n")

# Load packages
library(readxl)
library(tidyverse)
library(janitor)
library(lubridate)

# Script 1: Load data
cat("=" %r% 70, "\n", sep="")
cat("STEP 1: Loading data...\n")
cat("=" %r% 70, "\n\n", sep="")

file_path <- "data/ISO8005 Tyne Artisan Bakery(TAB) issued AY2526 (1).xlsx"

monthly_marketing <- read_excel(file_path, sheet = "monthly_marketing") %>% clean_names()
paid_campaigns <- read_excel(file_path, sheet = "paid_campaigns") %>% clean_names()
web_analytics <- read_excel(file_path, sheet = "web_analytics") %>% clean_names()
orders <- read_excel(file_path, sheet = "orders") %>% clean_names()
ab_test <- read_excel(file_path, sheet = "ab_test") %>% clean_names()
social_metrics <- read_excel(file_path, sheet = "social_metrics") %>% clean_names()

cat("✓ Data loaded\n")
cat("Rows in monthly_marketing:", nrow(monthly_marketing), "\n")
cat("Rows in orders:", nrow(orders), "\n")
cat("Rows in paid_campaigns:", nrow(paid_campaigns), "\n\n")

# Test monthly metrics calculation
cat("Testing metric calculations...\n")
monthly_metrics <- monthly_marketing %>%
  mutate(
    cvr = ifelse(website_sessions > 0, orders / website_sessions, NA),
    aov = ifelse(orders > 0, revenue / orders, NA),
    blended_roas = ifelse(total_ad_spend > 0, revenue / total_ad_spend, NA),
    cac_proxy = ifelse(orders > 0, total_ad_spend / orders, NA)
  ) %>%
  arrange(month)

cat("✓ Monthly metrics calculated\n")
cat("\nSample monthly metrics:\n")
print(monthly_metrics %>% select(month, cvr, aov, blended_roas, cac_proxy) %>% head(3))

cat("\n✓ TEST PASSED - Ready to run full RUN_ALL.R\n")
