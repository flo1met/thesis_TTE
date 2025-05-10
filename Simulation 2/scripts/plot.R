library(tidyverse)
library(ggplot2)

julia_CI <- read.csv("Simulation 2/out/performance_summary_julia.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_kb = mean(alloc_kb)) %>%
  mutate(lang = "Julia")

r_CI <- read.csv("Simulation 2/out/performance_summary_r.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds, na.rm = TRUE), # rm missings introduced by non-inverse matrix error
            alloc_kb = mean(alloc_kb, na.rm = TRUE)) %>%
  mutate(lang = "R")

julia_noCI <- read.csv("Simulation 2/out/performance_summary_noCI_julia.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_kb = mean(alloc_kb)) %>%
  mutate(lang = "Julia")

r_noCI <- read.csv("Simulation 2/out/performance_summary_noCI_r.csv") %>%
  extract(
    col     = file,
    into    = c("n", "nsim"),
    regex   = "data_(\\-?[0-9]+(?:\\.[0-9]+)?)_-3.8_0.5_0_(\\-?[0-9]+(?:\\.[0-9]+)?).csv",
    convert = TRUE,
    remove  = FALSE
  ) %>%
  group_by(n) %>%
  summarise(time_seconds = mean(time_seconds),
            alloc_kb = mean(alloc_kb)) %>%
  mutate(lang = "R")



noCI <- bind_rows(r_noCI, julia_noCI)

ggplot(noCI, aes(x = factor(n), y = time_seconds, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Time (seconds)",
    title = "Execution Time: R vs Julia"
  ) +
  theme_bw()

CI <- bind_rows(r_CI, julia_CI)

ggplot(CI, aes(x = factor(n), y = time_seconds, color = lang, group = lang)) +
  geom_line(size = 0.5) +
  geom_point() +
  labs(
    x = "Sample Size",
    y = "Time (seconds)",
    title = "Execution Time: R vs Julia"
  ) +
  theme_bw()



