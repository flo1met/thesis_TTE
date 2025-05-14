library(TrialEmulation)
data <- read.csv("data/trial_example.csv")
data$catvarA <- as.factor(data$catvarA)
data$catvarB <- as.factor(data$catvarB)

bench::mark(initiators(
  data = data,
  id = "id",
  period = "period",
  eligible = "eligible",
  treatment = "treatment",
  estimand_type = "ITT",
  outcome = "outcome",
  model_var = "assigned_treatment",
  outcome_cov = c("catvarA", "catvarB", "nvarA", "nvarB", "nvarC"),
  use_censor_weights = FALSE
))


library(bench)
library(TrialEmulation)

data <- read.csv("data/trial_example.csv")
data$catvarA <- as.factor(data$catvarA)
data$catvarB <- as.factor(data$catvarB)

# Number of iterations
num_iters <- 1

# Run benchmarks multiple times and store results
results_list <- vector("list", num_iters)

bench::mark(
  initiators(
    data = data,
    id = "id",
    period = "period",
    eligible = "eligible",
    treatment = "treatment",
    estimand_type = "ITT",
    outcome = "outcome",
    model_var = "assigned_treatment",
    outcome_cov = c("catvarA", "catvarB", "nvarA", "nvarB", "nvarC"),
    use_censor_weights = FALSE
  )
)

