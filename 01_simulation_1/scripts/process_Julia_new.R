library(arrow)
library(tidyverse)
library(purrr)

nsample = c(200, 1000, 5000) # sample size
a_y = c(-4.7, -3.8, -3.0) # outcome event rate
a_c = c(0.1, 0.5, 0.9) # confounding strength
a_t = c(-1, 0, 1) # treatment prevalence

scenarios <- expand.grid(
  n   = nsample,
  a_y = a_y,
  a_c = a_c,
  a_t = a_t
)

process_fun <- function(n, a_y, a_c, a_t) {
  # 1) Find the “true” file
  tv_path <- sprintf("01_simulation_1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # 2) Gather all sim‐file paths for this scenario
  sim_paths <- list.files("01_simulation_1/out/Julia", full.names = TRUE) %>%
    keep(~ str_detect(.x,
                      sprintf("Julia_MRD_data_%d_%g_%g_%g_", n, a_y, a_c, a_t)))
  
  # 3) Read & bind all sims into one tibble
  files_all <- map_dfr(sim_paths, read_feather)
  names <- names(files_all)
  names[1] <- "followup_time"
  names[4] <- "survival_diff"
  names(files_all) <- names
  
  # 4) Join the truth, compute SD/CI/coverage measures
  measures <- files_all %>%
    left_join(true_pe, by = "followup_time", suffix = c("", "_true")) %>%
    group_by(followup_time) %>%
    mutate(
      survival_diff = round(survival_diff, 5),
      SD         = sd(survival_diff),
      MCE_Julia = SD / sqrt(nrow(.)),
      mean_survdiff = mean(survival_diff),
      # measures emp
      coverage_emp   = True_MRD > CIlow_emp & True_MRD < CIhigh_emp,
      bias_coverage_emp = mean_survdiff > CIlow_emp & mean_survdiff < CIhigh_emp,
      width_emp = (CIhigh_emp - CIlow_emp),
      power_emp = (0 < CIlow_emp | 0 > CIhigh_emp),
      # measures pct
      coverage_pct   = True_MRD > CIlow_pct & True_MRD < CIhigh_pct,
      bias_coverage_pct = mean_survdiff > CIlow_pct & mean_survdiff < CIhigh_pct,
      width_pct = (CIhigh_pct - CIlow_pct),
      power_pct = (0 < CIlow_pct | 0 > CIhigh_pct),
      ## measures PE
      bias_Julia = survival_diff - True_MRD,
      MCE_bias_Julia = (survival_diff - mean_survdiff)^2,
      MSE_Julia = (survival_diff - True_MRD)^2
      )
  
  # calculate accumulated measures
  measures_agg <- measures %>%
    group_by(followup_time) %>%
    summarise(survival_diff = mean(survival_diff),
              MCE_Julia = mean(MCE_Julia),
              # agg emp
              CIlow_emp = mean(CIlow_emp),
              CIhigh_emp = mean(CIhigh_emp),
              coverage_emp = mean(coverage_emp),
              bias_coverage_emp = mean(bias_coverage_emp),
              MCE_coverage_emp = sqrt((coverage_emp * (1-coverage_emp))/nrow(.)),
              MCE_bias_coverage_emp = sqrt((bias_coverage_emp * (1-bias_coverage_emp))/nrow(.)),
              width_emp = mean(width_emp),
              power_emp = mean(power_emp),
              # agg pct
              CIlow_pct = mean(CIlow_pct),
              CIhigh_pct = mean(CIhigh_pct),
              coverage_pct = mean(coverage_pct),
              bias_coverage_pct = mean(bias_coverage_pct),
              MCE_coverage_pct = sqrt((coverage_pct * (1-coverage_pct))/nrow(.)),
              MCE_bias_coverage_pct = sqrt((bias_coverage_pct * (1-bias_coverage_pct))/nrow(.)),
              width_pct = mean(width_pct),
              power_pct = mean(power_pct),
              ## measures PE
              bias_Julia = mean(bias_Julia),
              MCE_bias_Julia = sqrt(sum(MCE_bias_Julia)/(nrow(.)*(nrow(.)-1))),
              MSE_Julia = mean(MSE_Julia),
              MCE_MSE_Julia = sqrt(sum((((survival_diff - True_MRD)^2)-MSE_Julia)^2)/(nrow(.)*(nrow(.)-1)))
              )
  
  write_feather(
    measures,
    sprintf("01_simulation_1/out/measures/measures_Julia_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
  
  write_feather(
    measures_agg,
    sprintf("01_simulation_1/out/measures/measures_agg_Julia_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
}

library(furrr)
# this does not stop automatically, problem with arrow? needs to be aborted by hand
t1 <- Sys.time()
plan(multisession, workers = 8)

future_pwalk(
  .l = scenarios,
  .f = process_fun
)

t2 <- Sys.time()
t2 - t1