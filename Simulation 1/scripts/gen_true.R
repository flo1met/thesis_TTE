# generate true values

library(TrialEmulation)
library(tidyverse)
source("Simulation 1/scripts/simulate_MSM_simplified.R")
library(furrr)

library(survival)

nvisit = 5 # number of visits
nsample = 1e6 # sample size
a_y = c(-3.8) # outcome event rate
a_c = c(0.5) # confounding strength
a_t = c(0) # treatment prevalence

set.seed(1337)

data_1 <- DATA_GEN_censored_reduced(
  ns = nsample,
  nv = nvisit,
  outcome_prev = a_y,
  conf = a_c,
  treat_prev = a_t,
  censor = FALSE,
  all_treat = TRUE
)

data_0 <- DATA_GEN_censored_reduced(
  ns = nsample,
  nv = nvisit,
  outcome_prev = a_y,
  conf = a_c,
  treat_prev = a_t,
  censor = FALSE,
  all_control = TRUE
)

surv0 <- survfit(Surv(t, Y) ~ 1, data = data_0)
surv1 <- survfit(Surv(t, Y) ~ 1, data = data_1)
summary_surv0 <- summary(surv0)
summary_surv1 <- summary(surv1)

(MRD <- data.frame(fup = 0:4,
                   True_MRD = summary_surv1$surv - summary_surv0$surv))

write.csv(MRD, file = "Simulation 1/out/True Values/TRUE_PE.csv")






