# Estimate Simulation R

library(arrow)
library(TrialEmulation)
library(furrr)
#library(tictoc)

# Define a log file for errors
log_file <- "01_simulation_1/out/R/error_log.txt"

#tic()
files <- data.frame(file = list.files("01_simulation_1/out/datasets/"))

est <- function(file) {
  tryCatch({
    data <- read_feather(paste0("01_simulation_1/out/datasets/", file))
    
    out_te <- initiators(data,
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
                         include_followup_time = ~followup_time + I(followup_time^2))
    
    out_surv <- predict(out_te, predict_times = 0:4, type = "surv")[[3]]
    
    write_feather(out_surv, sink = paste0("01_simulation_1/out/R/R_MRD_", file))
  }, error = function(e) {
    # Capture error and append to log file
    msg <- paste(Sys.time(), "Error in file:", file, "\n", conditionMessage(e), "\n\n")
    write(msg, file = log_file, append = TRUE)
  })
}

# Parallel execution
plan(multisession, 
     workers = 70)
set.seed(1337)
future_pwalk(files, est,
             .options = furrr_options(seed = TRUE))
plan(sequential)
#toc()
