library(tidyverse)
library(purrr)
library(arrow)
library(ggplot2)
library(writexl)

files <- data.frame(path = list.files("01_simulation_1/out/measures", full.names = TRUE)) %>%
  extract(
    col     = path,
    into    = c("lang", "n", "a_y", "a_c", "a_t"),
    regex   = "measures_agg_([^_]+)_(\\d+)_(\\-?[0-9]+(?:\\.[0-9]+)?)_(\\-?[0-9]+(?:\\.[0-9]+)?)_(\\-?[0-9]+(?:\\.[0-9]+)?)\\.arrow$",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  na.omit()

#all_R <- files %>% filter(lang == "R") %>%
#  pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
#    read_feather(path) %>%
#      mutate(
#        lang = lang,
#        n    = n,
#        a_y  = a_y,
#        a_c  = a_c,
#        a_t  = a_t
#      )
#  })
#
#all_Julia <- files %>% filter(lang == "Julia") %>%
#  pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
#    read_feather(path) %>%
#      mutate(
#        lang = "Julia",
#        n    = n,
#        a_y  = a_y,
#        a_c  = a_c,
#        a_t  = a_t
#      )
#  })

all_measures <- files %>% filter(lang == "R") %>%
  pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
    read_feather(path) %>%
      mutate(
        lang = lang,
        n    = n,
        a_y  = a_y,
        a_c  = a_c,
        a_t  = a_t
      )
  }) %>% select(-lang) %>%
  left_join(
    files %>% filter(lang == "Julia") %>%
              pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
                read_feather(path) %>% 
                  mutate(
                    lang = lang,
                    n    = n,
                    a_y  = a_y,
                    a_c  = a_c,
                    a_t  = a_t
                  ) %>% select(-lang)
              }), by = c("followup_time", "n", "a_y", "a_c", "a_t")
    )

# add true MRD

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

load_true <- function(n, a_y, a_c, a_t) {
  # Construct file path
  tv_path <- sprintf("01_simulation_1/out/true_values/true_%d_%g_%g_%g.arrow",
                     n, a_y, a_c, a_t)
  
  # Read and name data
  true_pe <- read_feather(tv_path)
  names(true_pe) <- c("followup_time", "True_MRD")
  
  # Add scenario info
  true_pe <- true_pe %>%
    mutate(n = n, a_y = a_y, a_c = a_c, a_t = a_t)
  
  return(true_pe)
}

true_all <- pmap_dfr(scenarios, load_true)

all_measures <- all_measures %>% left_join(true_all)

#### read all sims
#files <- data.frame(path = list.files("01_simulation_1/out/measures", full.names = TRUE)) %>%
#  extract(
#    col     = path,
#    into    = c("lang", "n", "a_y", "a_c", "a_t"),
#    regex   = "measures_([^_]+)_(\\d+)_(\\-?[0-9]+(?:\\.[0-9]+)?)_(\\-?[0-9]+(?:\\.[0-9]+)?)_(\\-?[0-9]+(?:\\.[0-9]+)?)\\.arrow$",
#    convert = TRUE,
#    remove  = FALSE
#  ) %>%
#  na.omit()
#
#
#all_measures_full <- files %>% filter(lang == "R") %>%
#  pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
#    read_feather(path) %>%
#      mutate(
#        lang = lang,
#        n    = n,
#        a_y  = a_y,
#        a_c  = a_c,
#        a_t  = a_t
#      )
#  }) %>% select(-lang) %>%
#  left_join(
#    files %>% filter(lang == "Julia") %>%
#      pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
#        read_feather(path) %>% 
#          mutate(
#            lang = lang,
#            n    = n,
#            a_y  = a_y,
#            a_c  = a_c,
#            a_t  = a_t
#          ) %>% select(-lang)
#      }), by = c("followup_time", "n", "a_y", "a_c", "a_t")
#  )

#####


 
ns <- unique(all_measures$n)

# red line: sandwich
# green line: empirical bootstrap
# blue line: percentile bootstrap

##  Coverage Plots
for (n_value in ns) {
  # 1. Pivot to long form and filter for the current 'n_value'
  df_cov <- all_measures %>%
    pivot_longer(
      cols      = c(coverage, coverage_emp, coverage_pct),
      names_to  = "method",
      values_to = "cov"
    ) %>% 
    filter(n == n_value)
  
  
  
  # 2. Plot with facet_grid over (a_t) × (a_c + a_y)
  plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = method, shape = method, linetype = method)) +
    geom_hline(yintercept = 0.95, linetype = "dashed", alpha = 0.5) +
    geom_line(alpha = 0.8) +
    geom_point(size = 1, position = position_dodge(width = 0.2)) +
    facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
    scale_y_continuous(limits = c(0.1,1)) +
    labs(
      x     = "Follow‑up time",
      y     = "Coverage probability",
      color = "CI method",
      title = paste("Coverage over follow‑up time for n =", n_value)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      strip.text   = element_text(size = 8),
      axis.text.x  = element_text(angle = 45, hjust = 1),
      panel.grid   = element_line(size = 0.2)
    ) 
  
  ggsave(paste0("01_simulation_1/out/plots/plots_coverage",n_value,".png"), plots_coverage, 
         width = 21, height = 29.7, units = "cm", dpi = 300)
  
}


