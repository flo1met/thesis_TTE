getwd()
out_df <- read.csv("out_df.csv")
out_df <- out_df %>% 
  arrange(id, period, trialnr)
