/*

Cleaning Data in SQL Queries

*/

SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio_Projects].[dbo].[NashvilleHousing]

  select *
  from Portfolio_Projects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

  
Select saleDateConverted, CONVERT(Date,SaleDate)
From Portfolio_Projects.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
from Portfolio_Projects.dbo.NashvilleHousing

Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Projects.dbo.NashvilleHousing a
JOIN Portfolio_Projects.dbo.NashvilleHousing b
    on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Projects.dbo.NashvilleHousing a
JOIN Portfolio_Projects.dbo.NashvilleHousing b
    on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <>  b.[UniqueID ]
where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Portfolio_Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;


select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From Portfolio_Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant),Count(SoldasVacant)
From Portfolio_Projects.dbo.NashvilleHousing
Group by SoldasVacant
Order by SoldasVacant


Select SoldasVacant
, CASE when SoldasVacant = 'Y' THEN 'Yes'
       when SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END
From Portfolio_Projects.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldasVacant=CASE when SoldasVacant = 'Y' THEN 'Yes'
       when SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
     ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
					UniqueID
					)row_num

From Portfolio_Projects.dbo.NashvilleHousing
)		
Select *
From RowNumCTE
where row_num>1
Order by PropertyAddress

Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Portfolio_Projects.dbo.NashvilleHousing


ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