## Width Plots
for (n_value in ns) {
  # 1. Pivot to long form and filter for the current 'n_value'
  df_cov <- all_measures %>%
    pivot_longer(
      cols      = c(width, width_emp, width_pct),
      names_to  = "method",
      values_to = "cov"
    ) %>% 
    filter(n == n_value)
  
  
  
  # 2. Plot with facet_grid over (a_t) × (a_c + a_y)
  plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = method, shape = method, linetype = method)) +
    geom_line(alpha = 0.8) +
    geom_point(size = 1, position = position_dodge(width = 0.2)) +
    facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
    #scale_y_continuous(limits = c(0.1,1)) +
    labs(
      x     = "Follow‑up time",
      y     = "Width of CI",
      color = "CI method",
      title = paste("Width over follow‑up time for n =", n_value)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      strip.text   = element_text(size = 8),
      axis.text.x  = element_text(angle = 45, hjust = 1),
      panel.grid   = element_line(size = 0.2)
    ) 
  
  ggsave(paste0("01_simulation_1/out/plots/plots_width",n_value,".png"), plots_coverage, 
         width = 21, height = 29.7, units = "cm", dpi = 300)
  
}



## Power Plots
for (n_value in ns) {
  # 1. Pivot to long form and filter for the current 'n_value'
  df_cov <- all_measures %>%
    pivot_longer(
      cols      = c(power, power_emp, power_pct),
      names_to  = "method",
      values_to = "cov"
    ) %>% 
    filter(n == n_value)
  
  
  
  # 2. Plot with facet_grid over (a_t) × (a_c + a_y)
  plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = method, shape = method, linetype = method)) +
    geom_line(alpha = 0.8) +
    geom_point(size = 1, position = position_dodge(width = 0.2)) +
    facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
    scale_y_continuous(limits = c(0,1)) +
    labs(
      x     = "Follow‑up time",
      y     = "Power",
      color = "CI method",
      title = paste("Power over follow‑up time for n =", n_value)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      strip.text   = element_text(size = 8),
      axis.text.x  = element_text(angle = 45, hjust = 1),
      panel.grid   = element_line(size = 0.2)
    ) 
  
  ggsave(paste0("01_simulation_1/out/plots/plots_power",n_value,".png"), plots_coverage, 
         width = 21, height = 29.7, units = "cm", dpi = 300)
  
}



## Bias Eliminated Coverage Plots
for (n_value in ns) {
  # 1. Pivot to long form and filter for the current 'n_value'
  df_cov <- all_measures %>%
    pivot_longer(
      cols      = c(bias_coverage, bias_coverage_emp, bias_coverage_pct),
      names_to  = "method",
      values_to = "cov"
    ) %>% 
    filter(n == n_value)
  
  
  
  # 2. Plot with facet_grid over (a_t) × (a_c + a_y)
  plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = method, shape = method, linetype = method)) +
    geom_hline(yintercept = 0.95, linetype = "dashed", alpha = 0.5) +
    geom_line(alpha = 0.8) +
    geom_point(size = 1, position = position_dodge(width = 0.2)) +
    facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
    scale_y_continuous(limits = c(0.75,1)) +
    labs(
      x     = "Follow‑up time",
      y     = "Bias-Eliminated Coverage probability",
      color = "CI method",
      title = paste("Bias-Eliminated Coverage over follow‑up time for n =", n_value)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      strip.text   = element_text(size = 8),
      axis.text.x  = element_text(angle = 45, hjust = 1),
      panel.grid   = element_line(size = 0.2)
    ) 
  
  ggsave(paste0("01_simulation_1/out/plots/plots_bias_coverage",n_value,".png"), plots_coverage, 
         width = 21, height = 29.7, units = "cm", dpi = 300)
  
}

####### Plots PE ##########

## Empirical-Bias Point Estimate Plots
df_cov <- all_measures %>%
  pivot_longer(
    cols      = c(bias_Julia),
    names_to  = "method",
    values_to = "cov"
  )

