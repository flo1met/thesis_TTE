library(tidyverse)
library(ggplot2)

df_200 <- read.csv("Additionals/out/BS_sample_200.csv")

hist(df_200$Iter1)
hist(df_200$Iter2)
hist(df_200$Iter3)
hist(df_200$Iter4)
hist(df_200$Iter5)

colnames(df_200) <- paste0("FUP ", 1:5)

# Reshape to long format
df_long_200 <- df_200 %>%
  pivot_longer(cols = everything(),
               names_to = "FUP",
               values_to = "Value")

ggplot(df_long_200, aes(x = Value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ FUP, scales = "free") +
  theme_bw(base_size = 14) +
  labs(title = "Distribution of bootstrapped MRD estimates with n = 200",
       x = NULL, y = NULL) +
  theme(
    plot.title = element_text(size = 12),
    strip.text = element_text(size = 10),  
    axis.title = element_blank()           
  )

ggsave(filename = "Additionals/out/plot_BSdist_200.png", width = 10, height = 6, dpi = 300)


df_1000 <- read.csv("Additionals/out/BS_sample_1000.csv")

colnames(df_1000) <- paste0("FUP ", 1:5)

# Reshape to long format
df_long_1000 <- df_1000 %>%
  pivot_longer(cols = everything(),
               names_to = "FUP",
               values_to = "Value")

ggplot(df_long_1000, aes(x = Value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ FUP, scales = "free") +
  theme_bw(base_size = 14) +
  labs(title = "Distribution of bootstrapped MRD estimates with n = 1000",
       x = NULL, y = NULL) +
  theme(
    plot.title = element_text(size = 12),
    strip.text = element_text(size = 10),  
    axis.title = element_blank()           
  )

ggsave(filename = "Additionals/out/plot_BSdist_1000.png", width = 10, height = 6, dpi = 300)


df_5000 <- read.csv("Additionals/out/BS_sample_5000.csv")

colnames(df_5000) <- paste0("FUP ", 1:5)

df_long_5000 <- df_5000 %>%
  pivot_longer(cols = everything(),
               names_to = "FUP",
               values_to = "Value")

ggplot(df_long_5000, aes(x = Value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ FUP, scales = "free") +
  theme_bw(base_size = 14) +
  labs(title = "Distribution of bootstrapped MRD estimates with n = 5000",
       x = NULL, y = NULL) +
  theme(
    plot.title = element_text(size = 12),
    strip.text = element_text(size = 10),  
    axis.title = element_blank()           
  )



ggsave(filename = "Additionals/out/plot_BSdist_5000.png", width = 10, height = 6, dpi = 300)
