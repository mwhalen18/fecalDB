library(tidyverse)
hormones = read_csv("output/hormones_raw.csv")

#protocols 
# protocol_id | dilution | volume_used | hormone

protocols = hormones %>% 
  select(protocol_id, lab, dilution, volume_used, hormone) %>% 
  unique()

write_csv(protocols, "output/protocols.csv")