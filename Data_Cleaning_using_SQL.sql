use Portfolio_Project

/* cleaning data */
select * from Nashville_Housing

/* standardzing date format */
alter table Nashville_Housing /* changing dtype from datetime to date */
alter column SaleDate date


/* populating address where it equals null */
select *
from Nashville_Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

/* segregating property address into individual columns */
select PropertyAddress
from Nashville_Housing
--order by ParcelID

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from Nashville_Housing

alter table Nashville_Housing
add Property_Split_Address nvarchar(255)

update Nashville_Housing
set Property_Split_Address = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 

alter table Nashville_Housing
add Property_Split_City nvarchar(255)

update Nashville_Housing
set Property_Split_City = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) 


select OwnerAddress from Nashville_Housing
--where OwnerAddress is not null

select parsename(replace(OwnerAddress, ',', '.'), 1) as state, /* parsename only works with PERIOD  and it works backwards*/
parsename(replace(OwnerAddress, ',', '.'), 2) as city, 
parsename(replace(OwnerAddress, ',', '.'), 3) as address 
from Nashville_Housing

alter table Nashville_Housing
add Owner_Split_Address nvarchar(255)

update Nashville_Housing
set Owner_Split_Address = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table Nashville_Housing
add Owner_Split_City nvarchar(255)

update Nashville_Housing
set Owner_Split_City = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table Nashville_Housing
add Owner_Split_State nvarchar(255)

update Nashville_Housing
set Owner_Split_State = parsename(replace(OwnerAddress, ',', '.'), 1)


/* standarizing 'Sold as vacant' column */
select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Nashville_Housing


update Nashville_Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                   when SoldAsVacant = 'N' then 'No'
	               else SoldAsVacant
	               end



/* removing duplicates */
with row_num_CTE as(
select *,
row_number() over(
partition by ParcelID,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 order by UniqueID) row_num
from Nashville_Housing
--order by ParcelID
)

delete 
from row_num_CTE
where row_num > 1
--order by ParcelID


/* deletion of unused columns */
alter table Nashville_Housing
drop column PropertyAddress, OwnerAddress


