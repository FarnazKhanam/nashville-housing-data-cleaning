-- SELECTING DATABASE
USE farnazdb;

----------- DATA CLEANING ON
SELECT * 
FROM nashvillehousing;

----------- STANDARDIZE DATE FORMAT
SELECT SaleDate, DATE(SaleDate) AS SaleDateConverted
 FROM nashvillehousing;
 
 ALTER TABLE nashvillehousing
 ADD SaleDateConverted Date;
 
 UPDATE nashvillehousing
 SET SaleDateConverted = DATE(SaleDate);
 
 
 -------------- POPULATE PROPERTY ADDRESS_DATA
 
 SELECT * 
 FROM nashvillehousing
 -- WHERE PropertyAddress IS NULL;
 ORDER BY ParcelID;
 
 ----------------- WHERE PROPERY ADDRESS IS NULL.
 SELECT 
  NH1.ParcelID
 ,NH1.PropertyAddress
 ,NH2.ParcelID
 ,NH2.PropertyAddress
 ,IFNULL(NH1.PropertyAddress,NH2.PropertyAddress)
 FROM nashvillehousing NH1
 JOIN nashvillehousing NH2
 ON NH1.ParcelID = NH2.ParcelID
 AND NH1.UniqueID <> NH2.UniqueID
 WHERE NH1.PropertyAddress IS NULL;
 
 -------------------- UPDATING NULL ADDRESS 
 
UPDATE nashvillehousing NH1
 JOIN nashvillehousing NH2
 ON NH1.ParcelID = NH2.ParcelID
 AND NH1.UniqueID <> NH2.UniqueID
SET NH1.PropertyAddress = IFNULL(NH1.PropertyAddress,NH2.PropertyAddress)
WHERE NH1.PropertyAddress IS NULL;


---------------- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY)

 /*SELECT PropertyAddress,SUBSTRING_INDEX(PropertyAddress,",",1) AS Address
 ,SUBSTRING_INDEX(PropertyAddress,",",-1) AS City
 FROM nashvillehousing; */
 
  ALTER TABLE nashvillehousing
 ADD PropertySplitAddress Varchar(255);
 
 UPDATE nashvillehousing
 SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress,",",1);
 
 ALTER TABLE nashvillehousing
 ADD PropertySplitCity Varchar(255);
 
 UPDATE nashvillehousing
 SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress,",",-1);
 
 
 -------- Change Y and N to Yes and No in 'Sold as Vacant' field.
 SELECT DISTINCT(SoldAsVacant)
 ,COUNT(SoldAsVacant)
 FROM nashvillehousing
 GROUP BY SoldAsVacant
 ORDER BY 2;
 
 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = "Y" THEN "Yes"
        WHEN SoldAsVacant = "N" THEN "No"
        ELSE SoldAsVacant
   END
        FROM nashvillehousing ;
        
 UPDATE nashvillehousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN "Yes"
        WHEN SoldAsVacant = "N" THEN "No"
        ELSE SoldAsVacant
   END;
   
   ----------- REMOVE DUPLICATES
   
   WITH RowNumCTE AS(
   SELECT *,
   ROW_NUMBER() OVER(PARTITION BY ParcelID
                                  ,PropertyAddress
                                  ,SalePrice
                                  ,SaleDate
                                  ,LegalReference
							ORDER BY UniqueID
					) AS row_num
 FROM nashvillehousing
                   )
 DELETE NHD
FROM nashvillehousing NHD INNER JOIN RowNumCTE RN
ON NHD.UniqueID = RN.UniqueID
WHERE row_num >1; 

SELECT * FROM RowNumCTE
WHERE row_num >1;



-------------- Delete Unused Colulmns
SELECT * FROM nashvillehousing;


ALTER TABLE nashvillehousing
  DROP COLUMN OwnerAddress
 ,DROP COLUMN PropertyAddress
 ,DROP COLUMN SaleDate
 ,DROP COLUMN TaxDistrict ;
