library(TrialEmulation)
library(microbenchmark)

data <- read.csv("data/temp/data.csv")


benchmark <- microbenchmark(initiators(
  data = data,
  id = "id",
  period = "period",
  eligible = "eligible",
  treatment = "treatment",
  estimand_type = "ITT",
  outcome = "outcome",
  model_var = "assigned_treatment",
  outcome_cov = c("x1", "x2", "x3", "x4", "age"),
  use_censor_weights = TRUE,
  cense = "censored",
  pool_cense = "both",
  cense_n_cov = ~ period + I(period^2),
  cense_d_cov = ~ x1 + x2 + x3 + x4 + age + period + I(period^2),
  include_followup_time = ~followup_time + I(followup_time^2)
))

summary(benchmark)
