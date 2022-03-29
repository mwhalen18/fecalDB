library(tidyverse)
library(googlesheets4)

gs4_auth(email = "matthew.whalen18@gmail.com")
ss = "https://docs.google.com/spreadsheets/d/1gh4RkPbT44No7sDLYZudvephSGMcsV1zehi1fRk27v4/edit#gid=0"

x = read_sheet(ss) %>%
  janitor::clean_names() %>%
  mutate(across(everything(), as.character))

boxes = x %>% 
  pivot_longer(cols = everything(),
               names_to = "box_id",
               values_to = "poop_id",
               names_prefix = "box_") %>% 
  filter(!is.na(poop_id),
         str_detect(poop_id, "[*]", negate = TRUE)) %>% 
  mutate(poop_id = case_when(
    str_detect(poop_id, "\\.") ~ sprintf("%06.2f", as.numeric(poop_id)),
    TRUE ~ poop_id))

write_csv(boxes, "output/boxes.csv")
