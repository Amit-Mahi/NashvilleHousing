
-- Cleaning Data In SQL Queries

SELECT * 
FROM Covid.dbo.NashvilleHousing


-- 1. Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Covid.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




-- 2. Populate Property Address Data

SELECT *
FROM Covid.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Covid.dbo.NashvilleHousing a
JOIN Covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Covid.dbo.NashvilleHousing a
JOIN Covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- check if the changes have been made
SELECT *
FROM Covid..NashvilleHousing
WHERE PropertyAddress is null




-- 3. Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Covid..NashvilleHousing
WHERE PropertyAddress is null

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Covid..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Covid..NashvilleHousing





SELECT OwnerAddress
FROM Covid..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM Covid..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)



SELECT *
FROM Covid..NashvilleHousing





-- 4. Change Y, N to Yes and No in "Sold Or Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Covid..NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Covid..NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Covid..NashvilleHousing




-- 5. Remove Duplicates 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Covid..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
where row_num > 1
--order by propertyAddress




--6. Delete Unused Columns


ALTER TABLE Covid..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Covid..NashvilleHousing
DROP COLUMN SaleDate


SELECT * 
FROM Covid.dbo.NashvilleHousing