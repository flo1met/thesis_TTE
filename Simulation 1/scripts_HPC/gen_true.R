library(TrialEmulation)
library(tidyverse)
source("scripts/simulate_MSM_simplified.R")
library(furrr)
library(survival)
library(arrow)

nvisit = 5 # number of visits
nsample = c(200, 1000, 5000) # sample size
a_y = c(-4.7, -3.8, -3.0) # outcome event rate
a_c = c(0.1, 0.5, 0.9) # confounding strength
a_t = c(-1, 0, 1) # treatment prevalence

scenarios <- expand.grid(nvisits = nvisit, 
                         nsample = nsample, 
                         a_y = a_y, 
                         a_c = a_c, 
                         a_t = a_t)

# Define log file
log_file <- "out/true_values/error_log.txt"

sim_save_fun <- function(nvisits, nsample, a_y, a_c, a_t) {
  tryCatch({
    data_1 <- DATA_GEN_censored_reduced(
      ns = nsample,
      nv = nvisits,
      outcome_prev = a_y,
      conf = a_c,
      treat_prev = a_t,
      censor = FALSE,
      all_treat = TRUE
    )
    
    data_0 <- DATA_GEN_censored_reduced(
      ns = nsample,
      nv = nvisits,
      outcome_prev = a_y,
      conf = a_c,
      treat_prev = a_t,
      censor = FALSE,
      all_control = TRUE
    )
    
    surv0 <- survfit(Surv(t, Y) ~ 1, data = data_0)
    surv1 <- survfit(Surv(t, Y) ~ 1, data = data_1)
    
    summary_surv0 <- summary(surv0, times = 0:4)
    summary_surv1 <- summary(surv1, times = 0:4)
    
    MRD <- data.frame(
      fup = 0:4,
      True_MRD = summary_surv1$surv - summary_surv0$surv
    )
    
    out_file <- paste0("out/true_values/true_", nsample, "_", a_y, "_", a_c, "_", a_t, ".arrow")
    write_feather(MRD, sink = out_file)
    
  }, error = function(e) {
    msg <- paste0(Sys.time(), " | Error for: nsample=", nsample,
                  ", a_y=", a_y, ", a_c=", a_c, ", a_t=", a_t,
                  "\n", conditionMessage(e), "\n\n")
    write(msg, file = log_file, append = TRUE)
  })
}

plan(multisession, 
     workers = 27)
set.seed(1337)
future_pwalk(scenarios, sim_save_fun,
             .options = furrr_options(seed = TRUE))
