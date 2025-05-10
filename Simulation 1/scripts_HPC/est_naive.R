args <- commandArgs(trailingOnly = TRUE)
file <- args[1]

library(arrow)
library(survival)

data <- read_feather(file)

data_itt <- subset(data, eligible == 1)


coxfit <- coxph(Surv(t, Y) ~ A + X2 + X4, data = data_itt)

# Predict survival at 0:4 (if desired)
survfit_obj <- survfit(coxfit, newdata = data_itt)

summary(survfit_obj)


baseline <- data[data$t == 0 & data$eligible == 1, c("ID", "A", "X2", "X4")]
data_itt <- merge(data, baseline, by = "ID", suffixes = c("", "_baseline"))
cox <- coxph(Surv(t, Y) ~ A_baseline + X2_baseline + X4_baseline, data = data_itt)
summary(cox)
