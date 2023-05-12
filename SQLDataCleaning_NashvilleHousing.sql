-- Data Cleaning Project
USE test_db;
SELECT *
FROM nashville_house

-- Changing the SaleDate column from string to desired date format
UPDATE nashville_house
SET SaleDate = date_format(STR_TO_DATE(SaleDate, '%M %d,%Y'), '%Y-%m-%d');

-- Populate Property Address Data
UPDATE nashville_house
SET PropertyAddress = NULLIF(PropertyAddress,'');

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_house a
JOIN nashville_house b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_house as a
JOIN nashville_house as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
    SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
    WHERE a.PropertyAddress IS NULL;

-- Breaking out Address Into Individual Columns
SELECT PropertyAddress
FROM nashville_house;

ALTER TABLE nashville_house
ADD Property_Address_Line VARCHAR(100),
ADD Property_Address_City VARCHAR(100);

UPDATE nashville_house
SET Property_Address_Line = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);
UPDATE nashville_house
SET Property_Address_City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress));

SELECT OwnerAddress
FROM nashville_house;

ALTER TABLE nashville_house
ADD Owner_Address_Line VARCHAR(100),
ADD Owner_Address_City VARCHAR(100),
ADD Owner_Address_State VARCHAR(100);

UPDATE nashville_house
SET Owner_Address_Line = SUBSTRING_INDEX(OwnerAddress, ',', 1);
UPDATE nashville_house
SET Owner_Address_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),',',1);
UPDATE nashville_house
SET Owner_Address_State = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- CHANGE Y and N to Yes and No in 'Sold as Vacant' field

 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
END
FROM nashville_house;

UPDATE nashville_house
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;
                    
-- REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY UniqueID
             ) row_num
FROM nashville_house
)
-- SELECT *
-- FROM RowNumCTE
-- -- WHERE row_num >1; 
DELETE FROM nashville_house
USING nashville_house 
JOIN RowNumCTE ON
nashville_house.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1; 

                    
-- Remove Unused Columns
SELECT * 
FROM nashville_house; 

ALTER TABLE nashville_house
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress; 



                   