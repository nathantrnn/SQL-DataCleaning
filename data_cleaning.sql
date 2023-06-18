/*
Cleaning Data in SQL Queries
*/

-- Retrieve all data from NashvilleHousing table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Retrieve SaleDate column and convert it to date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

-- Update SaleDate column in NashvilleHousing table to standardized date format
UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- Retrieve all data from NashvilleHousing table ordered by ParcelID
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID;

-- Retrieve PropertyAddress data from NashvilleHousing table where PropertyAddress is NULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress in NashvilleHousing table with non-null values from matching ParcelID
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Retrieve PropertyAddress from NashvilleHousing table
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;
--Where PropertyAddress is null
--order by ParcelID

-- Split PropertyAddress into Address and City columns
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing;

-- Add PropertySplitAddress column to NashvilleHousing table and populate it with the Address part of PropertyAddress
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- Update PropertySplitAddress column with the Address part of PropertyAddress
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

-- Add PropertySplitCity column to NashvilleHousing table and populate it with the City part of PropertyAddress
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitCity column with the City part of PropertyAddress
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

-- Clean OwnerAddress
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

-- Split OwnerAddress into Address, City, and State columns
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
       PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
       PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM PortfolioProject.dbo.NashvilleHousing;

-- Add OwnerSplitAddress column to NashvilleHousing table and populate it with the Address part of OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress column with the Address part of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

-- Add OwnerSplitCity column to NashvilleHousing table and populate it with the City part of OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity column with the City part of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

-- Add OwnerSplitState column to NashvilleHousing table and populate it with the State part of OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState column with the State part of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- Trim extra spaces in PropertySplitAddress
UPDATE NashvilleHousing
SET PropertySplitAddress = REPLACE(TRIM(PropertySplitAddress), '  ', ' ');

-- Trim extra spaces in OwnerSplitAddress
UPDATE NashvilleHousing
SET OwnerSplitAddress = REPLACE(TRIM(OwnerSplitAddress), '  ', ' ');

-- Trim extra spaces in OwnerSplitCity
UPDATE NashvilleHousing
SET OwnerSplitCity = REPLACE(TRIM(OwnerSplitCity), '  ', ' ');

-- Trim extra spaces in OwnerSplitState
UPDATE NashvilleHousing
SET OwnerSplitState = REPLACE(TRIM(OwnerSplitState), '  ', ' ');

-- Trim extra spaces in PropertySplitCity
UPDATE NashvilleHousing
SET PropertySplitCity = REPLACE(TRIM(PropertySplitCity), '  ', ' ');


-- Retrieve all data from NashvilleHousing table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY SalePrice;

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Count the distinct values in SoldAsVacant column
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Replace Y and N values in SoldAsVacant column with Yes and No, respectively
SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvilleHousing;

-- Update SoldAsVacant column with Yes and No values
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                   END;

---------------------------------------------------------------------------------------------------------------------------
-- Remove commas and dollar signs from the SalePrice column
UPDATE NashvilleHousing
SET SalePrice = REPLACE(REPLACE(SalePrice, ',', ''), '$', '');
-- The nested REPLACE functions remove commas and dollar signs from the SalePrice values

-- Convert the SalePrice column to an integer data type
ALTER TABLE NashvilleHousing
ALTER COLUMN SalePrice INT;
-- The ALTER TABLE statement modifies the data type of the SalePrice column to INT

---------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Identify and retrieve duplicate rows based on specific columns
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM PortfolioProject.dbo.NashvilleHousing
    --order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Retrieve all data from NashvilleHousing table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY SalePrice

---------------------------------------------------------------------------------------------------------

/* Delete Unused Columns
-- Retrieve all data from NashvilleHousing table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- Drop unused columns from NashvilleHousing table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
*/
