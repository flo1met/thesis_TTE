library(TrialEmulation)
library(tidyverse)

files <- list.files("02_appendix_F/datasets/", full.names = TRUE)

results <- data.frame(file = character(), time_seconds = numeric(), alloc_kb = numeric())

for (f in files) {
  message("Processing ", f)
  dat <- read_csv(f, show_col_types = FALSE)

  # temporray profiling file
  mem_file <- tempfile(fileext = ".out")

  # start profiling memory
  Rprofmem(mem_file)

  t <- system.time({
    out_te <- initiators(dat,
                         id = "ID",
                         period = "t",
                         treatment = "A",
                         outcome = "Y",
                         eligible = "eligible",
                         estimand_type = "ITT",
                         model_var = "assigned_treatment",
                         outcome_cov = c("X2", "X4"),
                         use_censor_weights = TRUE,
                         cense = "C",
                         pool_cense = "both",
                         cense_n_cov = ~ period + I(period^2),
                         cense_d_cov = ~ X2 + X4 + period + I(period^2),
                         include_followup_time = ~ followup_time + I(followup_time^2))
  })

  # stop profiling memory
  Rprofmem(NULL)

  # read memory alloc and save time and memory
  mem_lines <- readLines(mem_file)
  alloc_bytes <- sum(as.numeric(str_extract(mem_lines, "\\d+")), na.rm = TRUE)
  alloc_kb <- alloc_bytes / 1024  # convert to kilobytes

  results <- add_row(results,
                     file = basename(f),
                     time_seconds = t["elapsed"],
                     alloc_kb = alloc_kb)
}

# Save results
write_csv(results, "02_appendix_F/out/performance_summary_noCI_r.csv")

results
