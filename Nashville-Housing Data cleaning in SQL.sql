/*
Cleaning Data in SQL
*/

SELECT *
FROM PortfolioProject..[Nashville-Housing]

/*
Standardizing Date Format
*/

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..[Nashville-Housing] 

ALTER TABLE [Nashville-Housing]
ADD SaleDateConverted Date;

UPDATE [Nashville-Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..[Nashville-Housing] 


--Populate Property Adress Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS PA
FROM PortfolioProject..[Nashville-Housing] a
JOIN PortfolioProject..[Nashville-Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..[Nashville-Housing] a
JOIN PortfolioProject..[Nashville-Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS PA
FROM PortfolioProject..[Nashville-Housing] a
JOIN PortfolioProject..[Nashville-Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL --Now there Are no NULL values in dublicate PropertyAddress


--Breaking out Address into Individual Columns (Address, City, State)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..[Nashville-Housing] 

ALTER TABLE [Nashville-Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville-Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville-Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville-Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..[Nashville-Housing] 



SELECT OwnerAddress
FROM PortfolioProject..[Nashville-Housing] 


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3), --PARSENAME only use '.' to as dilaimeter so we replace ',' with '.'
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject..[Nashville-Housing] 


ALTER TABLE [Nashville-Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville-Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Nashville-Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville-Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Nashville-Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville-Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM PortfolioProject..[Nashville-Housing]


--Change Y and N to Yes And NO in "Sold as Vacant" feild

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[Nashville-Housing]
Group BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM PortfolioProject..[Nashville-Housing]


UPDATE [Nashville-Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[Nashville-Housing]
Group BY SoldAsVacant
ORDER BY 2



-- Remove Dublicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM PortfolioProject..[Nashville-Housing]
Order BY ParcelID


WITH RowNum AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM PortfolioProject..[Nashville-Housing]) 
DELETE
FROM RowNum
WHERE row_num > 1


WITH RowNum AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM PortfolioProject..[Nashville-Housing]) 
SELECT * -- Just to check rows are deleted or not
FROM RowNum
WHERE row_num > 1


-- Delete unused columns

SELECT*
FROM PortfolioProject..[Nashville-Housing]

ALTER TABLE PortfolioProject..[Nashville-Housing]
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE PortfolioProject..[Nashville-Housing]
DROP COLUMN SaleDate