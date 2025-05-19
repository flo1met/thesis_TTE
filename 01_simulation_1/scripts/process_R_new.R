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
  # load true values
  tv_path <- sprintf("01_simulation_1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # load sim data
  sim_paths <- list.files("01_simulation_1/out/R", full.names = TRUE) %>%
    keep(~ str_detect(.x,
                      sprintf("R_MRD_data_%d_%g_%g_%g_", n, a_y, a_c, a_t)))
  
  files_all <- map_dfr(sim_paths, read_feather)
  names <- names(files_all)
  names[3] <- "CIlow"
  names[4]  <- "CIhigh"
  names(files_all) <- names
  
  # calculate measures
  measures <- files_all %>%
    left_join(true_pe, by = "followup_time", suffix = c("", "_true")) %>%
    group_by(followup_time) %>%
    mutate(survival_diff = round(survival_diff, 5),
           SD = sd(survival_diff),
           MCE_R = SD / sqrt(nrow(.)),
           mean_survdiff = mean(survival_diff),
           coverage = True_MRD > CIlow & True_MRD < CIhigh,
           bias_coverage = mean_survdiff > CIlow & mean_survdiff < CIhigh,
           width = (CIhigh - CIlow),
           power = (0 < CIlow | 0 > CIhigh),
           ## measures PE
           bias_R = survival_diff - True_MRD,
           MCE_bias_R = (survival_diff - mean_survdiff)^2,
           MSE_R = (survival_diff - True_MRD)^2
    )
  
  measures_agg <- measures %>%
    group_by(followup_time) %>%
    summarise(survival_diff = mean(survival_diff),
              MCE_R = mean(MCE_R),
              CIlow = mean(CIlow),
              CIhigh = mean(CIhigh),
              coverage = mean(coverage),
              bias_coverage = mean(bias_coverage),
              MCE_coverage = sqrt((coverage * (1-coverage))/nrow(.)),
              MCE_bias_coverage = sqrt((bias_coverage * (1-bias_coverage))/nrow(.)),
              width = mean(width),
              power = mean(power),
              ## measures PE
              bias_R = mean(bias_R),
              MCE_bias_R = sqrt(sum(MCE_bias_R)/(nrow(.)*(nrow(.)-1))),
              MSE_R = mean(MSE_R),
              MCE_MSE_R = sqrt(sum((((survival_diff - True_MRD)^2)-MSE_R)^2)/(nrow(.)*(nrow(.)-1)))
              )
  
  # save results
  write_feather(
    measures,
    sprintf("01_simulation_1/out/measures/measures_R_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
    )
    
  write_feather(
    measures_agg,
    sprintf("01_simulation_1/out/measures/measures_agg_R_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
    )
}


library(furrr)
# this does not stop automatically, problem with arrow? needs to be aborted by hand sometimes
t1 <- Sys.time()
plan(multisession, workers = 8)

future_pwalk(
  .l = scenarios,
  .f = process_fun
)

t2 <- Sys.time()
t2 - t1



