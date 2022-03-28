library(tidyverse)
library(janitor)


assays = read_csv("data/Assays/fecal_database.csv", show_col_types = FALSE) %>% 
  janitor::clean_names() %>%
  # fix cort date as it is in EXCEL numeric format
  mutate(date_cort_eia = janitor::excel_numeric_to_date(as.numeric(date_cort_eia))) %>% 
  # first replace with sample extracted if two samples to eliminate the later spread step
  mutate(poop_vial_id = case_when(
    sample_extracted_if_two_samples == "n" ~ poop_vial_id, # this is a known error I happened to catch.
    !is.na(sample_extracted_if_two_samples) ~ str_to_upper(sample_extracted_if_two_samples),
    TRUE ~ poop_vial_id)) %>% 
  mutate(tvar1 = case_when(
    str_detect(poop_vial_id, "\\.") ~ sprintf("%06.2f", as.numeric(poop_vial_id)),
    #!is.na(field_poop_vial_id) ~ sprintf("%06.2f", field_poop_vial_id),
  )) %>% 
  bind_cols(
    str_extract_all(str_to_upper(.$poop_vial_id), "[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S][0-9]{4}", simplify = TRUE) %>% 
      as.data.frame() %>%
      rename_with(~ gsub("V", "poop_id", .x)) %>% 
      mutate(across(contains("poop"), ~ if_else(.x == "", NA_character_, .x)))
  ) %>% 
  mutate(poop_id1 = coalesce(tvar1, poop_id1, poop_vial_id)) %>% 
  pivot_longer(cols = contains("poop_id"),
               values_to = "poop_id") %>% 
  filter(!is.na(poop_id)) %>% 
  select(-c(poop_vial_id, field_poop_vial_id, duplicate_sample, poop_time, sample_extracted_if_two_samples,
            extra_fecal_sample, me_oh_extraction_volume_u_l, name, fcm_analyzed, fam_analyzed, tvar1, cort_repeat)) %>% 
  relocate(poop_id)

#write_csv(assays, "output/assays_cleaned.csv")

# Now we need to fix the cort and androgen so that each row is a single poop id
# and a single assay run
cort = assays %>% 
  select(poop_id, eia_lab, observer_id = eia_done_by,
         contains("cort")) %>% 
  rename(cort_eia_plate_id = cort_eia_plate_id_run_1) %>% 
  select(-c(cort_final_concentration, cort_high_cv, contains("bjd_repeated")))

r1 = cort %>% 
  select(poop_id, eia_lab, observer_id, !contains("repeat")) %>% 
  rename_with(~str_remove_all(., "(cort_|_cort)|(_eia|eia_)"), .cols = everything()) %>% 
  filter(!is.na(concentration)) %>% 
  mutate(is_rerun = FALSE)

r2 = cort %>% 
  select(poop_id, eia_lab, observer_id, contains("repeat")) %>% 
  filter(!is.na(repeat_cort_concentration)) %>% 
  rename_with(~str_remove_all(., "(_repeated|repeat_|_repeat)|(cort_|_cort)|(_eia|eia_)"), .cols = everything()) %>% 
  mutate(is_rerun = TRUE)

cort_final = bind_rows(r1, r2) %>% 
  unique() %>% 
  mutate(hormone = "Cortisol")

#write_csv(cort_final, "output/cort_final.csv")

androgen = assays %>% 
  select(poop_id, eia_lab, observer_id = eia_done_by, contains("androgen"), -androgen_high_cv) %>% 
  rename_with(~str_remove_all(., "(_androgen|androgen_)|(_eia|eia_)|(final_)"), .cols = everything()) %>% 
  filter(!is.na(concentration)) %>% 
  unique() %>% 
  mutate(hormone = "Testosterone")

hormones = bind_rows(cort_final,androgen) %>% 
  mutate(protocol_id = paste(substr(hormone,1,1), substr(lab,1,1), floor(dilution), floor(volume_used), sep = ""))

write_csv(hormones, "output/hormones_raw.csv")
