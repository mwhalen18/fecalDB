library(tidyverse)
library(RMySQL)

protocols = read_csv("output/protocols.csv", show_col_types = FALSE) %>% 
  rename(id = protocol_id, eia_lab = lab)
write_csv(protocols, "output/final_protocols.csv")

con = dbConnect(MySQL(), group = "krspfecals-DEV")
dbWriteTable(con, "Protocol", protocols, append = TRUE, row.names = FALSE)
dbDisconnect(con);rm(con)
