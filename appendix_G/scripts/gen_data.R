# Simulate Data Simulation 1

library(TrialEmulation)
library(tidyverse)
source("simulation_1/scripts/simulate_MSM_simplified.R")
library(purrr)
# number of simulations
nvisit <- 5 # number of visits
nsample <- c(200, 1000, 5000) # sample size
a_y <- c(-3.8) # outcome event rate
a_c <- c(0.5) # confounding strength
a_t <- c(1) # treatment prevalence


scenarios <- expand.grid(nvisits = nvisit, 
                         nsample = nsample, 
                         a_y = a_y, 
                         a_c = a_c, 
                         a_t = a_t)




sim_save_fun <- function(
                         nvisits = nvisit, 
                         nsample = nsample, 
                         a_y = a_y, 
                         a_c = a_c, 
                         a_t = a_t) {
  data <- DATA_GEN_censored_reduced(ns = nsample, 
                            nv = nvisit, 
                            outcome_prev = a_y, 
                            conf = a_c, 
                            treat_prev = a_t, 
                            censor = TRUE)
  
  arrow::write_feather(data, sink = paste0("03_appendix_F/datasets/data_", nsample, "_", a_y, "_", a_c, "_", a_t, ".arrow"))
}

set.seed(1337)
pwalk(scenarios, sim_save_fun)
