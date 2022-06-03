


/*
Cleaning Data in SQL Queries



*/
SELECT *
FROM NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 




-- If it doesn't Update properly

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL







--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress) ) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE  NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE  NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress) )

SELECT *
FROM NashvilleHousing





SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE  NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE  NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE  NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
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



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY 
			       UniqueID
				   ) AS row_num
FROM NashvilleHousing
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num >1

DELETE 
FROM RowNumCTE
WHERE row_num >1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN  OwnerAddress



















