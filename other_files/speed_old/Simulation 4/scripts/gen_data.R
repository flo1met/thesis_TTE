# Simulate Data Simulation 1

library(TrialEmulation)
library(tidyverse)
source("scripts/simulate_MSM_simplified.R")

args <- commandArgs(trailingOnly = TRUE)

seed <- as.integer(args[1]) # slurm id
nsample <-  as.integer(args[2]) # sample size


# fix parameters
nvisit <- 5 # number of visits
a_y <- -3.8 # outcome event rate
a_c <- 0.5 # confounding strength
a_t <- 0 # treatment prevalence

set.seed(seed)

data <- DATA_GEN_censored_reduced(ns = nsample, 
                            nv = nvisit, 
                            outcome_prev = a_y, 
                            conf = a_c, 
                            treat_prev = a_t, 
                            censor = TRUE)
  
readr::write_csv(data, file = paste0("out/datasets/data_", nsample, "_",  seed,".csv"))

