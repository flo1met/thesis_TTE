library(TrialEmulation)
library(tidyverse)

files <- list.files("Simulation 2/datasets/", full.names = TRUE)

results <- data.frame(
  file = character(),
  time_seconds = numeric(),
  alloc_kb = numeric(),
  error_message = character(),
  stringsAsFactors = FALSE
)

for (f in files) {
  message("Processing ", f)
  dat <- read_csv(f, show_col_types = FALSE)

  mem_file <- tempfile(fileext = ".out")
  Rprofmem(mem_file)

  # Initialize outputs
  time_elapsed <- NA_real_
  alloc_kb <- NA_real_
  error_msg <- NA_character_

  t <- tryCatch({
    # measure time
    timing <- system.time({
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

      out_surv <- predict(out_te, predict_times = 0:4, type = "surv")[[3]]
    })

    # read memory profile only if no error
    mem_lines <- readLines(mem_file)
    alloc_bytes <- sum(as.numeric(str_extract(mem_lines, "\\d+")), na.rm = TRUE)
    alloc_kb <<- alloc_bytes / 1024
    time_elapsed <<- timing["elapsed"]
  }, error = function(e) {
    error_msg <<- conditionMessage(e)
  })

  Rprofmem(NULL)

  results <- add_row(results,
                     file = basename(f),
                     time_seconds = time_elapsed,
                     alloc_kb = alloc_kb,
                     error_message = error_msg)
}

write_csv(results, "Simulation 2/out/performance_summary_r.csv")
results
