# Poop-link prep
options(tidyverse.quiet = TRUE)
library(RMySQL)
library(tidyverse)
con = dbConnect(MySQL(), group = "krspfecals-DEV")


poop = read_csv("output/poops.csv", show_col_types = FALSE) %>% 
  relocate(poop_id)

duplicate_poops = poop %>% 
  group_by(poop_id) %>% 
  filter(n_distinct(trapping_id) > 1) %>% 
  ungroup()

write_csv(poop, "output/final_Poop.csv")
write_csv(duplicate_poops, "output/final_poop_duplicates.csv")
dbWriteTable(con, "Poop", poop, append = TRUE, row.names = FALSE)
dbWriteTable(con, "DuplPoop", duplicate_poops, append = TRUE, row.names = FALSE)
dbDisconnect(con);rm(con)
