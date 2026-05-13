# =============================================================================
# ISO8005 – TAB | Script 03: Publication-quality Visuals
# -----------------------------------------------------------------------------
# Purpose : Produce the 15 figures embedded in the academic report. Palette
#           and typographic conventions follow Tufte (2001) (data-ink ratio)
#           and Healy (2018) (effective faceting).
# Notes   : Where a diagram is more clearly conveyed as a schematic
#           (Fig 1, 7, 8, 9, 10, 14) the diagram is drawn with grid/patchwork
#           rather than fabricated chart data.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(scales)
  library(patchwork)
  library(ggrepel)
  library(lubridate)
})

load("scripts/calculated_metrics.RData")
load("scripts/cleaned_data.RData")

# Brand palette (earthy bakery aesthetic, WCAG-AA contrast safe on white)
BROWN  <- "#5C3A21"
COPPER <- "#B96E26"
WHEAT  <- "#D9A55E"
SAGE   <- "#5F7B5C"
NAVY   <- "#22354E"
GREY   <- "#666666"
LIGHT  <- "#EDE3D2"

theme_tab <- function(base = 10) {
  theme_minimal(base_size = base) +
    theme(
      plot.title         = element_text(face = "bold", colour = NAVY, size = base + 2),
      plot.subtitle      = element_text(colour = GREY, size = base),
      axis.title         = element_text(colour = NAVY),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.position    = "bottom",
      legend.title       = element_blank()
    )
}
theme_set(theme_tab())

if (!dir.exists("figures")) dir.create("figures")

# Helper to save consistently
save_fig <- function(plot, name, w = 9, h = 5) {
  ggsave(file.path("figures", name), plot, width = w, height = h, dpi = 300, bg = "white")
  message("  -> ", name)
}

# -----------------------------------------------------------------------------
# Note: Figures 1, 7-10 and 14 are schematic diagrams produced with the Python
#       supplementary script (see /scripts/diagrams.py) because they are
#       composed of layered boxes/arrows rather than data marks. They are
#       version-controlled alongside the dataset.
# -----------------------------------------------------------------------------

# Figure 2 – MALC + Revenue
f2 <- ggplot(malc_trend, aes(x = month)) +
  geom_col(aes(y = revenue / 30), fill = COPPER, alpha = 0.35, width = 22) +
  geom_line(aes(y = malc), colour = BROWN, linewidth = 1.2) +
  geom_point(aes(y = malc), colour = BROWN, size = 2.4) +
  scale_y_continuous(name = "Monthly Active Local Customers",
                     sec.axis = sec_axis(~ . * 30, name = "Revenue (£)",
                                         labels = label_currency(prefix = "£"))) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %y") +
  labs(title = "Figure 2: MALC and Revenue Trend",
       subtitle = "Mar 2024 – Feb 2026 (partial Mar 2026 omitted)",
       x = "Month") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_fig(f2, "fig2_malc_revenue_trend.png", 10, 5)

# Figure 3 – ROAS & CAC by channel
f3a <- ggplot(paid_perf, aes(reorder(platform, roas), roas, fill = roas >= 1)) +
  geom_col() +
  geom_hline(yintercept = 1, linetype = "dashed", colour = GREY) +
  geom_text(aes(label = sprintf("%.2fx", roas)), hjust = -0.15, colour = NAVY) +
  scale_fill_manual(values = c("TRUE" = BROWN, "FALSE" = COPPER), guide = "none") +
  coord_flip() +
  labs(title = "ROAS by paid channel", x = NULL, y = "ROAS")

f3b <- ggplot(paid_perf, aes(reorder(platform, -cac), cac)) +
  geom_col(fill = NAVY) +
  geom_hline(yintercept = mean(orders$revenue), linetype = "dashed", colour = COPPER) +
  geom_text(aes(label = sprintf("£%.1f", cac)), hjust = -0.15, colour = NAVY) +
  coord_flip() +
  labs(title = "CAC by paid channel (dashed = AOV)", x = NULL, y = "CAC (£)")

f3 <- (f3a | f3b) + plot_annotation(
  title = "Figure 3: Paid Channel Efficiency",
  subtitle = "All channels except Google operate below the 1.0x ROAS break-even line",
  theme = theme(plot.title = element_text(face = "bold", colour = NAVY))
)
save_fig(f3, "fig3_channel_roas_cac.png", 12, 5)

