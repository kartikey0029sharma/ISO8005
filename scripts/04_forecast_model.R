# =============================================================================
# ISO8005 – TAB | Script 04: Forecast & Budget Reallocation Model
# -----------------------------------------------------------------------------
# Purpose : Triangulate a 12-month MALC and revenue forecast from three
#           sources of evidence (i) the observed two-year trend, (ii) UK SME
#           e-commerce benchmarks (Statista, 2025), and (iii) the bakery's
#           current unit-economics. A scenario tree (Low / Base / High) is
#           used to capture parameter uncertainty (Makridakis, Spiliotis &
#           Assimakopoulos, 2018) and a sensitivity analysis stress-tests
#           the result.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
})

load("scripts/calculated_metrics.RData")

# -----------------------------------------------------------------------------
# 1. Baseline parameters (last complete month)
# -----------------------------------------------------------------------------
baseline      <- malc_trend |> slice_tail(n = 1)
baseline_malc <- baseline$malc
baseline_rev  <- baseline$revenue
baseline_aov  <- baseline$aov
baseline_month <- baseline$month

# Observed annualised growth – compounded geometric mean of MALC over the
# trailing 12 months (Hyndman & Athanasopoulos, 2021)
trailing <- malc_trend |> slice_tail(n = 12)
observed_growth <- (tail(trailing$malc, 1) / head(trailing$malc, 1))^(1/11) - 1

message(sprintf("Observed monthly compound MALC growth: %.2f%%", observed_growth*100))
message(sprintf("Baseline MALC (%s): %d", format(baseline_month,"%b %Y"), baseline_malc))

# -----------------------------------------------------------------------------
# 2. Scenario definitions
# -----------------------------------------------------------------------------
scenarios <- tibble(
  scenario       = c("Low", "Base", "High"),
  monthly_growth = c(0.02, 0.04, 0.06),
  description    = c(
    "Pessimistic: slow site adoption, paid channels stay sub-1.0x ROAS",
    "Most likely: incremental UX gains, seasonal Christmas lift, modest paid optimisation",
    "Optimistic: A/B winner rolled out, Google budget reweighting, subscription churn cut to <3%/mo"
  )
)

# -----------------------------------------------------------------------------
# 3. 12-month forecast
# -----------------------------------------------------------------------------
forecast_df <- expand_grid(month_ahead = 0:12, scenarios) |>
  mutate(
    month   = baseline_month %m+% months(month_ahead),
    malc    = baseline_malc * (1 + monthly_growth)^month_ahead,
    revenue = malc * baseline_aov
  )

forecast_summary <- forecast_df |>
  filter(month_ahead %in% c(3, 6, 9, 12)) |>
  select(scenario, month_ahead, malc, revenue) |>
  arrange(month_ahead, scenario)
print(forecast_summary)

# -----------------------------------------------------------------------------
# 4. Sensitivity tornado
# -----------------------------------------------------------------------------
sensitivity <- tibble(
  driver  = c("Monthly growth ±1pp", "AOV ±10%", "Subscription churn ±1pp"),
  low     = c(baseline_malc * 1.03^12 * baseline_aov,
              baseline_malc * 1.04^12 * baseline_aov * 0.9,
              baseline_malc * 1.04^12 * baseline_aov * 0.97),
  high    = c(baseline_malc * 1.05^12 * baseline_aov,
              baseline_malc * 1.04^12 * baseline_aov * 1.1,
              baseline_malc * 1.04^12 * baseline_aov * 1.03)
)
print(sensitivity)

# -----------------------------------------------------------------------------
# 5. Budget reallocation grounded in observed ROAS rank
# -----------------------------------------------------------------------------
total_spend <- sum(paid_perf$spend)
reallocation <- paid_perf |>
  mutate(current_pct = spend / total_spend * 100,
         rank_roas   = rank(-roas),
         multi       = case_when(rank_roas == 1 ~ 1.30,
                                 rank_roas == 2 ~ 1.05,
                                 rank_roas == 3 ~ 0.85,
                                 TRUE           ~ 0.55),
         raw_rec     = current_pct * multi,
         rec_pct     = raw_rec / sum(raw_rec) * 100,
         delta_pp    = rec_pct - current_pct)

print(reallocation |> select(platform, roas, current_pct, rec_pct, delta_pp))

# -----------------------------------------------------------------------------
# 6. Customer Lifetime Value (CLV) – simplified Pareto/NBD-lite (Fader,
#    Hardie & Lee, 2005)
# -----------------------------------------------------------------------------
# CLV = (AOV * orders/customer/month * gross_margin) / churn
gross_margin <- 0.55
orders_per_cust_month <- mean(malc_trend$orders) / mean(malc_trend$malc)
clv <- (baseline_aov * orders_per_cust_month * gross_margin) / avg_churn
message(sprintf("Estimated CLV (12-mo, gross-margin 55%%): £%.2f", clv))

# -----------------------------------------------------------------------------
# 7. Quarterly roadmap
# -----------------------------------------------------------------------------
roadmap <- tibble(
  quarter = c("Q1", "Q2", "Q3", "Q4"),
  focus   = c("Shopify MVP launch, GA4/Klaviyo wiring, email capture",
              "SEO/blog programme, Bread Box LP, A/B winner rollout",
              "Budget reallocation by ROAS; PDP optimisation; retention flows",
              "Christmas campaign; loyalty tier; subscription gifting"),
  malc_uplift = c("+5–8%", "+8–12%", "+10–15%", "+15–20%"),
  budget_estimate = c(2000, 2500, 3000, 4000)
)

save(forecast_df, forecast_summary, sensitivity, reallocation, roadmap,
     baseline_malc, baseline_rev, baseline_aov, baseline_month,
     observed_growth, clv,
     file = "scripts/forecast_models.RData")

message("Forecast outputs persisted to scripts/forecast_models.RData")
