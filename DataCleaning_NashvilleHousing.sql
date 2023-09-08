-- Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing 
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date ;

UPDATE PortfolioProject..NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE, SaleDate) 


-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking Out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress)) AS Address
--, LEN(PropertyAddress)
--, CHARINDEX(',', PropertyAddress) +1
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress NVarChar(255) ;

UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
Add PropertySplitCity NVarChar(255); 

UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress)) 


SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressCity NVarchar(50)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerAddressCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddressCity
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressStreet NVarchar(255)

UPDATE NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

SELECT OwnerAddressStreet
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerAddressState NVarChar(100)

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

SELECT OwnerAddressState 
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress, OwnerAddressCity, OwnerAddressState, OwnerAddressStreet
FROM PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
order by 2


SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


--REMOVE DUPLICATES 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() 	OVER 
	(PARTITION BY	ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY 
									UniqueID
									) row_num 

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- DELETE UNUSED COLUMNS


SELECT *
FROM PortfolioProject..NashvilleHousing  

ALTER TABLE PortfolioProject..NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing 
DROP COLUMN SaleDate


