#plates

plates = read_csv("output/hormones_raw.csv", show_col_types = FALSE) %>% 
  group_by(protocol_id) %>% 
  mutate(wasna = is.na(plate_id),
         plate_id = case_when(
           is.na(plate_id) ~ paste(protocol_id, row_number(), sep = ""),
           TRUE ~ plate_id
  )) %>% 
  ungroup() %>% 
  select(plate_id, observer_id, date, concentration, cv)

write_csv(plates, "output/plates.csv")

  