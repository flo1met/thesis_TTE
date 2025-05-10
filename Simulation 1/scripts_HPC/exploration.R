library(tidyverse)
library(purrr)
library(arrow)

# test if all true scenarios have a population effect

process_fun <- function(n, a_y, a_c, a_t) {
  # load true values
  tv_path <- sprintf("Simulation 1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # Optionally add scenario identifiers
  true_pe$n <- n
  true_pe$a_y <- a_y
  true_pe$a_c <- a_c
  true_pe$a_t <- a_t
  
  return(true_pe)
}

out <- pmap(scenarios, process_fun) |> bind_rows()

zero <- sum(abs(out$True_MRD) < 1e-5)

out[zero,]




#### test cox ph
library(survival)
library(dplyr)
library(feather)

# Load your data
data <- read_feather("Simulation 1/datasets/data_200_1.arrow")

# Extract baseline covariates
baseline_covs <- data %>%
  filter(t == 0) %>%
  select(ID, X2, X4, C)

# Join these back to the full dataset so everyone gets their baseline values
data <- data %>%
  select(-X2, -X4, -C) %>%  # remove possibly time-varying covariates
  left_join(baseline_covs, by = "ID")

# Fit Cox PH model
cox.fit <- coxph(Surv(t, Y) ~ A + X2 + X4 + C, data)

# Get baseline survival function
base_surv <- survfit(cox.fit)

# Create two representative datasets for A = 1 and A = 0
# Use average covariate values at baseline(ITT)
newdata_1 <- data %>% 
  mutate(A = 1)

newdata_0 <- data %>% 
  mutate(A = 0)



# Predict survival curves for both groups
surv_1 <- survfit(cox.fit, newdata = newdata_1)
surv_0 <- survfit(cox.fit, newdata = newdata_0)

# Extract survival risks over time
times <- surv_1$time
risk_1 <- 1 - surv_1$surv
risk_0 <- 1 - surv_0$surv

# Calculate risk difference over time
risk_diff <- risk_1 - risk_0

# Combine into a data frame
risk_df <- data.frame(
  time = times,
  risk_1 = risk_1,
  risk_0 = risk_0,
  risk_diff = risk_diff
)

# Predict survival curves with standard errors
surv_1 <- survfit(cox.fit, newdata = newdata_1)
surv_0 <- survfit(cox.fit, newdata = newdata_0)

# Risk = 1 - survival
risk_1 <- 1 - surv_1$surv
risk_0 <- 1 - surv_0$surv
risk_diff <- risk_1 - risk_0

# Approximate SE of difference
risk_se <- sqrt(surv_1$std.err^2 + surv_0$std.err^2)

# 95% Confidence Intervals
lower <- risk_diff - 1.96 * risk_se
upper <- risk_diff + 1.96 * risk_se

risk_df <- data.frame(
  time = surv_1$time,
  risk_1 = risk_1,
  risk_0 = risk_0,
  risk_diff = risk_diff,
  lower = lower,
  upper = upper
)









### try 2
library(survival)
library(dplyr)
library(purrr)
library(tidyr)

# Load data
data <- read_feather("Simulation 1/datasets/data_200_1.arrow")

# Fit Cox model
cox.fit <- coxph(Surv(t, Y) ~ A + X2 + X4 + C, data)

# Get baseline covariates for each id
# If multiple rows per id, keep only baseline row:
baseline_data <- data %>% 
  group_by(id) %>% 
  slice_min(t) %>%  # Keep baseline row per person
  ungroup()

# Create two datasets: same covariates, different treatment
baseline_data_1 <- baseline_data %>% mutate(A = 1)
baseline_data_0 <- baseline_data %>% mutate(A = 0)

# Predict survival for each person under A=1 and A=0
surv_1 <- survfit(cox.fit, newdata = baseline_data_1)
surv_0 <- survfit(cox.fit, newdata = baseline_data_0)

# Extract survival matrix: rows = time, cols = individuals
surv_mat_1 <- as.data.frame(t(surv_1$surv))
surv_mat_0 <- as.data.frame(t(surv_0$surv))

# Average across individuals at each time
avg_surv_1 <- rowMeans(surv_mat_1)
avg_surv_0 <- rowMeans(surv_mat_0)

# Risk = 1 - survival
risk_1 <- 1 - avg_surv_1
risk_0 <- 1 - avg_surv_0
risk_diff <- risk_1 - risk_0

# Confidence intervals (optional): bootstrap or delta method needed for precision
# Put in data frame
risk_df <- data.frame(
  time = surv_1$time,
  risk_1 = risk_1,
  risk_0 = risk_0,
  risk_diff = risk_diff
)

# Optional: plot
library(ggplot2)
ggplot(risk_df, aes(x = time, y = risk_diff)) +
  geom_line(color = "darkred") +
  labs(y = "Risk Difference (A=1 - A=0)", title = "Difference in Survival Risk Over Time") +
  theme_minimal()


