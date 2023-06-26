---------------------------------------------------------------------------------------------
--Portfolio Project 2 Data Cleaning in SQL



---------------------------------------------------------------------------------------------
-- Creating the Table

CREATE TABLE PortfolioProject2.NashvilleHousingData (
 UniqueID VARCHAR(255),
 ParcelID VARCHAR(255),
 LandUse VARCHAR(255),
 PropertyAddress VARCHAR(255),
 SaleDate DATETIME,
 SalePrice VARCHAR(255),
 LegalReference VARCHAR(255),
 SoldAsVacant VARCHAR(255),
 OwnerName VARCHAR(255),
 OwnerAddress VARCHAR(255),
 Acreage VARCHAR(255),
 TaxDistrict VARCHAR(255),
 LandValue VARCHAR(255),
 BuildingValue VARCHAR(255),
 TotalValue VARCHAR(255),
 YearBuilt VARCHAR(255),
 Bedrooms VARCHAR(255),
 FullBath VARCHAR(255),
 HalfBath VARCHAR(255)
);




---------------------------------------------------------------------------------------------
-- Importing the data from the CSV file

LOAD DATA INFILE 'NashvilleHousingData.csv'
INTO TABLE PortfolioProject2.NashvilleHousingData
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



---------------------------------------------------------------------------------------------
-- Validate the data import by counting the rows and comparing it to Excel

SELECT COUNT(*)
FROM NashvilleHousingData

/*
The count of rows is the same as in Excel (56477) 
*/



---------------------------------------------------------------------------------------------
-- Viewing the data for the first time in SQL

SELECT *
FROM NashvilleHousingData
LIMIT 100





---------------------------------------------------------------------------------------------
-- Changing the Date format

/* 
This code didn't allow converting of the data. So instead we created a new column in the table
with the required data type and copied the data in.

SELECT SaleDate, CONVERT(SaleDate,DATE)
FROM NashvilleHousingData
LIMIT 100 

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(SaleDate,DATE)

*/

ALTER TABLE `NashvilleHousingData` 
	ADD SaleDateConverted DATE;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(SaleDate,DATE)

/* Or you could have used the CHANGE Function below to change the original column */

ALTER TABLE `NashvilleHousingData` 
	CHANGE `SaleDate` `SaleDate` date 



---------------------------------------------------------------------------------------------
--  Populate Property address Data

/* 
This code joins the table onto itself and allows to populate the property address if there
are any missing entries.
*/

SELECT *
FROM PortfolioProject2.NashvilleHousingData
ORDER BY ParcelID

SELECT *
FROM NashvilleHousingData A
JOIN NashvilleHousingData B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> b.UniqueID
LIMIT 1000

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM NashvilleHousingData A
JOIN NashvilleHousingData B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> b.UniqueID
WHERE A.PropertyAddress is NULL
LIMIT 1000

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousingData A
JOIN NashvilleHousingData B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> b.UniqueID
WHERE A.PropertyAddress is NULL
LIMIT 1000

UPDATE A
SET Propertyaddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousingData A
JOIN NashvilleHousingData B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> b.UniqueID
WHERE A.PropertyAddress is NULL


/* I don't know why but my data didn't actually contain any NULL values */






---------------------------------------------------------------------------------------------
-- Breaking out the address into Individual Columns (address, City, State)

SELECT PropertyAddress 
FROM NashvilleHousingData

SELECT SUBSTRING_INDEX(PropertyAddress,',',1) AS Address
FROM NashvilleHousingData

SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)) AS Address
FROM NashvilleHousingData


/* The code below will show the position number of ',' */

SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)) AS Address,
POSITION(',' IN PropertyAddress)
FROM NashvilleHousingData


/* Then run the original code with '-1' to remove the ',' */

SELECT 
    SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) AS Address1
FROM NashvilleHousingData

/* and with '+1' for the second part of the data */

SELECT 
    SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) AS Address1
,    SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1) AS Address2
FROM NashvilleHousingData



/* Now to add two new columns with the address broken up between Street and City */


ALTER TABLE `NashvilleHousingData` 
	ADD PropertySplitStreet VARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitStreet = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1)

ALTER TABLE `NashvilleHousingData` 
	ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1)




/* 
Whereas the Propertyaddress column only contained Street and City the OwnerAddress column contains Street, City
and State. So let's work on that one now...
 */

SELECT OwnerAddress  
FROM NashvilleHousingData
LIMIT 1000


SELECT
SUBSTRING_INDEX(OwnerAddress,',',1) AS AddressStreet,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',', -1) AS AddressCity,
SUBSTRING_INDEX(OwnerAddress,',',-1) AS AddressState
FROM NashvilleHousingData
LIMIT 1000


/* Add the new columns to the table and update the data */


ALTER TABLE `NashvilleHousingData` 
	ADD OwnerSplitStreet VARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitStreet = SUBSTRING_INDEX(OwnerAddress,',',1)

ALTER TABLE `NashvilleHousingData` 
	ADD OwnerSplitCity VARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',', -1)

ALTER TABLE `NashvilleHousingData` 
	ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1)


SELECT OwnerSplitStreet, PropertySplitStreet, OwnerSplitCity, PropertySplitCity, OwnerSplitState   
FROM NashvilleHousingData
LIMIT 1000



---------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END




---------------------------------------------------------------------------------------------
-- Remove Duplicates

/* Using a CTE */

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY
                        UniqueID
                        ) AS ROW_NUM
FROM NashvilleHousingData)

DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress
LIMIT 1000




/* The method above uses a CTE however it's not possible to directly delete rows using a CTE and DELETE Function.
Instead we will create a subquery. */

DELETE FROM NashvilleHousingData
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) AS ROW_NUM
        FROM NashvilleHousingData
        ) AS Subquery
        WHERE ROW_NUM > 1
    );


/* Check for duplicate entries! None found! */

SELECT UniqueID
FROM (
    SELECT UniqueID,
    ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) AS ROW_NUM
        FROM NashvilleHousingData
        ) AS Subquery
WHERE ROW_NUM > 1







---------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN SaleDate

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress

ALTER TABLE NashvilleHousingData
DROP COLUMN TaxDistrict

ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress





---------------------------------------------------------------------------------------------
-- Update NULL VALUES in OwnerSplitCity and OwnerSplitState and OwnerSplitSteet

SELECT OwnerSplitStreet, PropertySplitStreet, OwnerSplitCity, PropertySplitCity, OwnerSplitState   
FROM NashvilleHousingData
ORDER BY OwnerSplitStreet DESC
LIMIT 1000

SELECT OwnerSplitStreet, PropertySplitStreet
FROM NashvilleHousingData
WHERE OwnerSplitStreet <> PropertySplitStreet
LIMIT 1000

UPDATE NashvilleHousingData
SET OwnerSplitStreet = PropertySplitStreet

UPDATE NashvilleHousingData
SET OwnerSplitCity= PropertySplitCity



