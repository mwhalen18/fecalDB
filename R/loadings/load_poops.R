# Poop-link prep
library(RMySQL)
library(tidyverse)
con = dbConnect(MySQL(), group = "krspfecals-DEV")


poop = read_csv("output/poops.csv", show_col_types = FALSE) %>% 
  relocate(poop_id)

duplicate_poops = poop %>% 
  group_by(poop_id) %>% 
  filter(n_distinct(trapping_id) > 1) %>% 
  ungroup()

dbWriteTable(con, "Poop", poop, append = TRUE, row.names = FALSE)
dbWriteTable(con, "DuplPoop", duplicate_poops, append = TRUE, row.names = FALSE)
dbDisconnect(con); rm(con)