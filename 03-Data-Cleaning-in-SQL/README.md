Cleaning & Manipulating Raw Data in SQL
================
Cory Gargan
2022-12-08

# Cleaning a Raw Dataset for further Analysis

#### I took this raw dataset containing Nashville housing data and made it clean and usable. I made responses consistent, columns more search & sort friendly, and populated any missing property addresses.

### Changing `SaleDate` Format to YYYY-MM-DD

The original `SaleDate` column was in type DateTime.  
  
- Originally: 2022-05-24 00:00:00
  - Formated to: 2022-05-24

```
ALTER TABLE	Data_Cleaning..nashville_housing
ALTER COLUMN	SaleDate DATE;
```

### Standardized data: Y and N changed to Yes and No in `SoldAsVacant` Column

When looking at the Data most of the `SoldAsVacant` Column contained
‘yes’ or ‘no’, but there were a few ‘Y’ and ‘N’ mixed in.

``` sql
# Change Y and N to Yes and No in SoldAsVacant Column
UPDATE	Data_Cleaning..nashville_housing
SET	SoldAsVacant = CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
				ELSE SoldAsVacant
				END;
```

### Populating Missing `PropertyAddress` from a Common `ParcelID`, using an InnerJoin. Removed any duplicates

There were a number of rows with missing `PropertyAddress` data. I was
able to do an InnerJoin with the same data and populate the missed
addresses from other rows that contained the same `ParcelID`. After the
missed data was populated I removed any duplicates.

``` sql
# Populate Missing Property Address From Common ParcelID
UPDATE	A
SET	PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM	Data_Cleaning..nashville_housing AS A
JOIN	Data_Cleaning..nashville_housing AS B
		ON	A.ParcelID = B.ParcelID
			AND	A.[UniqueID ] <> B.[UniqueID ]
WHERE	A.PropertyAddress IS NULL;

# Remove Duplicates
WITH rowNumCTE AS(
SELECT	*,
	ROW_NUMBER() OVER (
	PARTITION BY 	ParcelID,
			PropertyAddress,
	 	 	SalePrice,
			SaleDate,
			LegalReference
	ORDER BY UniqueID
				) AS row_num
FROM	Data_Cleaning..nashville_housing
)
DELETE
FROM	rowNumCTE
WHERE	row_num > 1
```

### Splitting `PropertyAddress` & `OwnerAddress` into individual columns: Street, City, State

The initial data contained both the `PropertyAddress` & `OwnerAddress`
in a single column. By separating the data by Street, City, and State it
becomes more uniform in appearance and usable for analysis. Once the
columns were separated I changed any Blank or NULL Owner information to
‘N/A’

``` sql
# Splitting Property Address into Individual Columns: Street, City
ALTER TABLE	Data_Cleaning..nashville_housing
ADD		Property_Street Nvarchar(255),
		Property_City Nvarchar(255);

UPDATE		Data_Cleaning..nashville_housing
SET		Property_Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
		Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

# Splitting Owner Address into Individual columns: Street, City, State
ALTER TABLE	Data_Cleaning..nashville_housing
ADD		Owner_Street Nvarchar(255),
		Owner_City Nvarchar(255),
		Owner_State Nvarchar(255);

UPDATE		Data_Cleaning..nashville_housing
SET		Owner_Street = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

# Change any Blank or NA Owner Data to 'N/A'
UPDATE	Data_Cleaning..nashville_housing
SET		OwnerName = CASE	WHEN OwnerName IS NULL THEN 'N/A'
					ELSE OwnerName
					END,
		Owner_Street =	CASE	WHEN Owner_Street IS NULL THEN 'N/A'
					ELSE Owner_Street
					END,
		Owner_City =	CASE	WHEN Owner_City IS NULL THEN 'N/A'
					ELSE Owner_City
					END,
		Owner_State =	CASE	WHEN Owner_State IS NULL THEN 'N/A'
					ELSE Owner_State
					END;
```

### Removing all Leading/Trailing whitespace

The last step I took was to ensure there were no errant spaces within
the data columns. I trimmed all leading/trailing whitespace.

``` sql
# Remove Any Leading/trailing Spaces from Entire Data Frame
UPDATE	Data_Cleaning..nashville_housing
SET	Owner_State = TRIM(Owner_State)
```
