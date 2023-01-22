# Cleaning Data with sql queries

SELECT * FROM nashvile_housing.housing_data;  
SET SQL_SAFE_UPDATES = 0;

# Replace empty cell with Null
SELECT * FROM housing_data WHERE housing_data.PropertyAddress = '';

UPDATE housing_data 
SET PropertyAddress= NULLIF(PropertyAddress,''),
	housing_data.OwnerAddress= NULLIF(housing_data.OwnerAddress,''),
    housing_data.OwnerName = nullif(housing_data.OwnerName,''),
    housing_data.TaxDistrict = nullif(housing_data.TaxDistrict,'');

SELECT * FROM housing_data where PropertyAddress iS NULL;

# Replace the NULL with address to the property address.
# HERE, some of parcelIDs and owners are similar but the uniqueID is different, by using  IFNULL() function propertyAddress can be replaced

SELECT * FROM housing_data where PropertyAddress iS NULL;

SELECT IFNULL(ax.PropertyAddress,ay.PropertyAddress)
FROM housing_data ax
JOIN housing_data ay
ON ax.ParcelID = ay.ParcelID 
AND ax.UniqueID <> ay.UniqueID
WHERE ax.PropertyAddress is NULL;

UPDATE housing_data as ax
JOIN housing_data ay
ON ax.ParcelID = ay.ParcelID 
AND ax.UniqueID <> ay.UniqueID
SET ax.PropertyAddress=  IFNULL(ax.PropertyAddress,ay.PropertyAddress)
WHERE ax.PropertyAddress is NULL;

# Breaking out the property address column

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, POSITION(',' in PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, POSITION(',' in PropertyAddress)+1, LENGTH(PropertyAddress)) as Address
FROM housing_data;

ALTER TABLE housing_data
ADD Property_Address_street VARCHAR(255);

ALTER TABLE housing_data
ADD property_Address_City VARCHAR(255);

UPDATE housing_data
SET Property_Address_street = SUBSTRING(PropertyAddress, 1, POSITION(',' in PropertyAddress)-1),
	Property_Address_city = SUBSTRING(PropertyAddress, POSITION(',' in PropertyAddress)+1, LENGTH(PropertyAddress));

# Check for the OwnerAddress
SELECT OwnerAddress FROM housing_data;

SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM housing_data;

ALTER TABLE housing_data
ADD OwnerAddress_street VARCHAR(255);

ALTER TABLE housing_data
ADD OwnerAddress_city VARCHAR(255);

ALTER TABLE housing_data
ADD OwnerAddress_state VARCHAR(255);

UPDATE housing_data
SET OwnerAddress_street= SUBSTRING_INDEX(OwnerAddress, ',', 1),
	OwnerAddress_city = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerAddress_state = SUBSTRING_INDEX(OwnerAddress, ',', -1);

# CONVERT N and Y to NO and YES IN SoldAsVacant field

SELECT DISTINCT(SoldAsVacant)
FROM housing_data;

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM housing_data;

UPDATE housing_data
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

# DELETE duplicate Data

# How to find Duplicate entries

SELECT *,
	row_number() over (
    partition by ParcelID,
				 LandUse,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY
                 UniqueID) AS Row_num
FROM housing_data;

# TO see the duplicate rows
SELECT *
FROM (SELECT *,
	row_number() over (
    partition by ParcelID,
				 LandUse,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY
                 UniqueID) AS Row_num
FROM housing_data) AS TEMP
WHERE Row_num > 1;
    
    
# Delete Duplicate rows

DELETE FROM housing_data where UniqueID in(SELECT UniqueID
FROM (SELECT *,
	row_number() over (
    partition by ParcelID,
				 LandUse,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY
                 UniqueID) AS Row_num
FROM housing_data) AS TEMP
WHERE Row_num > 1);

# DELETE unused columns

ALTER TABLE housing_data
DROP PropertyAddress,
DROP TaxDistrict,
DROP OwnerAddress,
DROP SaleDate;