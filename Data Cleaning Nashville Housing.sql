/*
CLEANING DATA IN SQL QUERIES
*/
--------------------------------------------------------------------------------------
USE PortfolioProject
SELECT * FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------

--Standardize Date Format

SELECT Saledate, saledateconverted from NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

--------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b on
	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b on
	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------

--Breaking Out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress) ) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress) )


SELECT * 
FROM NashvilleHousing


SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(owneraddress, ',', '.'),3)
,PARSENAME(REPLACE(owneraddress, ',', '.'),2)
,PARSENAME(REPLACE(owneraddress, ',', '.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnersSplitAddress varchar(255)

UPDATE NashvilleHousing
SET OwnersSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnersSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnersSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnersSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnersSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'),1)

SELECT * FROM NashvilleHousing


--------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant field"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (	
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN Saledate