# =============================================================================
# ISO8005 – Tyne Artisan Bakery (TAB) | Script 01: Load & Clean Data
# -----------------------------------------------------------------------------
# Purpose : Import all sheets from the issued TAB workbook, harmonise types,
#           run quality checks, and persist a cleaned RData snapshot for the
#           downstream metric and forecasting scripts.
# Methods : Tidyverse + janitor (Wickham et al., 2019); ISO-aligned date
#           handling via lubridate (Grolemund & Wickham, 2011).
# Author  : Student Number [insert]
# =============================================================================

suppressPackageStartupMessages({
  library(readxl)
  library(tidyverse)
  library(janitor)
  library(lubridate)
})

# -----------------------------------------------------------------------------
# 1. File path & sheet inventory
# -----------------------------------------------------------------------------
file_path <- "data/ISO8005 Tyne Artisan Bakery(TAB) issued AY2526 (1).xlsx"
stopifnot(file.exists(file_path))

sheets <- excel_sheets(file_path)
message("Sheets discovered: ", paste(sheets, collapse = ", "))

# -----------------------------------------------------------------------------
# 2. Import each sheet
# -----------------------------------------------------------------------------
read_clean <- function(sheet) read_excel(file_path, sheet = sheet) |> clean_names()

monthly_marketing <- read_clean("monthly_marketing")
paid_campaigns    <- read_clean("paid_campaigns")
web_analytics     <- read_clean("web_analytics")
orders            <- read_clean("orders")
ab_test           <- read_clean("ab_test")
social_metrics    <- read_clean("social_metrics")
data_dictionary   <- read_clean("Data Dictionary")

# -----------------------------------------------------------------------------
# 3. Type harmonisation – snap each date to the first of the month so that the
#    monthly grain reconciles across sheets
# -----------------------------------------------------------------------------
month_floor <- function(x) floor_date(as.Date(x), unit = "month")

monthly_marketing <- monthly_marketing |> mutate(month = month_floor(month))
paid_campaigns    <- paid_campaigns    |> mutate(month = month_floor(month))
web_analytics     <- web_analytics     |> mutate(month = month_floor(month))
social_metrics    <- social_metrics    |> mutate(month = month_floor(month))
orders            <- orders            |> mutate(order_date = as.Date(order_date),
                                                 month      = month_floor(order_date))
ab_test           <- ab_test           |> mutate(date = as.Date(date))

# -----------------------------------------------------------------------------
# 4. Sanity / quality checks  (Wickham, 2014 – tidy data principles)
# -----------------------------------------------------------------------------
qa <- tibble(
  table        = c("monthly_marketing","paid_campaigns","web_analytics",
                   "orders","ab_test","social_metrics"),
  rows         = c(nrow(monthly_marketing), nrow(paid_campaigns), nrow(web_analytics),
                   nrow(orders), nrow(ab_test), nrow(social_metrics)),
  missing_vals = c(sum(is.na(monthly_marketing)), sum(is.na(paid_campaigns)),
                   sum(is.na(web_analytics)), sum(is.na(orders)),
                   sum(is.na(ab_test)), sum(is.na(social_metrics))),
  first_date   = c(min(monthly_marketing$month), min(paid_campaigns$month),
                   min(web_analytics$month), min(orders$order_date),
                   min(ab_test$date), min(social_metrics$month)),
  last_date    = c(max(monthly_marketing$month), max(paid_campaigns$month),
                   max(web_analytics$month), max(orders$order_date),
                   max(ab_test$date), max(social_metrics$month))
)
print(qa)

# Drop partial trailing month for trend analysis (workbook issues run mid-month)
last_full_month <- floor_date(max(orders$order_date) - days(7), "month")
message("Last complete month retained for trend analysis: ", last_full_month)

# -----------------------------------------------------------------------------
# 5. Persist cleaned objects
# -----------------------------------------------------------------------------
save(monthly_marketing, paid_campaigns, web_analytics, orders, ab_test,
     social_metrics, data_dictionary, qa, last_full_month,
     file = "scripts/cleaned_data.RData")

message("Cleaned data written to scripts/cleaned_data.RData")
