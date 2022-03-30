library(tidyverse)
library(RMySQL)

extracts = read_csv("output/final_Extract.csv", show_col_types = FALSE) %>% 
  select(id, poop_id)
extracts_nomatch = read_csv("output/final_extracts_nomatch.csv", show_col_types = FALSE) %>% 
  select(id, poop_id)

assays = read_csv("output/hormones_raw.csv", show_col_types = FALSE) %>% 
  select(-c(lab, hormone, dilution, volume_used)) %>% 
  left_join(extracts, by = "poop_id") %>% 
  rename(extract_id = id) %>% 
  select(-c(poop_id, is_rerun))

assays_nomatch = assays %>% 
  filter(extract_id %in% extracts_nomatch$id) %>% 
  mutate(id = row_number())

write_csv(assays, "output/final_Assay.csv")
write_csv(assays_nomatch, "output/final_Assaynomatch.csv")
con = dbConnect(MySQL(), group = "krspfecals-DEV")
dbWriteTable(con, "Assay", assays, append = TRUE, row.names = F)
dbWriteTable(con, "Assaynomatch", assays_nomatch, append = TRUE, row.names = F)
dbDisconnect(con);rm(con)