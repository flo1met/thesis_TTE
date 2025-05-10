# Estimate Simulation R

library(arrow)
library(TrialEmulation)
library(furrr)
#library(tictoc)

# Define a log file for errors
log_file <- "Simulation 1/out/R/error_log_20250410.txt"

#tic()
files <- data.frame(file = list.files("Simulation 1/datasets/"))

# Get list of processed files from the Julia directory
files_already_processed <- list.files("out/R/")

# Remove "R_MRD_" from the beginning of the file names
files_already_processed <- sub("^R_MRD_", "", files_already_processed)

# Filter to keep only files that contain ".arrow"
files <- grep(".arrow", files, value = TRUE)
files_already_processed <- grep(".arrow", files_already_processed, value = TRUE)

# Filter out files that have already been processed
files <- setdiff(files, files_already_processed)

est <- function(file) {
  tryCatch({
    data <- read_feather(paste0("Simulation 1/datasets/", file))
    
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
    
    write_feather(out_surv, sink = paste0("Simulation 1/out/R/R_MRD_", file))
  }, error = function(e) {
    # Capture error and append to log file
    msg <- paste(Sys.time(), "Error in file:", file, "\n", conditionMessage(e), "\n\n")
    write(msg, file = log_file, append = TRUE)
  })
}

# Parallel execution
plan(multisession)
set.seed(1337)
future_pwalk(files, est,
             .options = furrr_options(seed = TRUE), .progress = TRUE)
plan(sequential)
#toc()


# test
#files = c("test.txt", "data_200_1.arrow", "data_200_10.arrow","data_200_16.arrow","data_200_15.arrow","data_200_14.arrow","data_200_13.arrow","data_200_12.arrow")
#files_already_processed = c("test2.txt", "R_MRD_data_200_1.arrow", "R_MRD_data_200_10.arrow")
