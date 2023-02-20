--				LOOKING AT OUR DATA

SELECT *
FROM NashvilleHousing

--				CHANGING THE DATE FORMAT

SELECT SaleDate, CONVERT (date,SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

--				INFUSE PROPERtY ADRESS DATA 

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--				BREAKING A COLUMN WITH LOTS OF DATA INTO SEPERATE DATA COLUMNS

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,TRIM(SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+2, 50)) AS City
/* OR THIS WAY: */
--,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
,	PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

--ALTER TABLE NashvilleHousing
--DROP COLUMN PropertyAddress

--					ALTERNATIVE APPROACH

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress,OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

--				RENAMING 'BOOLEAN' DATA ('Y' and 'N' to 'Yes' and 'No')

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC

SELECT SoldAsVacant,
	CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	END

--				REMOVING DUPLICATES

WITH RowNumCTE AS 
(
	SELECT *, 
		ROW_NUMBER() OVER(
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num
	FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1

--				DELETING UNUSED COLUMNS

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,
			OwnerAddress