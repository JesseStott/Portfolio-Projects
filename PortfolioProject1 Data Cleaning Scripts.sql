SELECT *
FROM [Portfolio Project 1]..NashvilleHousing;

--Standardizing Date Format

SELECT SaleDateConverted
FROM [Portfolio Project 1]..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

---------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM [Portfolio Project 1]..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 1]..NashvilleHousing a
JOIN [Portfolio Project 1]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 1]..NashvilleHousing a
JOIN [Portfolio Project 1]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-----------------------------------------------------------------------

-- Separating the Address into Address, City, State

SELECT PropertyAddress
FROM [Portfolio Project 1]..NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project 1]..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT *
FROM [Portfolio Project 1]..NashvilleHousing;

SELECT OwnerAddress
FROM [Portfolio Project 1]..NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
FROM [Portfolio Project 1]..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1);

---------------------------------------------------------------------

-- Changing Y and N to Yes and No in Sold as Vacant

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM [Portfolio Project 1]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [Portfolio Project 1]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-------------------------------------------------------------

--Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
FROM [Portfolio Project 1]..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY ParcelID;

----------------------------------------------

-- Deleting Unused Columns

ALTER TABLE [Portfolio Project 1]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT * 
FROM [Portfolio Project 1]..NashvilleHousing;