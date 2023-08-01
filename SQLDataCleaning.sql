/*
Cleaning Data in SQL Queries
*/
select * 
from PortfolioProject..NashvilleHousing

---Standardize Date Format
alter table NashvilleHousing 
add SalesDateConverted Date;

update NashvilleHousing
set SalesDateConverted = convert(Date,SaleDate)

---Populate Property Address data

/* By closely examining the dataset, it's clear that the same parcelIDs has the same property address. Therefore, all the fields with 
property address value NULL can be filled with the property address value of a same parcelID on a different raw/rows
*/

--List of all rows with PoppertyAddress value as NULL in table a is displayed

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--NULL values in a.PropertyAddress is replaced with values in b.PropertyAddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


---Breaking out Address into Individual Columns(Address,City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing 

select substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) As address,
substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) As address
from PortfolioProject..NashvilleHousing 


--Creating columns after splitting the address:

select PropertyAddress
from PortfolioProject..NashvilleHousing 


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---Using the 'parsename' function to split the values in the 'OwnerAddress' column

select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

 Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing


---order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--- Delete Unused Columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


