Cleaning Nashville Housing Data in R
================
Cory Gargan
2022-12-08

# Cleaning a Raw Dataset for further Analysis

#### I took this raw dataset containing Nashville housing data and made it clean and usable. I made responses consistent, columns more search & sort friendly, and populated any missing property addresses.

Note: To create my environment I loaded the following libraries:

- `tidyverse`  
- `skimr`  
- `janitor`  
- `lubridate`

Along with the dataset:

- `Nashville-Housing-Data`
  - This dataset can be found in the github project folder

``` r
library(tidyverse)  
library(skimr)
library(janitor)
library(lubridate)
housing <- read.csv("~/Documents/Data-Analysis/Github/Portfolio-Projects/02-Data-Cleaning-in-R/Nashville-Housing-Data.csv")
```

### Changing `SaleDate` Format to YYYY-MM-DD

The original SaleDate column had the month spelled out.

- Originally: May 24, 2022
  - Formated to: 2022-05-24

``` r
# Changing Date to YYYY-MM-DD Format, Replace Original SaleDate Column
housing <- mutate(housing, SaleDate = mdy(housing$SaleDate))
```

### Standardized data: Y and N changed to Yes and No in `SoldAsVacant` Column

When looking at the Data most of the `SoldAsVacant` Column contained
‘yes’ or ‘no’, but there were a few ‘Y’ and ‘N’ mixed in.

``` r
# Change Y and N to Yes and No in "Sold as Vacant" Column
housing <- housing %>% 
  mutate(SoldAsVacant = ifelse(SoldAsVacant == 'Y', 'Yes', SoldAsVacant)) %>% 
  mutate(SoldAsVacant = ifelse(SoldAsVacant == 'N', 'No', SoldAsVacant))
```

### Populating Missing `PropertyAddress` from a Common `ParcelID`, using an InnerJoin. Removed any duplicates

There were a number of rows with missing `PropertyAddress` data. I was
able to do an InnerJoin with the same data and populate the missed
addresses from other rows that contained the same `ParcelID`. After the
missed data was populated I removed any duplicates.

``` r
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
```

### Splitting `PropertyAddress` & `OwnerAddress` into individual columns: Street, City, State

The initial data contained both the `PropertyAddress` & `OwnerAddress`
in a single column. By separating the data by Street, City, and State it
becomes more uniform in appearance and usable for analysis. Once the
columns were separated I changed any Blank or NULL Owner information to
‘N/A’

``` r
# Splitting Property Address into Individual Columns: Street, City
housing <- housing %>% 
  separate(PropertyAddress, into = c('PropertyStreet', 'PropertyCity'), sep = ',')

# Splitting Owner Address into Individual columns: Street, City, State
housing <- housing %>% 
  separate(OwnerAddress, into = c('OwnerStreet', 'OwnerCity', 'OwnerState'), sep = ',')

# Change any Blank or NA Owner Data to 'N/A'
housing <- housing %>%
  mutate(OwnerName = ifelse(OwnerName == '' | is.na(OwnerName) == TRUE, 'N/A', OwnerName)) %>% 
  mutate(OwnerStreet = ifelse(OwnerStreet == '' | is.na(OwnerStreet) == TRUE, 'N/A', OwnerStreet)) %>% 
  mutate(OwnerCity = ifelse(OwnerCity == '' | is.na(OwnerCity) == TRUE, 'N/A', OwnerCity)) %>% 
  mutate(OwnerState = ifelse(OwnerState == '' | is.na(OwnerState) == TRUE, 'N/A', OwnerState))
```

### Removing all Leading/Trailing whitespace from then entire `housing` dataframe, exporting to .CSV file.

The last step I took was to ensure there were no errant spaces within
the data columns. I trimmed all leading/trailing whitespace and then
exported the `housing` dataframe to a .CSV file for use with Excel or
SQL.

``` r
# Remove Any Leading/trailing Spaces from Entire Data Frame
housing <- housing %>% 
  mutate(across(where(is.character), str_trim))

# Export the Dataframe to CSV File
write_csv(housing, "~/Documents/Data-Analysis/Github/Portfolio-Projects/02-Data-Cleaning-in-R/Nashville-Housing-Data-CLEANED.csv")
```
