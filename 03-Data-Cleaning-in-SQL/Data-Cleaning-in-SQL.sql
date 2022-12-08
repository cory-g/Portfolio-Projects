/*
	Cleaning Data with SQL Queries

*/


-- Format Datetime to Date
ALTER TABLE	Data_Cleaning..nashville_housing
ALTER COLUMN	SaleDate DATE;


-- Alt Method, Add New Column with Converted Data
ALTER TABLE	Data_Cleaning..nashville_housing
ADD		SaleDateConverted DATE;

UPDATE		Data_Cleaning..nashville_housing
SET		SaleDateConverted = CONVERT(DATE, SaleDate);


-------------------------------------------------------------------------


-- Populate Property Address Data Where NULL
UPDATE	A
SET	PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM	Data_Cleaning..nashville_housing AS A
JOIN	Data_Cleaning..nashville_housing AS B
		ON	A.ParcelID = B.ParcelID
			AND	A.[UniqueID ] <> B.[UniqueID ]
WHERE	A.PropertyAddress IS NULL;


--------------------------------------------------------------------------


-- Remove Duplicates
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


--------------------------------------------------------------------------


-- Changing Address into Individual Columns (Address, City, State)
ALTER TABLE	Data_Cleaning..nashville_housing
ADD		Property_Street Nvarchar(255),
		Property_City Nvarchar(255);

UPDATE		Data_Cleaning..nashville_housing
SET		Property_Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
		Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--Spilt Owner Address
ALTER TABLE	Data_Cleaning..nashville_housing
ADD		Owner_Street Nvarchar(255),
		Owner_City Nvarchar(255),
		Owner_State Nvarchar(255);

UPDATE		Data_Cleaning..nashville_housing
SET		Owner_Street = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


--------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" Column
UPDATE	Data_Cleaning..nashville_housing
SET	SoldAsVacant = CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
				ELSE SoldAsVacant
				END;


--------------------------------------------------------------------------


-- Change Owner Information from NULL to N/A
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


--------------------------------------------------------------------------


-- Remove Extra Spaces from Data
UPDATE	Data_Cleaning..nashville_housing
SET	Owner_State = TRIM(Owner_State)


--------------------------------------------------------------------------


-- Delete Unused Columns
ALTER TABLE 	Data_Cleaning..nashville_housing
DROP COLUMN	PropertyAddress, OwnerAddress


-------------------------------------------------------------------------
