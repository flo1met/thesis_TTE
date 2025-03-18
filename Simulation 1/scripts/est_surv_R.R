# Estimate Simulation R

library(arrow)
library(TrialEmulation)




files <- list.files("Simulation 1/datasets/")

est <- function(file) {
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
}