library(TrialEmulation)
args <- commandArgs(trailingOnly = TRUE)
SEED <- as.integer(args[1])

data <- read.csv(paste0("out/Sim1/data_gen_sim", SEED, ".csv"))

data$x1 <- as.factor(data$x1)
data$x3 <- as.factor(data$x3)

out_te <- initiators(
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
)

cumsurv <- predict(out_te, predict_times = 0:9, type = "survival")

write.csv(cumsurv$difference, paste0("out/Sim1/cumsurvR", SEED, ".csv"), row.names = FALSE)

