-- Select all fields from dataset
SELECT *
FROM housing;

-- Number of rows in dataset
SELECT COUNT(*)
FROM housing;

-- Number of unique ids
SELECT COUNT(DISTINCT uniqueid)
FROM housing;

-- parcelid
-- Number of unique parcelids
SELECT COUNT(DISTINCT parcelid)
FROM housing;

-- Number of duplicate parcelids
SELECT COUNT(*) - COUNT(DISTINCT parcelid) AS n_duplicates
FROM housing;

-- Number of null parcelids
SELECT *
FROM housing
WHERE parcelid IS NULL;

-- landuse
-- Number of null values in landuse
SELECT *
FROM housing
WHERE landuse IS NULL;

-- Count distinct types of landuse
SELECT COUNT(DISTINCT landuse)
FROM housing;

-- List distinct types of landuse
SELECT DISTINCT landuse
FROM housing;


-- Find null values in propertyaddress
SELECT *
FROM housing
WHERE parcelid IN (SELECT parcelid
	FROM housing
	WHERE propertyaddress IS NULL)
ORDER BY parcelid;


--------------------------------------------------------------------
-- Populate Property Address data where parcelid is identical
-- Using a self join
WITH ab AS (
SELECT a.parcelid AS pid, a.propertyaddress, b.parcelid, b.propertyaddress, 
	   COALESCE(a.propertyaddress, b.propertyaddress) AS commonaddress
FROM housing AS a
JOIN housing AS b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
)
UPDATE housing
SET PropertyAddress = ab.commonaddress
FROM ab
WHERE housing.parcelid = ab.pid
	AND housing.propertyaddress IS NULL;


-- Splitting property address into individual columns (Address, City)
SELECT propertyaddress
FROM housing;

SELECT SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress,',')-1) AS address,
	   SUBSTRING(propertyaddress, STRPOS(propertyaddress,',')+1, LENGTH(propertyaddress))
FROM housing;


-- Add new column for property address without city
ALTER TABLE housing
Add propertysplitaddress VARCHAR(255);

UPDATE housing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress,',')-1)


-- Add new column for property address without city
ALTER TABLE housing
Add propertycity VARCHAR(255);

UPDATE housing
SET propertycity = SUBSTRING(propertyaddress, STRPOS(propertyaddress,',')+1, LENGTH(propertyaddress))


-- Splitting owner address into individual columns (Address, City, State)
SELECT SPLIT_PART(owneraddress, ',', 1) AS ownersplitaddress, 
	   SPLIT_PART(owneraddress, ',', 2) AS ownercity, 
	   SPLIT_PART(owneraddress, ',', 3) AS ownerstate
FROM housing;

-- Add new column for owner address without city and state
ALTER TABLE housing
ADD ownersplitaddress VARCHAR(255);

UPDATE housing
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1);


-- Add new column for owner city
ALTER TABLE housing
ADD ownercity VARCHAR(255);

UPDATE housing
SET ownercity = SPLIT_PART(owneraddress, ',', 2);


-- Add new column for owner state
ALTER TABLE housing
ADD ownerstate VARCHAR(255);

UPDATE housing
SET ownerstate = SPLIT_PART(owneraddress, ',', 3);

SELECT *
FROM housing;


--------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM housing
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant, 
	   CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	   WHEN soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END
FROM housing;

UPDATE housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	   			   WHEN soldasvacant = 'N' THEN 'No'
	   			   ELSE soldasvacant
	   			   END;


--------------------------------------------------------------------
-- Remove duplicate rows

DELETE FROM housing
WHERE uniqueid IN (
	SELECT uniqueid
	FROM (SELECT uniqueid, ROW_NUMBER() OVER (PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference) AS row_num
	FROM housing) AS s
	WHERE row_num > 1
)

SELECT COUNT(*)
FROM housing;


--------------------------------------------------------------------
-- Delete unused columns
SELECT *
FROM housing;

ALTER TABLE housing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

--------------------------------------------------------------------
SELECT *
FROM housing
WHERE propertyaddress IS NULL;