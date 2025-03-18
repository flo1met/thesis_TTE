# Simulate Data Simulation 1

library(TrialEmulation)
library(tidyverse)
source("Simulation 1/scripts/simulate_MSM_simplified.R")

nsim = 1:1000 # number of simulations
nvisit = 5 # number of visits
nsample = c(200, 1000, 5000) # sample size
a_y = c(-4.7, -3.8, -3) # outcome event rate
a_c = c(0.1, 0.5, 0.9) # confounding strength
a_t = c(-1, 0, 1) # treatment prevelance


scenarios <- expand.grid(nsim = nsim, 
                         nvisits = nvisit, 
                         nsample = nsample, 
                         a_y = a_y, 
                         a_c = a_c, 
                         a_t = a_t)

test <- DATA_GEN_censored_reduced(5000, 5) # 81k obs

write.csv(test, file = "Simulation 1/datasets/test.csv") #1.3mb -> ~100gb

arrow::write_feather(test, sink = "Simulation 1/datasets/test.arrow") # ~350kb -> ~ 10gb


