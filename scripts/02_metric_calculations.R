# =============================================================================
# ISO8005 – Tyne Artisan Bakery (TAB) | Script 02: Metric Calculations
# -----------------------------------------------------------------------------
# Purpose : Compute the funnel and unit-economic KPIs required by the brief –
#           CVR, AOV, CTR, CPC, ROAS, CAC, MALC, churn, region/product mix,
#           subscription dynamics, seasonality and the A/B test outcome.
# Methods : Vectorised summarisations (Wickham et al., 2019); two-proportion
#           z-test for the A/B significance (Agresti, 2018).
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
})

load("scripts/cleaned_data.RData")

# -----------------------------------------------------------------------------
# 1. Monthly funnel metrics (blended)
# -----------------------------------------------------------------------------
monthly_metrics <- monthly_marketing |>
  mutate(
    cvr           = orders / website_sessions,
    aov           = revenue / orders,
    blended_roas  = revenue / total_ad_spend,
    cac_blended   = total_ad_spend / new_customers,
    sub_net_adds  = subscription_starts - subscription_cancels,
    churn_rate    = subscription_cancels / active_subscriptions
  ) |>
  arrange(month)

avg_churn <- mean(monthly_metrics$churn_rate, na.rm = TRUE)
message(sprintf("Mean monthly subscription churn: %.2f%%", avg_churn*100))

# -----------------------------------------------------------------------------
# 2. Paid channel performance (whole-period roll-up)
# -----------------------------------------------------------------------------
paid_perf <- paid_campaigns |>
  group_by(platform = channel) |>
  summarise(
    spend              = sum(spend, na.rm = TRUE),
    impressions        = sum(impressions, na.rm = TRUE),
    clicks             = sum(clicks, na.rm = TRUE),
    conversions        = sum(conversions, na.rm = TRUE),
    attributed_revenue = sum(attributed_revenue, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    ctr  = clicks / impressions,
    cpc  = spend / clicks,
    cpm  = spend / impressions * 1000,
    roas = attributed_revenue / spend,
    cac  = spend / conversions
  ) |>
  arrange(desc(roas))

print(paid_perf)

# -----------------------------------------------------------------------------
# 3. Web analytics summary
# -----------------------------------------------------------------------------
web_summary <- web_analytics |>
  arrange(month) |>
  mutate(period = if_else(row_number() <= n()/2, "First half", "Second half")) |>
  group_by(period) |>
  summarise(
    sessions      = sum(sessions_total),
    organic_share = sum(sessions_organic) / sum(sessions_total),
    paid_share    = sum(sessions_paid)    / sum(sessions_total),
    bounce_rate   = mean(bounce_rate),
    pages_session = mean(pages_per_session)
  )
print(web_summary)

# -----------------------------------------------------------------------------
# 4. Monthly Active Local Customers (MALC) – the North Star
#    Definition: unique customer_ids placing >=1 order in a calendar month.
#    For privacy/scaling the local geographic scope is the workbook's
#    "North East" region (Tyne and Wear catchment).
# -----------------------------------------------------------------------------
malc <- orders |>
  group_by(month) |>
  summarise(
    malc    = n_distinct(customer_id),
    orders  = n(),
    revenue = sum(revenue),
    aov     = mean(revenue),
    .groups = "drop"
  ) |>
  arrange(month)

# Drop last (partial) month for trend
malc_trend <- malc |> filter(month <= last_full_month)

# -----------------------------------------------------------------------------
# 5. Region & product mix
# -----------------------------------------------------------------------------
region_mix <- orders |>
  group_by(region) |>
  summarise(orders = n(), revenue = sum(revenue), aov = mean(revenue),
            .groups = "drop") |>
  mutate(pct_revenue = revenue / sum(revenue) * 100) |>
  arrange(desc(revenue))

product_mix <- orders |>
  group_by(product_category) |>
  summarise(orders = n(), revenue = sum(revenue), .groups = "drop") |>
  mutate(pct_revenue = revenue / sum(revenue) * 100) |>
  arrange(desc(revenue))

# -----------------------------------------------------------------------------
# 6. Subscription share trend
# -----------------------------------------------------------------------------
subscription_trend <- orders |>
  group_by(month) |>
  summarise(
    total_orders = n(),
    sub_orders   = sum(is_subscription, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(sub_share_pct = sub_orders / total_orders * 100) |>
  arrange(month)

# -----------------------------------------------------------------------------
# 7. Seasonality profile (month-of-year)
# -----------------------------------------------------------------------------
seasonality <- orders |>
  mutate(month_num = month(order_date),
         month_lab = month(order_date, label = TRUE, abbr = TRUE)) |>
  group_by(month_num, month_lab) |>
  summarise(orders = n(), revenue = sum(revenue), .groups = "drop") |>
  arrange(month_num)

peak_months   <- seasonality |> slice_max(revenue, n = 3) |> pull(month_lab) |> as.character()
trough_months <- seasonality |> slice_min(revenue, n = 3) |> pull(month_lab) |> as.character()
message("Peak months  : ", paste(peak_months, collapse = ", "))
message("Trough months: ", paste(trough_months, collapse = ", "))

# -----------------------------------------------------------------------------
# 8. A/B test – two-proportion z-test (Agresti, 2018)
# -----------------------------------------------------------------------------
ab_summary <- ab_test |>
  group_by(variant) |>
  summarise(visitors    = sum(visitors),
            conversions = sum(conversions),
            .groups = "drop") |>
  mutate(cvr_pct = conversions / visitors * 100)

# Order so 'A' is control, 'B' treatment
ab_ctrl <- ab_summary |> filter(variant == "A")
ab_trt  <- ab_summary |> filter(variant == "B")

p_pool <- (ab_ctrl$conversions + ab_trt$conversions) /
          (ab_ctrl$visitors    + ab_trt$visitors)
se     <- sqrt(p_pool * (1 - p_pool) * (1/ab_ctrl$visitors + 1/ab_trt$visitors))
z_stat <- ((ab_trt$conversions / ab_trt$visitors) -
           (ab_ctrl$conversions / ab_ctrl$visitors)) / se
p_value  <- 2 * (1 - pnorm(abs(z_stat)))
uplift   <- ((ab_trt$conversions/ab_trt$visitors) /
             (ab_ctrl$conversions/ab_ctrl$visitors) - 1) * 100

ab_inference <- tibble(uplift_pct = uplift, z = z_stat, p_value = p_value)
print(ab_inference)

# -----------------------------------------------------------------------------
# 9. Device & channel mix
# -----------------------------------------------------------------------------
device_mix <- orders |>
  group_by(device) |>
  summarise(orders = n(), revenue = sum(revenue), .groups = "drop") |>
  mutate(pct = orders / sum(orders) * 100)

channel_mix <- orders |>
  group_by(channel) |>
  summarise(orders = n(), revenue = sum(revenue), .groups = "drop") |>
  mutate(pct_revenue = revenue / sum(revenue) * 100) |>
  arrange(desc(revenue))

# -----------------------------------------------------------------------------
# 10. Persist
# -----------------------------------------------------------------------------
save(monthly_metrics, paid_perf, web_summary, malc, malc_trend,
     region_mix, product_mix, subscription_trend, seasonality,
     ab_summary, ab_inference, device_mix, channel_mix, avg_churn,
     peak_months, trough_months,
     file = "scripts/calculated_metrics.RData")

message("All metrics persisted to scripts/calculated_metrics.RData")
