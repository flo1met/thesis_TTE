# Simulate Data Simulation 1

library(TrialEmulation)
library(tidyverse)
source("01_simulation_1/scripts/simulate_MSM_simplified.R") # load DATA_GEN_censored_reduced()
library(furrr)

nsim = 1:1000# number of simulations
nvisit = 5 # number of visits
nsample = c(200, 1000, 5000) # sample size
a_y = c(-4.7, -3.8, -3.0) # outcome event rate
a_c = c(0.1, 0.5, 0.9) # confounding strength
a_t = c(-1, 0, 1) # treatment prevalence


# Grid with all scenarios to iterate over
scenarios <- expand.grid(nsim = nsim, 
                         nvisits = nvisit, 
                         nsample = nsample, 
                         a_y = a_y, 
                         a_c = a_c, 
                         a_t = a_t)


# Function to generate and save datasets
sim_save_fun <- function(nsim = nsim, 
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
  
  # Save dataset
  arrow::write_feather(data, sink = paste0("01_simulation_1/out/datasets/data_", nsample, "_", a_y, "_", a_c, "_", a_t, "_",  nsim,".arrow"))
}



# Run simulations in parallel
plan(multisession, 
     workers = 76)
set.seed(1337)
future_pwalk(scenarios, sim_save_fun,
             .options = furrr_options(seed = TRUE))
plan(sequential)