# Plot with different lines for each sample size
plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = factor(n), shape = factor(n), linetype = factor(n))) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_line(alpha = 0.8) +
  geom_point(size = 1, position = position_dodge(width = 0.2)) +
  facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
  scale_y_continuous(limits = c(-0.1, 0.1)) +
  labs(
    x     = "Follow‑up time",
    y     = "Empirical-Bias of PE",
    color = "Sample size (n)",
    shape = "Sample size (n)",
    linetype = "Sample size (n)",
    title = "Empirical-Bias of PE over follow‑up times"
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.text   = element_text(size = 8),
    axis.text.x  = element_text(angle = 45, hjust = 1),
    panel.grid   = element_line(size = 0.2)
  )

# Save the combined plot
ggsave("01_simulation_1/out/plots/plots_PE_bias.png", plots_coverage, 
       width = 21, height = 29.7, units = "cm", dpi = 300)



## MSE Point Estimate Plots
df_cov <- all_measures %>%
  pivot_longer(
    cols      = c(MSE_Julia),
    names_to  = "method",
    values_to = "cov"
  )

# Plot with different lines for each sample size
plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = factor(n), shape = factor(n), linetype = factor(n))) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_line(alpha = 0.8) +
  geom_point(size = 1, position = position_dodge(width = 0.2)) +
  facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
  scale_y_continuous(limits = c(0, 0.01)) +
  labs(
    x     = "Follow‑up time",
    y     = "Mean Squared Error of PE",
    color = "Sample size (n)",
    shape = "Sample size (n)",
    linetype = "Sample size (n)",
    title = "Mean Squared Error of PE over follow‑up time"
    
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.text   = element_text(size = 8),
    axis.text.x  = element_text(angle = 45, hjust = 1),
    panel.grid   = element_line(size = 0.2)
  )

# Save the combined plot
ggsave("01_simulation_1/out/plots/plots_PE_MSE.png", plots_coverage, 
       width = 21, height = 29.7, units = "cm", dpi = 300)



## Point Estimates R/Julia
for (n_value in ns) {
  # 1. Pivot to long form and filter for the current 'n_value'
  df_cov <- all_measures %>%
    pivot_longer(
      cols      = c(survival_diff.x, survival_diff.y),
      names_to  = "method",
      values_to = "cov"
    ) %>% 
    filter(n == n_value)
  
  
  
  # 2. Plot with facet_grid over (a_t) × (a_c + a_y)
  plots_coverage <- ggplot(df_cov, aes(x = followup_time, y = cov, color = method, shape = method, linetype = method)) +
    #geom_line(yintercept = 0.95, linetype = "dashed", alpha = 0.5) +
    geom_line(alpha = 0.8) +
    geom_point(size = 1, position = position_dodge(width = 0.2)) +
    facet_grid(a_y + a_c ~ a_t, labeller = label_both) +
    #scale_y_continuous(limits = c(0.75,1)) +
    labs(
      x     = "Follow‑up time",
      y     = "Point Estimates",
      color = "CI method",
      title = paste("Point Estimates over follow‑up time for n =", n_value)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      strip.text   = element_text(size = 8),
      axis.text.x  = element_text(angle = 45, hjust = 1),
      panel.grid   = element_line(size = 0.2)
    ) 
  
  ggsave(paste0("01_simulation_1/out/plots/plots_PE",n_value,".png"), plots_coverage, 
         width = 21, height = 29.7, units = "cm", dpi = 300)
  
}








######## table

summaries <- all_measures %>% group_by(n, a_c, a_t, a_y) %>%
  summarise(coverage = mean(coverage),
            coverage_emp = mean(coverage_emp),
            coverage_pct = mean(coverage_pct),
            width = mean(width),
            width_emp = mean(width_emp),
            width_pct = mean(width_pct),
            type_I = mean(type_I),
            type_I_emp = mean(type_I_emp),
            type_I_pct = mean(type_I_pct),
            power = mean(power),
            power_emp = mean(power_emp),
            power_pct = mean(power_pct),
            
            )

summaries_MCE_fup <- all_measures %>% group_by(followup_time, n, a_c, a_t, a_y) %>%
  summarise(MCE_coverage = mean(MCE_coverage),
            MCE_coverage_emp = mean(MCE_coverage_emp),
            MCE_coverage_pct = mean(MCE_coverage_pct),
            MCE_bias_coverage = mean(MCE_bias_coverage),
            MCE_bias_coverage_emp = mean(MCE_bias_coverage_emp),
            MCE_bias_coverage_pct = mean(MCE_bias_coverage_pct),
            MCE_bias = mean(MCE_bias_Julia),
            MCE_MSE = mean(MCE_MSE_Julia),
            MCE = mean(MCE_Julia)
            #MCE_width_pct = mean(MCE_width_pct),
            #MCE_power = mean(MCE_power),
            #MCE_power_emp = mean(MCE_power_emp),
            #MCE_power_pct = mean(MCE_power_pct),
            
  )

