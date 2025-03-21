# Process Julia files

library(arrow)
library(tidyverse)
library(purrr)


files_Julia <- list.files("Simulation 1/out/Julia", full.names = TRUE)

files_200_Julia <- files_Julia[grepl("Julia_MRD_data_200_\\d+\\.arrow$", files_Julia)]
files_1000_Julia <- files_Julia[grepl("Julia_MRD_data_1000_\\d+\\.arrow$", files_Julia)]
files_5000_Julia <- files_Julia[grepl("Julia_MRD_data_5000_\\d+\\.arrow$", files_Julia)]


Julia_out_200 <- files_200_Julia %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


Julia_out_combined_200 <- Julia_out_200 %>%
  group_by(fup) %>%
  summarize(MRD = mean(MRD_hat),
            CIlow = mean(CIlow_emp),
            CIhigh = mean(CIhigh_emp))

CI_200 <- Julia_out_200 %>%
  group_by(fup) %>%
  mutate(SD = sd(MRD_hat),
         CIlow = mean(MRD_hat) - 1.96*SD,
         CIhigh = mean(MRD_hat) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))




Julia_out_1000 <- files_1000_Julia %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


Julia_out_combined_1000 <- Julia_out_1000 %>%
  group_by(fup) %>%
  summarize(MRD = mean(MRD_hat),
            CIlow = mean(CIlow_emp),
            CIhigh = mean(CIhigh_emp))

CI_1000 <- Julia_out_1000 %>%
  group_by(fup) %>%
  mutate(SD = sd(MRD_hat),
         CIlow = mean(MRD_hat) - 1.96*SD,
         CIhigh = mean(MRD_hat) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))


Julia_out_5000 <- files_5000_Julia %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


Julia_out_combined_5000 <- Julia_out_5000 %>%
  group_by(fup) %>%
  summarize(MRD = mean(MRD_hat),
            CIlow = mean(CIlow_emp),
            CIhigh = mean(CIhigh_emp))

CI_5000 <- Julia_out_5000 %>%
  group_by(fup) %>%
  mutate(SD = sd(MRD_hat),
         CIlow = mean(MRD_hat) - 1.96*SD,
         CIhigh = mean(MRD_hat) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))



#### coverage
Julia_out_200 <- Julia_out_200 %>%
  left_join(CI_200, by = "fup")

sum(Julia_out_200$MRD_hat > Julia_out_200$CIlow & Julia_out_200$MRD_hat < Julia_out_200$CIhigh)/nrow(Julia_out_200)

Julia_out_1000 <- Julia_out_1000 %>%
  left_join(CI_1000, by = "fup")

sum(Julia_out_1000$MRD_hat > Julia_out_1000$CIlow & Julia_out_1000$MRD_hat < Julia_out_1000$CIhigh)/nrow(Julia_out_1000)

Julia_out_5000 <- Julia_out_5000 %>%
  left_join(CI_5000, by = "fup")

sum(Julia_out_5000$MRD_hat > Julia_out_5000$CIlow & Julia_out_5000$MRD_hat < Julia_out_5000$CIhigh)/nrow(Julia_out_5000)

### COVERAGE OF CI
## Real Value
true_pe <- read.csv("Simulation 1/out/True Values/TRUE_PE.csv")
Julia_out_200 <- Julia_out_200 %>%
  left_join(true_pe, by = "fup")

sum(Julia_out_200$True_MRD > Julia_out_200$CIlow_emp & Julia_out_200$True_MRD < Julia_out_200$CIhigh_emp)/nrow(Julia_out_200)

Julia_out_1000 <- Julia_out_1000 %>%
  left_join(true_pe, by = "fup")

sum(Julia_out_1000$True_MRD > Julia_out_1000$CIlow_emp & Julia_out_1000$True_MRD < Julia_out_1000$CIhigh_emp)/nrow(Julia_out_1000)

Julia_out_5000 <- Julia_out_5000 %>%
  left_join(true_pe, by = "fup")

sum(Julia_out_5000$True_MRD > Julia_out_5000$CIlow_emp & Julia_out_5000$True_MRD < Julia_out_5000$CIhigh_emp)/nrow(Julia_out_5000)


## Bias CI
mean(Julia_out_200$CIlow_emp - Julia_out_200$CIlow)
mean(Julia_out_200$CIhigh_emp - Julia_out_200$CIhigh)

mean(Julia_out_1000$CIlow_emp - Julia_out_1000$CIlow)
mean(Julia_out_1000$CIhigh_emp - Julia_out_1000$CIhigh)

mean(Julia_out_5000$CIlow_emp - Julia_out_5000$CIlow)
mean(Julia_out_5000$CIhigh_emp - Julia_out_5000$CIhigh)

## MSE CI
mean((Julia_out_200$CIlow_emp - Julia_out_200$CIlow)^2)
mean((Julia_out_200$CIhigh_emp - Julia_out_200$CIhigh)^2)

mean((Julia_out_1000$CIlow_emp - Julia_out_1000$CIlow)^2)
mean((Julia_out_1000$CIhigh_emp - Julia_out_1000$CIhigh)^2)

mean((Julia_out_5000$CIlow_emp - Julia_out_5000$CIlow)^2)
mean((Julia_out_5000$CIhigh_emp - Julia_out_5000$CIhigh)^2)

## Variance CI
var(Julia_out_200$CIlow_emp)
var(Julia_out_200$CIhigh_emp)

var(Julia_out_1000$CIlow_emp)
var(Julia_out_1000$CIhigh_emp)

var(Julia_out_5000$CIlow_emp)
var(Julia_out_5000$CIhigh_emp)




### Bias Variance MSE (of estimator, not interesting)
mean(Julia_out_200$MRD_hat - Julia_out_200$True_MRD)
mean((Julia_out_200$MRD_hat - Julia_out_200$True_MRD)^2)
var(Julia_out_200$MRD_hat)

mean(Julia_out_1000$MRD_hat - Julia_out_1000$True_MRD)
mean((Julia_out_1000$MRD_hat - Julia_out_1000$True_MRD)^2)
var(Julia_out_1000$MRD_hat)

mean(Julia_out_5000$MRD_hat - Julia_out_5000$True_MRD)
mean((Julia_out_5000$MRD_hat - Julia_out_5000$True_MRD)^2)
var(Julia_out_5000$MRD_hat)

