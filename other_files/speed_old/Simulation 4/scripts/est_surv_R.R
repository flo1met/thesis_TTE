# Estimate Simulation R

library(tidyverse)
library(TrialEmulation)

args <- commandArgs(trailingOnly = TRUE)

seed <- as.integer(args[1]) # slurm id
nsample <-  as.integer(args[2]) # sample size

set.seed(seed)

data <- read.csv(paste0("out/datasets/data_", nsample, "_",  seed,".csv"))

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

