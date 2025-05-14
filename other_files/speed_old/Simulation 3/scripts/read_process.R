library(tidyverse)

header_values <- c("seed", "sample_size", "language", "runtime_min", "peak_memory_MB")

output <- read.csv("Simulation 3/out/logs/timing_summary.csv") %>%
  filter(!if_any(everything(), ~ .x %in% header_values)) %>%
  mutate(across(
    .cols = -language,  # exclude 'language' column
    .fns = ~ as.numeric(.)
  ))

# get overview over missing measurements
seeds <- 1:100
sample_sizes <- c(500, 5000, 50000, 500000, 5000000)
languages <- c("R", "Julia")

# create grid of expected outputs
expected <- expand_grid(seed = seeds, sample_size = sample_sizes, language = languages)

# find missing combinations
missing <- expected %>%
  anti_join(output, by = c("seed", "sample_size", "language"))


(miss <- missing %>%
  group_by(sample_size, language) %>%
  summarise(n = n()))

(there <- output %>%
  group_by(sample_size, language) %>%
  summarise(n = n()))

# plots runtime
time_data <- output %>%
  group_by(sample_size, language) %>%
  summarise(mean_runtime = mean(runtime_min, na.rm = TRUE), .groups = "drop")

ggplot(time_data, aes(x = factor(sample_size), y = mean_runtime, color = language, group = language)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    x = "Sample Size",
    y = "Mean Runtime (min)",
    color = "Language",
    title = "Runtime Comparison: R vs Julia"
  ) +
  theme_bw()

ggplot(output, aes(x = factor(sample_size), y = runtime_min, fill = language)) +
  geom_boxplot() +
  labs(
    x = "Sample Size",
    y = "Runtime (min)",
    fill = "Language",
    title = "Runtime Distribution: R vs Julia"
  ) +
  theme_bw()

# plots memory
memory_data <- output %>%
  group_by(sample_size, language) %>%
  summarise(mean_memory = mean(peak_memory_MB, na.rm = TRUE), .groups = "drop")

ggplot(memory_data, aes(x = factor(sample_size), y = mean_memory, color = language, group = language)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    x = "Sample Size",
    y = "Mean Peak Memory usage (MB)",
    color = "Language",
    title = "Peak Memory Usage Comparison: R vs Julia"
  ) +
  theme_bw()

ggplot(output, aes(x = factor(sample_size), y = peak_memory_MB, fill = language)) +
  geom_boxplot() +
  labs(
    x = "Sample Size",
    y = "Mean Peak Memory usage (MB)",
    fill = "Language",
    title = "Peak Memory Usage Comparison: R vs Julia"
  ) +
  theme_bw()




