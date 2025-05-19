library(tidyverse)
library(ggplot2)
library(patchwork)

# Add sample sizes for x-label
n_names <- c("200", "1e3", "5e3", "2e4", "5e4", "1e5")

# read data
julia_CI <- read.csv("02_appendix_F/out/performance_summary_julia.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_gb = mean(alloc_kb)/(1024^2)) %>%
  mutate(lang = "Julia",
         n = n_names)

r_CI <- read.csv("02_appendix_F/out/performance_summary_r.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds, na.rm = TRUE), # rm missings introduced by non-inverse matrix error
            alloc_gb = mean(alloc_kb, na.rm = TRUE)/(1024^2)) %>%
  mutate(lang = "R",
         n = n_names)



julia_noCI <- read.csv("02_appendix_F/out/performance_summary_noCI_julia.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_gb = mean(alloc_kb)/(1024^2)) %>%
  mutate(lang = "Julia",
         n = n_names)

r_noCI <- read.csv("02_appendix_F/out/performance_summary_noCI_r.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_gb = mean(alloc_kb)/(1024^2)) %>%
  mutate(lang = "R",
         n = n_names)



noCI <- bind_rows(r_noCI, julia_noCI)

# Plot and save
p_time_noCI <- ggplot(noCI, aes(x = factor(n, levels = n_names), y = time_seconds, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Time (seconds)",
    title = "Execution Time: R vs Julia"
  ) +
  theme_bw() +
  theme(legend.position = "none")

p_memory_noCI <- ggplot(noCI, aes(x = factor(n, levels = n_names), y = alloc_gb, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Allocated Memory (gb)",
    title = "Allocated Memory: R vs Julia"
  ) +
  theme_bw() +
  theme(legend.position = "none")

combined_noCI <- p_time_noCI + p_memory_noCI

ggsave("02_appendix_F/out/plots/noCI_performance.png", combined_noCI, width = 10, height = 4, dpi = 300)

CI <- bind_rows(r_CI, julia_CI)

p_time_CI <- ggplot(CI, aes(x = factor(n, levels = n_names), y = time_seconds, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Time (seconds)",
    title = "Execution Time: R vs Julia"
  ) +
  theme_bw() +
  theme(legend.position = "none")

p_memory_CI <- ggplot(CI, aes(x = factor(n, levels = n_names), y = alloc_gb, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Allocated Memory (gb)",
    title = "Allocated Memory: R vs Julia"
  ) +
  theme_bw() +
  theme(legend.position = "none")

combined_CI <- p_time_CI + p_memory_CI

ggsave("02_appendix_F/out/plots/CI_performance.png", combined_CI, width = 10, height = 4, dpi = 300)

# red line Julia
# blue line R



