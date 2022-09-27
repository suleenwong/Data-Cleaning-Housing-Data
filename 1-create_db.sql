DROP TABLE IF EXISTS housing;

CREATE TABLE housing(
	UniqueID INT,
	ParcelID VARCHAR(50),
	LandUse VARCHAR(50),
	PropertyAddress VARCHAR(255),
	SaleDate DATE,
	SalePrice VARCHAR(50),
	LegalReference VARCHAR(50),
	SoldAsVacant VARCHAR(50),
	OwnerName VARCHAR(255),
	OwnerAddress VARCHAR(255),
	Acreage NUMERIC,
	TaxDistrict VARCHAR(50),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt INT,
	Bedrooms INT,
	FullBath INT,
	HalfBath INT
);

COPY housing
FROM 'nashville_housing_data.csv'
DELIMITER ',' 
CSV HEADER;