# Figure 4 – Region mix lollipop
f4 <- ggplot(region_mix, aes(reorder(region, revenue), revenue,
                             fill = region == "North East")) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("£%s (%.1f%%)", comma(revenue), pct_revenue)),
            hjust = -0.05, size = 3.3, colour = NAVY) +
  scale_fill_manual(values = c("TRUE" = BROWN, "FALSE" = COPPER), guide = "none") +
  scale_y_continuous(labels = label_currency(prefix = "£"),
                     limits = c(0, max(region_mix$revenue) * 1.25)) +
  coord_flip() +
  labs(title = "Figure 4: Regional Revenue Mix",
       subtitle = "North East (Tyne home market) leads at 20.1% of revenue",
       x = NULL, y = "Revenue (£)")
save_fig(f4, "fig4_region_mix.png", 10, 5.5)

# Figure 5 – A/B test with 95% confidence intervals
ab_plot <- ab_summary |>
  mutate(se = sqrt((cvr_pct/100) * (1 - cvr_pct/100) / visitors) * 100,
         lo = cvr_pct - 1.96 * se,
         hi = cvr_pct + 1.96 * se)

f5 <- ggplot(ab_plot, aes(variant, cvr_pct, fill = variant)) +
  geom_col(width = 0.55) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.15, colour = NAVY) +
  geom_text(aes(label = sprintf("%.2f%%", cvr_pct)), vjust = -1.5, colour = NAVY) +
  scale_fill_manual(values = c(A = GREY, B = BROWN), guide = "none") +
  labs(title = "Figure 5: A/B Test – Hero Banner CVR",
       subtitle = sprintf("Variant B: +%.1f%% uplift (z = %.2f, p < 0.001)",
                          ab_inference$uplift_pct, ab_inference$z),
       x = NULL, y = "Conversion rate (%)")
save_fig(f5, "fig5_ab_test_uplift.png", 8, 5)

# Figure 6 – Forecast scenarios (last full month baseline)
baseline_malc    <- malc_trend |> slice_tail(n = 1) |> pull(malc)
baseline_month   <- malc_trend |> slice_tail(n = 1) |> pull(month)
horizon <- tibble(month_ahead = 0:12) |>
  expand_grid(scenario = c("Low (+2%)", "Base (+4%)", "High (+6%)")) |>
  mutate(rate = case_when(scenario == "Low (+2%)"  ~ 0.02,
                          scenario == "Base (+4%)" ~ 0.04,
                          scenario == "High (+6%)" ~ 0.06),
         month = baseline_month %m+% months(month_ahead),
         malc  = baseline_malc * (1 + rate)^month_ahead)

