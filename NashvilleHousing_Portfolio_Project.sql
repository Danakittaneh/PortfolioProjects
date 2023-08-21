/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------

--Standarize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_Project.DBO.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM Portfolio_Project..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing A
JOIN Portfolio_Project..NashvilleHousing B
 ON A.ParcelID = B.ParcelID
 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing A
JOIN Portfolio_Project..NashvilleHousing B
 ON A.ParcelID = B.ParcelID
 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------

--Breaking out Adress into individual columns(Adress,City,State)

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Adress
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

--SELECT *
--FROM Portfolio_Project..NashvilleHousing



SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Portfolio_Project..NashvilleHousing




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--SELECT *
--FROM Portfolio_Project..NashvilleHousing

-----------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END
FROM Portfolio_Project..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END


-------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS (SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelId,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			  UniqueID
			  ) Row_Num
FROM Portfolio_Project..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1


--SELECT * 
--FROM RowNumCTE
--WHERE Row_Num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------------------

--Delete Unuesd Columns

SELECT *
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict,SaleDate


