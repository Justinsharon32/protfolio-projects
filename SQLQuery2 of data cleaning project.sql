select*
from [data cleanning project]..nashvilleHousing

--standanardize date format
select SaleDateconverted,CONVERT(date,SaleDate)
from [data cleanning project]..nashvilleHousing

alter table nashvilleHousing
add saledateconverted date;

update nashvilleHousing
set saledateconverted= CONVERT(date,saledate)

--property address data

select *
from [data cleanning project]..nashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from [data cleanning project]..nashvilleHousing a
join [data cleanning project]..nashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [data cleanning project]..nashvilleHousing a
join [data cleanning project]..nashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- breaking ADDRESS into indivisual column (address,city,state)
select PropertyAddress
from [data cleanning project]..nashvilleHousing

select 
SUBSTRING(propertyaddress,1,CHARINDEX(',', PropertyAddress)-1) as address
,SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))  as address

from [data cleanning project]..nashvilleHousing


alter table nashvilleHousing
add propertysplitaddress nvarchar(255);

update nashvilleHousing
set  propertysplitaddress = SUBSTRING(propertyaddress,1,CHARINDEX(',', PropertyAddress)-1)


alter table nashvilleHousing
add propertysplitcity nvarchar(255);

update nashvilleHousing
set  propertysplitcity = SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))

select*
from [data cleanning project]..nashvilleHousing

--owner address
select OwnerAddress
from [data cleanning project]..nashvilleHousing

select
PARSENAME(replace( OwnerAddress,',','.'),3),
PARSENAME(replace( OwnerAddress,',','.'),2),
PARSENAME(replace( OwnerAddress,',','.'),1)
from [data cleanning project]..nashvilleHousing

alter table nashvilleHousing
add ownersplitaddress nvarchar(255);

update nashvilleHousing
set  ownersplitaddress = PARSENAME(replace( OwnerAddress,',','.'),3)

alter table nashvilleHousing
add ownersplitcity nvarchar(255);

update nashvilleHousing
set  ownersplitcity =PARSENAME(replace( OwnerAddress,',','.'),2)


alter table nashvilleHousing
add ownersplitstate nvarchar(255);

update nashvilleHousing
set  ownersplitstate = PARSENAME(replace( OwnerAddress,',','.'),1)

--change Y and N to YES or NO in sold as vacant feild

select distinct(SoldAsVacant), COUNT(soldasvacant)
from [data cleanning project]..nashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' THEN 'YES'
     when SoldAsVacant='N' THEN 'NO'
	 else SoldAsVacant
END
from [data cleanning project]..nashvilleHousing

update nashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' THEN 'YES'
     when SoldAsVacant='N' THEN 'NO'
	 else SoldAsVacant
	 end

--remove duplicates and unused columns
with RowNumCTE as(
select*,
Row_number() over (
partition by parcelID,
              propertyaddress,
			  saleprice,
			  saledate,
			  legalreference
			  order by
			     uniqueID
				 )row_num

from [data cleanning project]..nashvilleHousing
)
select*
from RowNumCTE
where row_num > 1


--unused columns

select*
from [data cleanning project]..nashvilleHousing

alter table [data cleanning project]..nashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress

alter table [data cleanning project]..nashvilleHousing
drop column saledate
