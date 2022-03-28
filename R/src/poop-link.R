# poop_link table

library(tidyverse)
library(readxl)
library(lubridate)
library(RMySQL)

con = dbConnect(MySQL(), group = "krsp-aws")
poop_external <- read_csv("https://raw.githubusercontent.com/KluaneRedSquirrelProject/poop/master/output/poop_external.csv", show_col_types = FALSE) %>%
  mutate(poop_time = as.character(poop_time))

source('R/helpers.R')

trapping = DBI::dbGetQuery(con, statement = read_file("sql_scripts/trapping_connection.sql")) %>% 
  tibble()
dba_trapping = DBI::dbGetQuery(con, statement = read_file("sql_scripts/dbatrapping_connection.sql")) %>% 
  tibble()

pooperScooper = function(.data, year) {
  #This function will extract poop_id from tvar columns from 2018 on
  data = .data %>% 
    filter(year(date) == year,
           !is.na(tvariable1)) %>% 
  mutate(poop_id = sprintf("%06.2f", tvariable1), poop_time = clean_tvar2(tvariable2), year = year(date)) %>% 
    select(contains("_id"), year, poop_time, comments)
  return(data)
}

# We have to treat each year independently with a LOT of check along the way

poop_2008 = trapping %>% 
  filter(year(date) == 2008,
         comments != "") %>% 
  extract_poopID() %>% 
  select(contains("_id"), year, poop_time, comments)

poops_external = poop_external %>% 
  filter(year %in% c(2006:2011),
         !is.na(poop_id)) %>% 
  select(contains("_id"), year, poop_time, comments)


# 2012 The poops come from the dbatrapping table
poop_2012 = dba_trapping %>% 
  filter(year(date) == 2012) %>% 
  # below, there are some weird poops so we just extract properly ormatted ones
  # There are a few instances of 0s being turned into Os, which this will filter OUT
  # So  those are lost to time
  # Someone else can fix them
  mutate(poop_id = str_extract(str_to_upper(poop), "[A-Z]{1,2}[0-9]{3,4}"),
         year = year(date),
         ptime = clean_pt(ptime)) %>% 
  filter(!is.na(poop_id)) %>% 
  select(contains("_id"), year, poop_time = ptime, comments)

# No data fro 2013

# 2018 on, store this function so that we can use it in the future
poop_2018_on = map(2018:2021, pooperScooper, .data = trapping) %>% 
  bind_rows()

poops = ls(pattern = "poop_2") %>% 
  map(as.symbol) %>% 
  map(eval) %>% 
  bind_rows() %>% 
  mutate(across(!c(poop_id, comments), as.integer)) %>% 
  select(contains("_id"), year, poop_time, comments)

write_csv(poops, file = "output/poops.csv")
dbDisconnect(con); rm(con)
rm(list = ls(pattern = "poop|trap"))