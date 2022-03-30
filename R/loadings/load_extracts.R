library(tidyverse)
library(RMySQL)

con = dbConnect(MySQL(), group = "krspfecals-DEV")
extracts = read_csv("output/extract_raw.csv", show_col_types = F) %>% 
  select(-extractID) %>% 
  rename_with(~str_replace(., "observerID", "observer_id"), .cols = contains("observer")) %>% 
  rename(contaminants_removed = contaminants) %>% 
  mutate(id = row_number()) %>% 
  relocate(id)


poop = read_csv("output/poops.csv", show_col_types = FALSE)
extracts_nomatch = extracts %>% 
  filter(!poop_id %in% poop$poop_id)

boxes = read_csv("output/boxes.csv", show_col_types = F)

results = left_join(extracts, boxes, by = "poop_id")
results_nomatch = left_join(extracts_nomatch, boxes, by = "poop_id")

write_csv(results, "output/final_Extract.csv")
write_csv(results_nomatch, "output/final_extracts_nomatch.csv")
dbWriteTable(con, "Extract", results, append = TRUE, row.names = FALSE)
dbWriteTable(con, "Extractnomatch", results_nomatch, append = TRUE, row.names = FALSE)
dbDisconnect(con);rm(con)