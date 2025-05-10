#library(arrow)
#library(tidyverse)
#library(purrr)
#
#files <- data.frame(path = list.files("Simulation 1/out/R", full.names = TRUE)) %>%
#  extract(
#    col     = path,
#    into    = c("n", "nsim"),
#    regex   = "R_MRD_data_(\\d+)_(\\d+)\\.arrow",
#    convert = TRUE,
#    remove  = FALSE
#  )
#
#nsample = c(200, 1000, 5000) # sample size
#a_y = c(-4.7, -3.8, -3.0) # outcome event rate
#a_c = c(0.1, 0.5, 0.9) # confounding strength
#a_t = c(-1, 0, 1) # treatment prevalence
#
#scenarios <- expand.grid(nsample, a_y, a_c, a_t)
#
#true_pe <- read.csv("Simulation 1/out/True Values/TRUE_PE.csv")
#names(true_pe) <- c("X", "followup_time", "True_MRD")
#
#files_all <- files %>%
#  filter(n == 1000) %>%
#  group_by(n, nsim) %>%
#  group_modify(~ read_feather(.x$path)) %>%
#  ungroup() %>%
#  group_by(followup_time) %>%
#  left_join(true_pe %>% select(-X)) %>%
#  mutate(SD = sd(survival_diff),
#         true_CIlow = mean(survival_diff) - 1.96*SD,
#         true_CIhigh = mean(survival_diff) + 1.96*SD)
#names <- names(files_all)
#names[5] <- "CIlow"
#names[6]  <- "CIhigh"
#names(files_all) <- names
#
##!!!!
## TODO: for Julia, add bias for pct and emp
##!!!!
#
#### Coverage, bias, variance per fup
#measures <- files_all %>%
#    group_by(followup_time) %>%
#    summarise(coverage = mean(True_MRD > CIlow & True_MRD < CIhigh, na.rm = TRUE),
#              bias_low = mean(CIlow - true_CIlow),
#              bias_high = mean(CIhigh - true_CIhigh),
#              var_low = var(CIlow),
#              var_high = var(CIhigh))
#
### Overall coverage, bias, variance
#mean(measures$coverage)
#mean(measures$bias_low)
#mean(measures$bias_high)
#mean(measures$var_low)
#mean(measures$var_high)

library(arrow)
library(tidyverse)
library(purrr)

nsample = c(200, 1000, 5000) # sample size
a_y = c(-4.7, -3.8, -3.0) # outcome event rate
a_c = c(0.1, 0.5, 0.9) # confounding strength
a_t = c(-1, 0, 1) # treatment prevalence

scenarios <- expand.grid(nsample, a_y, a_c, a_t)

process_fun <- function(scenarios) {
  files <- data.frame(path = list.files("out/R", full.names = TRUE)) %>%
    extract(
      col     = path,
      into    = c("n", "a_y", "a_c", "a_t", "nsim"),
      regex   = "R_MRD_data_(\\d+)_(\\d+)_(\\d+)_(\\d+)_(\\d+)\\.arrow",
      convert = TRUE,
      remove  = FALSE
    )
  
  true_files <- data.frame(path = list.files("out/true_values", full.names = TRUE)) %>%
    extract(
      col     = path,
      into    = c("n", "a_y", "a_c", "a_t"),
      regex   = "true_(\\d+)_(\\d+)_(\\d+)_(\\d+)\\.arrow",
      convert = TRUE,
      remove  = FALSE
    )
  
  true_pe <- true_files %>%
    filter(n == !!n, a_y == !!a_y, a_c == !!a_c, a_t == !!a_t) %>%
    group_by(n, a_y, a_c, a_t) %>%
    group_modify(~ read_feather(.x$path)) %>%
    ungroup()
    
  files_all <- files %>%
    filter(n == !!n, a_y == !!a_y, a_c == !!a_c, a_t == !!a_t) %>%
    group_by(n, a_y, a_c, a_t, nsim) %>%
    group_modify(~ read_feather(.x$path)) %>%
    ungroup() %>%
    group_by(followup_time) %>%
    left_join(true_pe %>% select(-X)) %>%
    mutate(SD = sd(survival_diff),
           true_CIlow = mean(survival_diff) - 1.96*SD,
           true_CIhigh = mean(survival_diff) + 1.96*SD)
  names <- names(files_all)
  names[5] <- "CIlow"
  names[6]  <- "CIhigh"
  names(files_all) <- names
  
  ### Coverage, bias, variance per fup
  measures <- files_all %>%
    group_by(followup_time) %>%
    summarise(coverage = mean(True_MRD > CIlow & True_MRD < CIhigh, na.rm = TRUE),
              bias_low = mean(CIlow - true_CIlow),
              bias_high = mean(CIhigh - true_CIhigh),
              var_low = var(CIlow),
              var_high = var(CIhigh))
  
  write_feather(measures, sink = paste0("out/measures/measures_R_", n, "_", a_y, "_", "a_c", "_", a_t, ".arrow"))
  
}

# same named grid as above…
scenarios <- expand.grid(
  n   = nsample,
  a_y = a_y,
  a_c = a_c,
  a_t = a_t
)

# and same signature for process_fun(n, a_y, a_c, a_t)…

# now run it once for each row:
pwalk(
  .l   = scenarios,
  .f   = process_fun
)


