# =============================================================================
# ISO8005 – TAB | RUN_ALL.R   (Master runner)
# -----------------------------------------------------------------------------
# Executes the four analysis scripts in sequence and then knits the report.
# If knitr/rmarkdown/tinytex are not available, falls back to a pandoc
# rendering of the report via scripts/rmd_to_md.py and pandoc/xelatex.
# =============================================================================

start <- Sys.time()
banner <- function(x) cat("\n", strrep("=", 70), "\n", x, "\n", strrep("=", 70), "\n", sep = "")

banner("Step 1/5 — Load & clean")
source("scripts/01_load_clean_data.R", local = TRUE)

banner("Step 2/5 — Metrics")
source("scripts/02_metric_calculations.R", local = TRUE)

banner("Step 3/5 — Visuals")
source("scripts/03_visuals.R", local = TRUE)

banner("Step 4/5 — Forecast")
source("scripts/04_forecast_model.R", local = TRUE)

banner("Step 5/5 — Render report")
ok <- requireNamespace("rmarkdown", quietly = TRUE) &&
      requireNamespace("tinytex",   quietly = TRUE)
if (ok) {
  message("Rendering via rmarkdown::render() ...")
  rmarkdown::render(
    input         = "ISO8005_TAB_Report.Rmd",
    output_file   = "output/ISO8005_TAB_Report.pdf",
    output_format = "pdf_document",
    quiet         = FALSE
  )
} else {
  message("rmarkdown/tinytex not available – falling back to pandoc render.")
  system("python3 scripts/rmd_to_md.py > output/_report_body.md")
  system(paste(
    "cat scripts/metadata.yaml output/_report_body.md > output/_full.md && ",
    "pandoc output/_full.md --pdf-engine=xelatex --resource-path=.:figures ",
    "--toc --toc-depth=3 -o output/ISO8005_TAB_Report.pdf"
  ))
}

took <- round(as.numeric(difftime(Sys.time(), start, units = "mins")), 1)
cat(sprintf("\nDone in %.1f minutes. Open output/ISO8005_TAB_Report.pdf\n", took))
