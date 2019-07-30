# Merging Datasets for "Intro to Google Data Studio IV"

    # 2019-07-30
    # OS: Windows 10
    # R Version: 3.6.0
    # RStudio Version: 1.2.1335


# Install & Load Packages

if(!require(readr)){install.packages("readr")}
if(!require(dplyr)){install.packages("dplyr")}
if(!require(stringr)){install.packages("stringr")}

library(readr)
library(dplyr)
library(stringr)


# Read in Datasets

url_att <- "https://data.ny.gov/api/views/8f3n-xj78/rows.csv?accessType=DOWNLOAD"
url_geo <- "https://data.ny.gov/api/views/97ur-5r4b/rows.csv?accessType=DOWNLOAD"

att <- read_csv(url_att)
geo <- read_csv(url_geo)

rm(url_att, url_geo)     # Remove URL objects


# Reconcile Variable "Facility" Values

cny_att <- att %>%
  filter(County %in% c("Onondaga", "Madison", "Oswego", "Cayuga", 
                       "Cortland", "Onondaga/Madison/Oneida"))

cny_geo <- geo %>%
  filter(County %in% c("Onondaga", "Madison", "Oswego", "Cayuga", 
                       "Cortland", "Onon/Mad/Oneida"))

rm(att, geo)

cny_geo[which(cny_geo$County == "Onon/Mad/Oneida"), "County"] <- "Onondaga/Madison/Oneida"

cny_att <- cny_att %>% 
  mutate(Facility = str_replace_all(string = Facility, 
                                    pattern = " St Pk| State Park| \\*1", 
                                    replacement = ""),
         Facility = str_replace_all(string = Facility,
                                    pattern = "Fls",
                                    replacement = "Falls"),
         Facility = str_replace_all(string = Facility,
                                    pattern = "Isl Golf Course",
                                    replacement = "Island")) %>%
  arrange(Facility)

cny_geo <- cny_geo %>%
  mutate(Name = str_replace_all(string = Name, 
                                pattern = " Marine Park", 
                                replacement = " Boat Launch"),
         Name = str_replace_all(string = Name, 
                                pattern = "Fair Haven Beach", 
                                replacement = "Fair Haven")) %>%
  rename(Facility = Name) %>%
  arrange(Facility) 


# Merge Data

sps <- left_join(cny_geo, cny_att) %>%
  select(Year, Facility:County, Attendance, Golf:Playground, `Facility URL`, Longitude:Location)

sps <- sps[which(complete.cases(sps)), ]

rm(cny_att, cny_geo)


# Replace Y/N with "Yes" & "No"

sps[which(sps$Golf == "Y"), "Golf"] <- "Yes"
sps[which(sps$Golf == "N"), "Golf"] <- "No"
sps[which(sps$Camp == "Y"), "Camp"] <- "Yes"
sps[which(sps$Camp == "N"), "Camp"] <- "No"
sps[which(sps$Playground == "Y"), "Playground"] <- "Yes"
sps[which(sps$Playground == "N"), "Playground"] <- "No"


# Order Observations: Facility, Year

sps <- sps %>%
  arrange(Facility, Year)


# Write to .CSV

setwd("~/CNYCF/Data Studio Learning Community/2019-08-02 Session 4")
write_csv(sps, "cny_parks.csv")