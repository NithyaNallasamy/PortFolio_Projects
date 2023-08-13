use PortfolioProject;


-- Standardize Date Format

--SaleDate columns had Timestamp as well

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);


-- Populate Property Address data

-- some of the items were NULL in the PropertyAddress with which we can populate with reference values from the table

Select * from NasvilleHousing;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousing a
join NasvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL;

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousing a
join NasvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL;

-----------------------------------------------------------------------------------

--Breaking Out the address into individual columns

-- PropertyAddress and OwnerAddress Columns had data which is not usuable or not in a standardized formart.

Select PropertyAddress
from NasvilleHousing;

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1 ) as SplitAddress
from NasvilleHousing;

select SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as SplitCity
from NasvilleHousing;

ALTER TABLE NasvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NasvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1 );

ALTER TABLE NasvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 
from NasvilleHousing;

Select * from NasvilleHousing;

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NasvilleHousing;

ALTER TABLE NasvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NasvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NasvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NasvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
from NasvilleHousing;

ALTER TABLE NasvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NasvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from NasvilleHousing;


-----------------------------------------------------------------------------------

--change 'Y'and 'N'to 'Yes' and 'No' in the SoldAsVacant Field


Select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NasvilleHousing
group by SoldAsVacant
order by 2 DESC;

Select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end
from NasvilleHousing;


UPDATE NasvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end;

--------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
	   ROW_NUMBER() over(
	   partition by ParcelID,
					SalePrice,
					LegalReference
					order By 
						UniqueID DESC
						) row_num
From  NasvilleHousing
--Order by ParcelID;
)
SELECT *
from RowNumCTE
where row_num > 1
order by PropertyAddress;


--------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NasvilleHousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict;

Select * from NasvilleHousing;