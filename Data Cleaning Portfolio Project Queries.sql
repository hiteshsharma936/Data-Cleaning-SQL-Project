----------------------------------------------------------------------------------------------------------------
                                           --DATA CLEANING PROJECT--

----------------------------------------------------------------------------------------------------------------
--Selecting the data

select * from [sqlproj].[dbo].[Nashville Housing Data]

-----------------------------------------------------------------------------------------------------------------
-- Populate PropertyAddress data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
from [sqlproj].[dbo].[Nashville Housing Data] a join
[sqlproj].[dbo].[Nashville Housing Data] b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null
 
update a 
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [sqlproj].[dbo].[Nashville Housing Data] a join 
[sqlproj].[dbo].[Nashville Housing Data] b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Columns(Address,City)

 select 
 Substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
 Substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
 from [sqlproj].[dbo].[Nashville Housing Data]

alter table [sqlproj].[dbo].[Nashville Housing Data]
add PropertysplitAddress Nvarchar(255);

update [sqlproj].[dbo].[Nashville Housing Data]
set PropertysplitAddress = Substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table [sqlproj].[dbo].[Nashville Housing Data]
add PropertySpCity Nvarchar(255);

update [sqlproj].[dbo].[Nashville Housing Data]
set PropertySpCity = Substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

---------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Columns(Address,City,State)

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2), 
PARSENAME(replace(OwnerAddress,',','.'),1) from [sqlproj].[dbo].[Nashville Housing Data]

alter table [sqlproj].[dbo].[Nashville Housing Data]
add OwnerSplitAddress Nvarchar(255);

update  [sqlproj].[dbo].[Nashville Housing Data]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table  [sqlproj].[dbo].[Nashville Housing Data]
add OwnerSplitCity Nvarchar(255);

update [sqlproj].[dbo].[Nashville Housing Data]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table  [sqlproj].[dbo].[Nashville Housing Data]
add OwnerSplitState Nvarchar(255);

update  [sqlproj].[dbo].[Nashville Housing Data]
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes AND NO in 'SoldAsVacant' Field

 select distinct(SoldAsVacant), count(SoldAsVacant)
 from [sqlproj].[dbo].[Nashville Housing Data]
 group by SoldAsVacant

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'NO'
	   else SoldAsVacant
	   end
 from [sqlproj].[dbo].[Nashville Housing Data]

 update [sqlproj].[dbo].[Nashville Housing Data]
 set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'NO'
	   else SoldAsVacant
	   end 
------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
select *,
     ROW_NUMBER() over (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  Saleprice,
				  Saledate,
				  LegalReference
				  ORDER BY 
				       UniqueID
					   ) row_num
from  [sqlproj].[dbo].[Nashville Housing Data]
)

delete
from RowNumCTE
where row_num >1

---------------------------------------------------------------------------------------------------------------
-- Drop Unused Columns

alter table [sqlproj].[dbo].[Nashville Housing Data]
drop column OwnerAddress,TaxDistrict,PropertyAddress