f6 <- ggplot() +
  geom_line(data = malc_trend, aes(month, malc), colour = NAVY, alpha = 0.6) +
  geom_point(data = malc_trend, aes(month, malc), colour = NAVY, alpha = 0.6, size = 1.6) +
  geom_line(data = horizon, aes(month, malc, colour = scenario, linetype = scenario),
            linewidth = 1.2) +
  geom_point(data = horizon, aes(month, malc, colour = scenario), size = 1.6) +
  scale_colour_manual(values = c("Low (+2%)" = COPPER, "Base (+4%)" = BROWN, "High (+6%)" = SAGE)) +
  scale_linetype_manual(values = c("Low (+2%)" = "dashed", "Base (+4%)" = "solid", "High (+6%)" = "dotdash")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %y") +
  labs(title = "Figure 6: 12-Month MALC Forecast Scenarios",
       subtitle = sprintf("Baseline %s = %d customers", format(baseline_month,"%b %Y"), baseline_malc),
       x = "Month", y = "MALC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_fig(f6, "fig6_forecast_scenarios.png", 10, 5.5)

# Figure 11 – Seasonality
season_plot <- seasonality |>
  mutate(group = case_when(
    month_num %in% c(11, 12, 1, 2) ~ "Christmas/Winter peak",
    month_num %in% c(3, 4)         ~ "Easter shoulder",
    TRUE                            ~ "Summer / off-peak"))

f11 <- ggplot(season_plot, aes(reorder(month_lab, month_num), revenue, fill = group)) +
  geom_col(width = 0.75) +
  geom_text(aes(label = sprintf("£%.1fk", revenue/1000)), vjust = -0.4, size = 3.2, colour = NAVY) +
  scale_fill_manual(values = c("Christmas/Winter peak" = BROWN,
                               "Easter shoulder" = COPPER,
                               "Summer / off-peak" = WHEAT)) +
  scale_y_continuous(labels = label_currency(prefix = "£"),
                     limits = c(0, max(season_plot$revenue) * 1.15)) +
  labs(title = "Figure 11: Seasonality Profile",
       subtitle = "Winter (Dec-Feb) drives the revenue peak; spring (Mar-Apr) is the trough",
       x = NULL, y = "Revenue (£)")
save_fig(f11, "fig11_seasonality.png", 10, 5)

# Figure 12 – Subscription dynamics (starts vs cancels vs active)
f12 <- ggplot(monthly_metrics, aes(x = month)) +
  geom_col(aes(y = subscription_starts),  fill = SAGE,   alpha = 0.85, width = 18) +
  geom_col(aes(y = -subscription_cancels), fill = COPPER, alpha = 0.85, width = 18) +
  geom_line(aes(y = active_subscriptions / 5), colour = BROWN, linewidth = 1.2) +
  geom_point(aes(y = active_subscriptions / 5), colour = BROWN, size = 2) +
  scale_y_continuous(name = "Starts vs cancels (per month)",
                     sec.axis = sec_axis(~ . * 5, name = "Active subscriptions")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %y") +
  labs(title = sprintf("Figure 12: Subscription Engine — average churn %.1f%% per month", avg_churn*100),
       subtitle = "Sage = new starts; copper = cancels; brown line = active base",
       x = "Month") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_fig(f12, "fig12_subscription_dynamics.png", 10, 5)

# Figure 13 – Device + channel donuts
f13a <- ggplot(device_mix, aes(x = 2, y = orders, fill = device)) +
  geom_col() + coord_polar(theta = "y") + xlim(0.5, 2.5) +
  geom_text(aes(label = sprintf("%s\n%.1f%%", device, pct)),
            position = position_stack(vjust = 0.5), colour = "white", fontface = "bold") +
  scale_fill_manual(values = c(Mobile = BROWN, Desktop = COPPER), guide = "none") +
  theme_void() + ggtitle("Orders by device")

f13b <- ggplot(channel_mix, aes(x = 2, y = revenue, fill = channel)) +
  geom_col() + coord_polar(theta = "y") + xlim(0.5, 2.5) +
  scale_fill_manual(values = c(BROWN, COPPER, WHEAT, SAGE, NAVY, GREY)) +
  theme_void() + ggtitle("Revenue by acquisition channel") +
  theme(legend.position = "right", legend.title = element_blank())

f13 <- (f13a | f13b) + plot_annotation(
  title = "Figure 13: Device and Channel Mix",
  subtitle = "Mobile-led traffic (69%) and organic-led revenue (32%)",
  theme = theme(plot.title = element_text(face = "bold", colour = NAVY))
)
save_fig(f13, "fig13_device_channel.png", 11, 5)

# Figure 15 – Budget reallocation (data-driven)
total_spend <- sum(paid_perf$spend)
realloc <- paid_perf |>
  mutate(current_pct = spend / total_spend * 100,
         roas_rank   = rank(-roas),
         multi       = case_when(roas_rank == 1 ~ 1.30,
                                 roas_rank == 2 ~ 1.05,
                                 roas_rank == 3 ~ 0.85,
                                 TRUE           ~ 0.55),
         raw_rec     = current_pct * multi,
         rec_pct     = raw_rec / sum(raw_rec) * 100,
         delta_pp    = rec_pct - current_pct)

f15 <- ggplot(realloc, aes(reorder(platform, delta_pp), delta_pp,
                           fill = delta_pp >= 0)) +
  geom_col() +
  geom_text(aes(label = sprintf("%+.1f pp (%.0f%%→%.0f%%)",
                                delta_pp, current_pct, rec_pct)),
            hjust = ifelse(realloc$delta_pp >= 0, -0.05, 1.05),
            colour = NAVY, size = 3.4) +
  scale_fill_manual(values = c("TRUE" = SAGE, "FALSE" = COPPER), guide = "none") +
  coord_flip() +
  labs(title = "Figure 15: Recommended Quarterly Budget Reallocation",
       subtitle = "Boost highest-ROAS (Google); reduce sub-1.0x ROAS channels",
       x = NULL, y = "Δ share of paid budget (percentage points)")
save_fig(f15, "fig15_budget_reallocation.png", 10, 5)

message("All data-driven figures regenerated under /figures.")
message("Schematic diagrams (Figs 1, 7, 8, 9, 10, 14) generated by Python helper – see scripts/diagrams.py.")
