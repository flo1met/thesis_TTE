# Process Julia files

library(arrow)
library(tidyverse)
library(purrr)


files <- list.files("Simulation 1/out/Julia", full.names = TRUE)
files[1:10]

out_combined <- files[1:10] %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


