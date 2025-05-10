process_fun <- function(n, a_y, a_c, a_t) {
  # load true values
  tv_path <- sprintf("Simulation 1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # load sim data
  sim_paths <- list.files("Simulation 1/out/R", full.names = TRUE) %>%
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
           true_low   = mean_survdiff - 1.96 * SD,
           true_high  = mean_survdiff + 1.96 * SD,
           coverage = True_MRD > CIlow & True_MRD < CIhigh,
           bias_coverage = mean_survdiff > CIlow & mean_survdiff < CIhigh,
           width = (CIhigh - CIlow),
           width_rel = (CIhigh - CIlow)/True_MRD,
           IoU = {
             overlap = pmax(0, pmin(true_high, CIhigh) -
                              pmax(true_low, CIlow))
             union   = pmax(true_high, CIhigh) -
               pmin(true_low, CIlow)
             overlap / union
           },
           type_I = (0 > true_low & 0 < true_high) & (0 < CIlow | 0 > CIhigh),
           power = (0 < true_low | 0 > true_high) & (0 < CIlow | 0 > CIhigh),
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
              true_low = mean(true_low),
              true_high = mean(true_high),
              coverage = mean(coverage),
              bias_coverage = mean(bias_coverage),
              MCE_coverage = sqrt((coverage * (1-coverage))/nrow(.)),
              MCE_bias_coverage = sqrt((bias_coverage * (1-bias_coverage))/nrow(.)),
              width = mean(width),
              width_rel = mean(width_rel),
              #type_I = mean(type_I),
              power = mean(power),
              IoU = mean(IoU),
              ## measures PE
              bias_R = mean(bias_R),
              MCE_bias_R = sqrt(sum(MCE_bias_R)/(nrow(.)*(nrow(.)-1))),
              MSE_R = mean(MSE_R),
              MCE_MSE_R = sqrt(sum((((survival_diff - True_MRD)^2)-MSE_R)^2)/(nrow(.)*(nrow(.)-1)))
    )
  
  # save results
  write_feather(
    measures,
    sprintf("Simulation 1/out/measures/measures_R_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
  
  write_feather(
    measures_agg,
    sprintf("Simulation 1/out/measures/measures_agg_R_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
}

process_fun <- function(n, a_y, a_c, a_t) {
  # 1) Find the “true” file
  tv_path <- sprintf("Simulation 1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # 2) Gather all sim‐file paths for this scenario
  sim_paths <- list.files("Simulation 1/out/Julia", full.names = TRUE) %>%
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
      true_low   = mean_survdiff - 1.96 * SD,
      true_high  = mean_survdiff + 1.96 * SD,
      # measures emp
      coverage_emp   = True_MRD > CIlow_emp & True_MRD < CIhigh_emp,
      bias_coverage_emp = mean_survdiff > CIlow_emp & mean_survdiff < CIhigh_emp,
      width_emp = (CIhigh_emp - CIlow_emp),
      width_rel_emp = (CIhigh_emp - CIlow_emp)/True_MRD,
      IoU_emp = {
        overlap = pmax(0, pmin(true_high, CIhigh_emp) -
                         pmax(true_low, CIlow_emp))
        union   = pmax(true_high, CIhigh_emp) -
          pmin(true_low, CIlow_emp)
        overlap / union
      },
      type_I_emp = (0 > true_low | 0 < true_high) & (0 < CIlow_emp | 0 > CIhigh_emp),
      power_emp = (0 > true_low | 0 < true_high) & (0 > CIlow_emp | 0 < CIhigh_emp),
      # measures pct
      coverage_pct   = True_MRD > CIlow_pct & True_MRD < CIhigh_pct,
      bias_coverage_pct = mean_survdiff > CIlow_pct & mean_survdiff < CIhigh_pct,
      width_pct = (CIhigh_pct - CIlow_pct),
      width_rel_pct = (CIhigh_pct - CIlow_pct)/True_MRD,
      IoU_pct = {
        overlap = pmax(0, pmin(true_high, CIhigh_pct) -
                         pmax(true_low, CIlow_pct))
        union   = pmax(true_high, CIhigh_pct) -
          pmin(true_low, CIlow_pct)
        overlap / union
      },
      type_I_pct = (0 > true_low & 0 < true_high) & (0 < CIlow_pct | 0 > CIhigh_pct),
      power_pct = (0 < true_low | 0 > true_high) & (0 < CIlow_pct | 0 > CIhigh_pct),
      ## measures PE
      bias_Julia = survival_diff - True_MRD,
      MCE_bias_Julia = (survival_diff - mean_survdiff)^2,
      MSE_Julia = (survival_diff - True_MRD)^2
    )
  
  # calculate accumulated measures
  measures_agg <- measures %>%
    group_by(followup_time) %>%
    summarise(survival_diff = mean(survival_diff),
              true_low = mean(true_low),
              true_high = mean(true_high),
              MCE_Julia = mean(MCE_Julia),
              # agg emp
              CIlow_emp = mean(CIlow_emp),
              CIhigh_emp = mean(CIhigh_emp),
              coverage_emp = mean(coverage_emp),
              bias_coverage_emp = mean(bias_coverage_emp),
              MCE_coverage_emp = sqrt((coverage_emp * (1-coverage_emp))/nrow(.)),
              MCE_bias_coverage_emp = sqrt((bias_coverage_emp * (1-bias_coverage_emp))/nrow(.)),
              width_emp = mean(width_emp),
              width_rel_emp = mean(width_rel_emp),
              type_I_emp = mean(type_I_emp),
              power_emp = mean(power_emp),
              IoU_emp = mean(IoU_emp),
              # agg pct
              CIlow_pct = mean(CIlow_pct),
              CIhigh_pct = mean(CIhigh_pct),
              coverage_pct = mean(coverage_pct),
              bias_coverage_pct = mean(bias_coverage_pct),
              MCE_coverage_pct = sqrt((coverage_pct * (1-coverage_pct))/nrow(.)),
              MCE_bias_coverage_pct = sqrt((bias_coverage_pct * (1-bias_coverage_pct))/nrow(.)),
              width_pct = mean(width_pct),
              width_rel_pct = mean(width_rel_pct),
              type_I_pct = mean(type_I_pct),
              power_pct = mean(power_pct),
              IoU_pct = mean(IoU_pct),
              ## measures PE
              bias_Julia = mean(bias_Julia),
              MCE_bias_Julia = sqrt(sum(MCE_bias_Julia)/(nrow(.)*(nrow(.)-1))),
              MSE_Julia = mean(MSE_Julia),
              MCE_MSE_Julia = sqrt(sum((((survival_diff - True_MRD)^2)-MSE_Julia)^2)/(nrow(.)*(nrow(.)-1)))
    )
  
  write_feather(
    measures,
    sprintf("Simulation 1/out/measures/measures_Julia_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
  
  write_feather(
    measures_agg,
    sprintf("Simulation 1/out/measures/measures_agg_Julia_%d_%g_%g_%g.arrow",
            n, a_y, a_c, a_t)
  )
}