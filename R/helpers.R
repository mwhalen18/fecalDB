#helpers

extract_pt <- function(x, first = TRUE) {
  x <- stringr::str_to_lower(x)
  # first look for a PT
  rgex <- "(?<=p(t|r)[-;,:]?\\s{0,2})[0-2]?[0-9](h|:)?[0-9]{2}\\s?(am|pm)?"
  pt <- stringr::str_extract(x, rgex)
  # in case PT is missing
  pv <- "(?<=pv[-:;]?\\s{0,2}[a-z]?\\s?[0-9]{3,5}[;,:\\sa-z]{1,6})"
  rgex <- "[0-2]?[0-9](h|:)?[0-9]{2}\\s?(am|pm)?"
  no_pt <- stringr::str_extract(x, paste0(pv, rgex))
  pt <- dplyr::coalesce(pt, no_pt)
  clean_pt(pt)
}

clean_pt <- function(x) {
  x <- stringr::str_to_lower(x)
  # standardize format
  is_pm <- !is.na(x) & str_detect(x, "pm$")
  pt <- stringr::str_replace_all(x, "[^0-9]", "")
  pt_int <- as.integer(pt)
  pt_int <- pt_int + ifelse(is_pm & pt_int < 1200, 1200, 0)
  pt <- as.character(pt_int)
  pt <- paste0(ifelse(!is.na(pt) & nchar(pt) == 3, "0", ""), pt)
  pt[pt == "NA"] <- NA_character_
  pt
}

extract_pv <- function(x, first = TRUE) {
  x <- stringr::str_to_lower(x)
  if (first) {
    regex <- "(?<=(pv|poop)[-:;]?\\s{0,2})[a-z]?\\s?[0-9]{3,5}"
    pv <- stringr::str_extract(x, regex)
  } else {
    previous <- "(?<=(pv|poop)[-:;]?\\s{0,2}[a-z]?\\s?[0-9]{3,5}[;\\s]{1,2}(and\\s)?)"
    pv <- stringr::str_extract(x, paste0(previous, "[a-z]{1}[0-9]{3,5}"))
  }
  stringr::str_to_upper(pv)
}

#clunky function to add zeroes to the end of the poop times until they have 4 digits
clean_tvar2 = function(tvar2){
  tvar2 = sub("\\.", "", tvar2)
  return(tvar2)
}

extract_poopID = function(.data, pt_rgx = "(?<=p[0-9]{4}[-;,:]?\\s{0,2})[0-2]?[0-9](h|:)?[0-9]{2}\\s?(am|pm)?") {
  .data %>%
    bind_cols(
      #the following extracts each poop_id, formats them as a data frame then reattaches
      # them to the main query
      str_extract_all(str_to_upper(.$comments), "[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S][0-9]{4}", simplify = TRUE) %>%
        as.data.frame() %>%
        rename_with(~ gsub("V", "poop_id", .x))
    ) %>%
    mutate(poop_time = str_extract(str_to_upper(comments), pt_rgx),
           across(contains("poop_id"), ~ ifelse(.x == "", NA_character_, .x)),
           year = year(date)) %>%
    # each row is now a unique poop id
    pivot_longer(cols = contains("poop_id"),
                 values_to = "poop_id") %>% 
    filter(!is.na(poop_id),
           poop_id != "")
}

