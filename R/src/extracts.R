# Define extract data

library(tidyverse)

extracts = read_csv("data/Extracts/extract-database.csv", show_col_types = FALSE) %>% 
  # first replace with sample extracted if two samples to eliminate the later spread step
  mutate(poop_vial_id = case_when(
    sample_extracted_if_two_samples == "n" ~ poop_vial_id, # this is a known error I happened to catch.
    !is.na(sample_extracted_if_two_samples) ~ str_to_upper(sample_extracted_if_two_samples),
    TRUE ~ poop_vial_id)) %>% 
  # extract tvariable poops and convert to unambiguous character string
  mutate(tvar1 = case_when(
    str_detect(poop_vial_id, "\\.") ~ sprintf("%06.2f", as.numeric(poop_vial_id)) #as.numeric(poop_vial_id),
    #!is.na(field_poop_vial_id) ~ sprintf("%06.2f", field_poop_vial_id),
  )) %>% 
  # extrct old poop ids and add spread them into poop_id columns
  # This still has to be done because there are a few samples where it was not indiciated 
  # which sample was extracted, so they will both get an entry
  bind_cols(
    str_extract_all(str_to_upper(.$poop_vial_id), "[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S][0-9]{4}", simplify = TRUE) %>% 
      as.data.frame() %>%
      rename_with(~ gsub("V", "poop_id", .x)) %>% 
      mutate(across(contains("poop"), ~ if_else(.x == "", NA_character_, .x)))
  ) %>% 
  mutate(poop_id1 = coalesce(tvar1, poop_id1, poop_vial_id),
         extraction_volume = 1000,
         hair_in_feces. = case_when(
           hair_in_feces. == "Y" ~ TRUE,
           hair_in_feces. == "N" ~ FALSE,
           TRUE ~ NA),
         extra_fecal_sample. = case_when(
           extra_fecal_sample. == "Y" ~ TRUE,
           extra_fecal_sample. == "N" ~ FALSE,
           TRUE ~ NA)) %>% 
  pivot_longer(cols = contains("poop_id"),
               values_to = "poop_id") %>% 
  filter(!is.na(poop_id)) %>% 
  #format for DB
  select(poop_id, extraction_date = date_of_extraction, extraction_observerID = extraaction_observer, 
         extraction_volume, weigh_date = date_weighed, weigh_observerID = weight_observer, hair = hair_in_feces.,
         contaminants = extraction_notes_.contaminants_removed., mass_g = mass_extracted_.g., extra = extra_fecal_sample.) %>% 
  mutate(extractID = row_number())

write_csv(extracts, "output/extract_raw.csv")


