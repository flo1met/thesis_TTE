library(TrialEmulation)

set.seed(1337)
data <- TrialEmulation:::data_gen_censored(ns = 1000,
                                            nv = 5,
                                            conf = 0.5,
                                            treat_prev = 1,
                                            all_treat = FALSE,
                                            all_control = FALSE,
                                            censor = TRUE)

names(data) <-c("id", "period", "treatment", "x1", "x2", "x3", "x4", "age", "age_s", "outcome", "censored", "eligible")

write.csv(data, "data/temp/data.csv")
