# Setting Up My Environment
library(tidyverse)
library(skimr)
library(janitor)
library(lubridate)
library(readxl)
housing <- read.csv("~/Documents/Data-Analysis/Github/Portfolio-Projects/04-Data-Cleaning-in-R/Nashville-Housing-Data.csv")

# Import Excel Worksheet
# housing <- read_excel("~/Documents/Data-Analysis/Github/Portfolio-Projects/04-Data-Cleaning-in-R/Nashville-Housing-Data.xlsx")


# Data Cleaning in R

################################################################################

# Changing Date to YYYY-MM-DD Format, Replace Original SaleDate Column
housing <- mutate(housing, SaleDate = mdy(housing$SaleDate))


# S/A/A, Changing Date to YYYY-MM-DD Format, New Columns
housing <- mutate(housing, newSaleDate = mdy(housing$SaleDate))


################################################################################

# Change Y and N to Yes and No in "Sold as Vacant" Column

# Check To See Values in SoldAsVacant Column 
housing %>%
  select(SoldAsVacant) %>% 
  lapply(table)


# Using ifelse to Change SoldAsVacant Column
housing <- housing %>% 
  mutate(SoldAsVacant = ifelse(SoldAsVacant == 'Y', 'Yes', SoldAsVacant)) %>% 
  mutate(SoldAsVacant = ifelse(SoldAsVacant == 'N', 'No', SoldAsVacant))


# Using case_when to Change SoldAsVacant Column
housing <- housing %>% 
  mutate(SoldAsVacant = case_when(
    SoldAsVacant == 'Y' ~ 'Yes',
    SoldAsVacant == 'Yes' ~ 'Yes',
    SoldAsVacant == 'N' ~ 'No',
    SoldAsVacant == 'No' ~ 'No'
  ))


################################################################################

# Populate Missing Property Address From Common ParcelID
# Remove Any Duplicates

housing2 <- housing
df <- merge(housing, housing2, by = 'ParcelID')

df[] <- df %>% 
  mutate(PropertyAddress.x = ifelse(PropertyAddress.x == '',
                                    PropertyAddress.y,
                                    PropertyAddress.x))

housing <- df %>% 
  filter(PropertyAddress.x != '') %>% 
  select(ParcelID, contains('.x')) %>% 
  #rename_with(~str_remove(., '.x')) %>%  # Originally used this, caused Column TaxDistrict -> TDistrict.x
  rename_with(~gsub('.x', '', .x, fixed = TRUE)) %>% 
  distinct(ParcelID, SalePrice, SaleDate, LegalReference, .keep_all = TRUE)


################################################################################


# Splitting Property Address into Individual Columns: Street, City
housing <- housing %>% 
  separate(PropertyAddress, into = c('PropertyStreet', 'PropertyCity'), sep = ',')


# Splitting Owner Address into Individual columns: Street, City, State
housing <- housing %>% 
  separate(OwnerAddress, into = c('OwnerStreet', 'OwnerCity', 'OwnerState'), sep = ',')


################################################################################


# Change any Blank or NA Owner Data to 'N/A'

housing <- housing %>%
  mutate(OwnerName = ifelse(OwnerName == '' | is.na(OwnerName) == TRUE, 'N/A', OwnerName)) %>% 
  mutate(OwnerStreet = ifelse(OwnerStreet == '' | is.na(OwnerStreet) == TRUE, 'N/A', OwnerStreet)) %>% 
  mutate(OwnerCity = ifelse(OwnerCity == '' | is.na(OwnerCity) == TRUE, 'N/A', OwnerCity)) %>% 
  mutate(OwnerState = ifelse(OwnerState == '' | is.na(OwnerState) == TRUE, 'N/A', OwnerState))


################################################################################


# Remove Any Leading/trailing Spaces from Entire Data Frame

housing <- housing %>% 
  mutate(across(where(is.character), str_trim))


################################################################################


# Export the Dataframe to CSV File

write_csv(housing, "~/Documents/Data-Analysis/Github/Portfolio-Projects/04-Data-Cleaning-in-R/Nashville-Housing-Data-CLEANED.csv")


