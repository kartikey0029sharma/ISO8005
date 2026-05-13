# ISO8005 — Tyne Artisan Bakery (TAB) Report

> Module: **ISO8005 — Web & Social Media Analytics**, Newcastle University Business School
> Assignment: Individual report (2,000 words), AY 2025–26
> Deliverable: A data-led, AI-augmented go-to-market plan for Tyne Artisan Bakery anchored on **Monthly Active Local Customers (MALC)** as the North Star metric.

---

## Repository layout

```
ISO8005_TAB_Report/
├── ISO8005_TAB_Report.Rmd           # Master report (knit in RStudio)
├── README.md                         # This file
├── data/
│   └── ISO8005_TAB_issued_AY2526.xlsx
├── scripts/
│   ├── 01_load_clean_data.R          # Tidyverse + janitor cleaning
│   ├── 02_metric_calculations.R      # CVR, AOV, ROAS, CAC, MALC, churn,
│   │                                 # seasonality, region/product mix,
│   │                                 # two-proportion z-test for A/B
│   ├── 03_visuals.R                  # 15 publication-quality figures
│   ├── 04_forecast_model.R           # Low / Base / High scenarios,
│   │                                 # sensitivity, budget reallocation,
│   │                                 # simplified Pareto/NBD CLV
│   ├── RUN_ALL.R                     # Master runner (R then PDF)
│   ├── rmd_to_md.py                  # Pandoc fallback (no-R rendering)
│   └── metadata.yaml                 # Pandoc YAML for the fallback path
├── figures/                          # 16 PNG figures @ 240 dpi
│   ├── fig1_growth_logic.png
│   ├── fig2_malc_revenue_trend.png
│   ├── ...
│   └── fig16_dashboard_snapshot.png  # Static dashboard image used in the PDF
└── output/
    ├── ISO8005_TAB_Report.pdf        # Final knitted report
    └── TAB_Dashboard.html            # Live leadership dashboard (self-contained)
```

---

## Quick start (recommended path)

In RStudio:

```r
setwd("ISO8005_TAB_Report")
source("scripts/RUN_ALL.R")
```

This runs the four analysis scripts (load → metrics → visuals → forecast), regenerates all figures, then knits `ISO8005_TAB_Report.Rmd` to `output/ISO8005_TAB_Report.pdf`.

### Pandoc fallback (no R required)

```bash
cd ISO8005_TAB_Report
python3 scripts/rmd_to_md.py > /tmp/body.md
cat scripts/metadata.yaml /tmp/body.md > /tmp/full.md
pandoc /tmp/full.md --pdf-engine=xelatex --resource-path=.:figures \
       --toc --toc-depth=3 -o output/ISO8005_TAB_Report.pdf
```

### Leadership dashboard

Open `output/TAB_Dashboard.html` in any browser — fully offline, no external scripts, KPIs and 11 charts rendered as inline SVG.

---

## What the analysis finds

| Finding | Evidence | Action |
|---|---|---|
| Only **Google** clears 1.0× ROAS (1.14×); Meta 0.82×, TikTok 0.90×, Other 0.62× | `paid_perf` | 60/25/15 Google/Meta/TikTok split until others break even |
| **North East = 20.1%** of revenue | `region_mix` | Launch market for local delivery / click & collect |
| **Mobile carries 69%** of orders | `device_mix` | Mobile-first PWA, Apple/Google Pay above the fold |
| **A/B Variant B +27.5% CVR** (z = 6.90, p < 0.001) | `ab_inference` | Ship Variant B day-one |
| Avg monthly subscription **churn 4.5%** | `monthly_metrics$churn_rate` | AI win-back flows in Q3, loyalty tier in Q4 |
| **Christmas (Dec–Feb)** is the peak, not Easter | `seasonality` | Headline campaign 6–8 wks before December |
| Base forecast: **430 → 688 MALC** in 12 months | `forecast_df` | £11.5k 12-month budget, +60% MALC |

Three productive outliers from the data — Feb 2026 revenue spike (~2×), Google CTR 2.5× rivals, and the A/B uplift exceeding the MDE by ~2.75× — are surfaced in Section 3.4.5 of the report.

---

## Rubric alignment

| Rubric criterion | Where it lives |
|---|---|
| Problem framing & SMART objectives | §3.1 |
| E-commerce MVP & UX (with AI layer) | §3.2 + Figures 8–10 |
| Channel & content strategy | §3.3 + Figure 7 |
| Analytics & measurement (weekly dashboard, owners, thresholds) | §3.7 + Figure 14 + Dashboard HTML |
| Data analysis quality (CVR/AOV/CAC/ROAS/A-B/seasonality/region) | §3.4 + Figures 2–5, 11–13 |
| Forecast & budget reallocation (Low/Base/High + sensitivity + CLV) | §3.6 + Figures 6, 15 |
| Ethics, privacy, accessibility (GDPR, WCAG 2.2 AA, AI Act) | §3.8 + Appendix B |
| Presentation (executive summary, numbered sections, page numbers, references) | front matter + §4 + References |

---

## Technical notes

- **R packages**: `tidyverse`, `readxl`, `janitor`, `lubridate`, `scales`, `knitr`, `patchwork`. Optional: `ggrepel` (the Rmd ships with a safety fallback so it knits without).
- **LaTeX**: xelatex via `tinytex`. All Unicode glyphs in the Rmd are written as TeX math (`$\geq$`, `$\times$`, `$\alpha$`), so no extra `.sty` files are required.
- **Reproducibility**: every figure and metric is recomputed from `data/`. Re-running `RUN_ALL.R` reproduces the report bit-for-bit.

---

## Live links

- **Interactive dashboard (offline HTML):** `output/TAB_Dashboard.html`
- **Source repo (placeholder):** `https://github.com/<your-handle>/iso8005-tab-report` *(replace `<your-handle>` after publishing)*

---

## Credits

Module tutor: Nick Howey, Newcastle University Business School.
Dataset: TAB issued workbook (`ISO8005 Tyne Artisan Bakery(TAB) issued AY2526.xlsx`).
AI assistance: scaffolding and code review only — all original ideas, analysis design, and writing produced by the student (per the assignment's AI-use policy).
