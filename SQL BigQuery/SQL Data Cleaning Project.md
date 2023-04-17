# Data Cleaning using Google Bigquery
This mini project on **Data Cleaning** uses the Nashville Housing Data from Kaggle. Below is a short description of steps taken to clean the data.
## Understanding the data
The following SQL queries were ran to have a feel of the data at hand:
```sql
SELECT *
FROM `portfolioproject-365216.Housing.Nashville`;

SELECT  MAX(SaleDate)  from  `portfolioproject-365216.Housing.Nashville`;
SELECT  MIN(SaleDate)  from  `portfolioproject-365216.Housing.Nashville`;

SELECT
  PropertyAddress,
  COUNT(*) AS frequency
FROM `portfolioproject-365216.Housing.Nashville`
GROUP BY PropertyAddress;
```
## Handling NULL values
Running the last query above informed that there were 29 _null_ values for _PropertyAddress_. 

On examining the [raw data](https://github.com/leekarensl/PortfolioProjects/blob/main/SQL%20BigQuery/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx), it was noticed that data with identical ParcelID also had identical values as the _PropertyAddress_. This was further confirmed using the following SQL **Self Join** query:
```sql
SELECT
  a.ParcelD,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `portfolioproject-365216.Housing.Nashville` a
JOIN `portfolioproject-365216.Housing.Nashville` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ = b.UniqueID_
  WHERE a.PropertyAddress IS NULL;
```
As such, this was used to update the table so that the null values found in _PropertyAddress_ can be corrected:
```sql
UPDATE a
SET PropertyAdress = IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `portfolioproject-365216.Housing.Nashville` a
JOIN `portfolioproject-365216.Housing.Nashville` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ = b.UniqueID_
  WHERE a.PropertyAddress IS NULL;
```
## Splitting values into two or more columns
### PropertyAddress
Now that _null_ values have been taken care of in the _PropertyAddress_, in order to increase readability, the city was split from the main address using the **SPLIT** function in Google BigQuery. As the city is indicated after the comma delimiter ( , ) from the main address, the delimiter was use as a split point in the SQL query:
```sql
SELECT
  SPLIT(PropertyAddress, ' , ') [offset(0)] AS address,
  SPLIT(PropertyAddress, ' , ') [offset(1)] AS city
FROM `portfolioproject-365216.Housing.Nashville`
```
 ### OwnerAddress
 The same **SPLIT** function was performed for the _OwnerAddress_. However this time, values in the _OwnerAddress_ column was split into 3 - _owner_address_, _owner_town_ and _owner_city_:
```sql
SELECT
  SPLIT(OwnerAddress, ',')  [offset(0)]  AS owner_addresss,
  SPLIT(OwnerAddress, ',')  [offset(1)]  AS owner_town,
  SPLIT(OwnerAddress, ',')  [offset(2)]  AS owner_city
FROM  `portfolioproject-365216.Housing.Nashville`;
```
## Finding and removing duplicates
In order to find duplicates in the data, the **row_number( )** function was used together with **PARTITION BY** within a _common table expression_ more widely known as **CTE**. The partition divides the data into set partitions and the row_number function is then applied to each partition, assigning a row number:
```sql
WITH cte_row_num AS(
SELECT
  *,
  ROW_NUMBER()  OVER(
     PARTITION  BY ParcelID,
				   PropertyAddress,
				   SalePrice,
				   LegalReference
				   ORDER  BY
					 UniqueID_
  )  AS row_num
FROM  `portfolioproject-365216.Housing.Nashville`
)
```
Therefore any duplicated records will have the value of 2 or more for _row_num_. These records were then deleted from the table:
```sql
DELETE
FROM cte_row_num
WHERE row_num >1;
```
