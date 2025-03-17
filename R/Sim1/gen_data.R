library(TrialEmulation)
args <- commandArgs(trailingOnly = TRUE)
SEED <- as.integer(args[1])

set.seed(SEED)

data <- TrialEmulation:::data_gen_censored(ns = 500,
                                   nv = 10,
                                   conf = 0.5,
                                   treat_prev = 1,
                                   all_treat = FALSE,
                                   all_control = FALSE,
                                   censor = TRUE)

names(data) <-c("id", "period", "treatment", "x1", "x2", "x3", "x4", "age", "age_s", "outcome", "censored", "eligible")

write.csv(data, paste0("out/Sim1/data_gen_sim", SEED, ".csv"), row.names = FALSE)