summaries_MCE <- all_measures %>% group_by(n, a_c, a_t, a_y) %>%
  summarise(MCE_coverage = mean(MCE_coverage),
            MCE_coverage_emp = mean(MCE_coverage_emp),
            MCE_coverage_pct = mean(MCE_coverage_pct),
            MCE_bias_coverage = mean(MCE_bias_coverage),
            MCE_bias_coverage_emp = mean(MCE_bias_coverage_emp),
            MCE_bias_coverage_pct = mean(MCE_bias_coverage_pct),
            MCE_bias = mean(MCE_bias_Julia),
            MCE_MSE = mean(MCE_MSE_Julia),
            MCE = mean(MCE_Julia)
            #MCE_width_pct = mean(MCE_width_pct),
            #MCE_power = mean(MCE_power),
            #MCE_power_emp = mean(MCE_power_emp),
            #MCE_power_pct = mean(MCE_power_pct),
            
  ) %>%
  round(5)

library(kableExtra)
summaries_MCE %>%
  kbl(format = "latex", booktabs = TRUE, longtable = TRUE, caption = "Summary of MCE Measures") %>%
  kable_styling(latex_options = c("repeat_header"))



######
cov_diff <- all_measures %>%
  select(coverage, coverage_emp, coverage_pct) %>%
  mutate(coverage = abs(coverage - 0.95),
         coverage_emp = abs(coverage_emp - 0.95),
         coverage_pct = abs(coverage_pct - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:3])

# Get percentage for each method
cov3 <- prop.table(table(cov_diff$closest_method)) 

###### Pairwise comparison


cov_diff <- all_measures %>%
  select(coverage, coverage_emp) %>%
  mutate(coverage = abs(coverage - 0.95),
         coverage_emp = abs(coverage_emp - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_emp_sw <- prop.table(table(cov_diff$closest_method)) 



cov_diff <- all_measures %>%
  select(coverage, coverage_pct) %>%
  mutate(coverage = abs(coverage - 0.95),
         coverage_pct = abs(coverage_pct - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_sw_pct <- prop.table(table(cov_diff$closest_method)) 



cov_diff <- all_measures %>%
  select(coverage_pct, coverage_emp) %>%
  mutate(coverage_pct = abs(coverage_pct - 0.95),
         coverage_emp = abs(coverage_emp - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_emp_pct <- prop.table(table(cov_diff$closest_method))

cov3
cov_emp_pct
cov_sw_pct
cov_emp_sw



#all_measures_full <- files %>% filter(lang == "R") %>%
#  pmap_dfr(function(path, lang, n, a_y, a_c, a_t) {
#    read_feather(path) %>%
#      mutate(
#        lang = lang,
#        n    = n,
#        a_y  = a_y,
#        a_c  = a_c,
#        a_t  = a_t
#      )
#  })









#### bias elim cov differences
######
cov_diff <- all_measures %>%
  select(bias_coverage, bias_coverage_emp, bias_coverage_pct) %>%
  mutate(bias_coverage = abs(bias_coverage - 0.95),
         bias_coverage_emp = abs(bias_coverage_emp - 0.95),
         bias_coverage_pct = abs(bias_coverage_pct - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:3])

# Get percentage for each method
cov3 <- prop.table(table(cov_diff$closest_method)) 

###### Pairwise comparison


cov_diff <- all_measures %>%
  select(bias_coverage, bias_coverage_emp) %>%
  mutate(bias_coverage = abs(bias_coverage - 0.95),
         bias_coverage_emp = abs(bias_coverage_emp - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_emp_sw <- prop.table(table(cov_diff$closest_method)) 



cov_diff <- all_measures %>%
  select(bias_coverage, bias_coverage_pct) %>%
  mutate(bias_coverage = abs(bias_coverage - 0.95),
         bias_coverage_pct = abs(bias_coverage_pct - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_sw_pct <- prop.table(table(cov_diff$closest_method)) 



cov_diff <- all_measures %>%
  select(bias_coverage_pct, bias_coverage_emp) %>%
  mutate(bias_coverage_pct = abs(bias_coverage_pct - 0.95),
         bias_coverage_emp = abs(bias_coverage_emp - 0.95))


# Find the method (column) with minimum distance for each row
cov_diff$closest_method <- apply(cov_diff, 1, function(row) {
  names(row)[which.min(row)]
})

# Convert to factor for consistent levels
cov_diff$closest_method <- factor(cov_diff$closest_method, levels = colnames(cov_diff)[1:2])

# Get percentage for each method
cov_emp_pct <- prop.table(table(cov_diff$closest_method))

cov3
cov_emp_pct
cov_sw_pct
cov_emp_sw

#save all measures as excel

write_xlsx(all_measures, path = "01_simulation_1/out/all_measures.xlsx")









