# Process R files

library(arrow)
library(tidyverse)
library(purrr)


files_R <- list.files("Simulation 1/out/R", full.names = TRUE)

files_200_R <- files_R[grepl("R_MRD_data_200_\\d+\\.arrow$", files_R)]
files_1000_R <- files_R[grepl("R_MRD_data_1000_\\d+\\.arrow$", files_R)]
files_5000_R <- files_R[grepl("R_MRD_data_5000_\\d+\\.arrow$", files_R)]


R_out_200 <- files_200_R %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


R_out_combined_200 <- R_out_200 %>%
  group_by(followup_time) %>%
  summarize(MRD = mean(survival_diff),
            CIlow = mean(`2.5%`),
            CIhigh = mean(`97.5%`))

CI_200 <- R_out_200 %>%
  group_by(followup_time) %>%
  mutate(SD = sd(survival_diff),
         CIlow = mean(survival_diff) - 1.96*SD,
         CIhigh = mean(survival_diff) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))




R_out_1000 <- files_1000_R %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


R_out_combined_1000 <- R_out_1000 %>%
  group_by(followup_time) %>%
  summarize(MRD = mean(survival_diff),
            CIlow = mean(`2.5%`),
            CIhigh = mean(`97.5%`))

CI_1000 <- R_out_1000 %>%
  group_by(followup_time) %>%
  mutate(SD = sd(survival_diff),
         CIlow = mean(survival_diff) - 1.96*SD,
         CIhigh = mean(survival_diff) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))


R_out_5000 <- files_5000_R %>%
  map(~ read_feather(.x) %>% mutate(nsim = sub(".*_(\\d+)\\.arrow$", "\\1", basename(.x)))) %>%
  bind_rows()


R_out_combined_5000 <- R_out_5000 %>%
  group_by(followup_time) %>%
  summarize(MRD = mean(survival_diff),
            CIlow = mean(`2.5%`),
            CIhigh = mean(`97.5%`))

CI_5000 <- R_out_5000 %>%
  group_by(followup_time) %>%
  mutate(SD = sd(survival_diff),
         CIlow = mean(survival_diff) - 1.96*SD,
         CIhigh = mean(survival_diff) + 1.96*SD) %>%
  summarise(CIlow = mean(CIlow),
            CIhigh = mean(CIhigh))



#### coverage
R_out_200 <- R_out_200 %>%
  left_join(CI_200, by = "followup_time")

sum(R_out_200$survival_diff > R_out_200$CIlow & R_out_200$survival_diff < R_out_200$CIhigh)/nrow(R_out_200)

R_out_1000 <- R_out_1000 %>%
  left_join(CI_1000, by = "followup_time")

sum(R_out_1000$survival_diff > R_out_1000$CIlow & R_out_1000$survival_diff < R_out_1000$CIhigh)/nrow(R_out_1000)

R_out_5000 <- R_out_5000 %>%
  left_join(CI_5000, by = "followup_time")

sum(R_out_5000$survival_diff > R_out_5000$CIlow & R_out_5000$survival_diff < R_out_5000$CIhigh)/nrow(R_out_5000)

### COVERAGE OF CI
## Real Value
true_pe <- read.csv("Simulation 1/out/True Values/TRUE_PE.csv")
names(true_pe) <- c("X", "followup_time", "True_MRD")
R_out_200 <- R_out_200 %>%
  left_join(true_pe, by = "followup_time")

sum(R_out_200$True_MRD > R_out_200$`2.5%` & R_out_200$True_MRD < R_out_200$`97.5%`)/nrow(R_out_200)

R_out_1000 <- R_out_1000 %>%
  left_join(true_pe, by = "followup_time")

sum(R_out_1000$True_MRD > R_out_1000$`2.5%` & R_out_1000$True_MRD < R_out_1000$`97.5%`)/nrow(R_out_1000)

R_out_5000 <- R_out_5000 %>%
  left_join(true_pe, by = "followup_time")

sum(R_out_5000$True_MRD > R_out_5000$`2.5%` & R_out_5000$True_MRD < R_out_5000$`97.5%`)/nrow(R_out_5000)


## Bias CI
mean(R_out_200$`2.5%` - R_out_200$CIlow)
mean(R_out_200$`97.5%` - R_out_200$CIhigh)

mean(R_out_1000$`2.5%` - R_out_1000$CIlow)
mean(R_out_1000$`97.5%` - R_out_1000$CIhigh)

mean(R_out_5000$`2.5%` - R_out_5000$CIlow)
mean(R_out_5000$`97.5%` - R_out_5000$CIhigh)

## MSE CI
mean((R_out_200$`2.5%` - R_out_200$CIlow)^2)
mean((R_out_200$`97.5%` - R_out_200$CIhigh)^2)

mean((R_out_1000$`2.5%` - R_out_1000$CIlow)^2)
mean((R_out_1000$`97.5%` - R_out_1000$CIhigh)^2)

mean((R_out_5000$`2.5%` - R_out_5000$CIlow)^2)
mean((R_out_5000$`97.5%` - R_out_5000$CIhigh)^2)

## Variance CI
var(R_out_200$`2.5%`)
var(R_out_200$`97.5%`)

var(R_out_1000$`2.5%`)
var(R_out_1000$`97.5%`)

var(R_out_5000$`2.5%`)
var(R_out_5000$`97.5%`)



########
### Bias Variance MSE of estiamtor (not interesting)
mean(R_out_200$survival_diff - R_out_200$True_MRD)
mean((R_out_200$survival_diff - R_out_200$True_MRD)^2)
var(R_out_200$survival_diff)

mean(R_out_1000$survival_diff - R_out_1000$True_MRD)
mean((R_out_1000$survival_diff - R_out_1000$True_MRD)^2)
var(R_out_1000$survival_diff)

mean(R_out_5000$survival_diff - R_out_5000$True_MRD)
mean((R_out_5000$survival_diff - R_out_5000$True_MRD)^2)
var(R_out_5000$survival_diff)
