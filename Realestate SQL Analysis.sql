
--Look at the observations to get familiarized with the data
Select *
from [Arizona Realestate]

-- Inappropriate values
SELECT DISTINCT propertyType
FROM [Arizona Realestate]

SELECT DISTINCT postcode
FROM [Arizona Realestate]

SELECT DISTINCT bedrooms
FROM [Arizona Realestate]

--few observations had the value 0 in bedrooms so I decided to take a look at those
SELECT datesold, propertyType, bedrooms
from [Arizona Realestate]
where bedrooms = 0 

SELECT COUNT(*) AS properties_without_bedrooms
from [Arizona Realestate]
where bedrooms = 0

--making sure all postal codes have 4 characters
SELECT LEN(postcode) AS number_characters, COUNT(LEN(postcode)) AS n_postal_codes
FROM [Arizona Realestate]
GROUP BY LEN(postcode)

 --Date corresponds to the highest number of sales?
SELECT TOP 1 datesold AS date, COUNT(*) AS number_of_sales
FROM [Arizona Realestate]
GROUP BY datesold
ORDER BY number_of_sales DESC

-- Postcode with the highest average price per sale? (Using Aggregate Functions)
SELECT TOP 1 postcode, AVG(price) AS avg_price
FROM [Arizona Realestate]
GROUP BY postcode
ORDER BY AVG(price) DESC

--A year witnessed the lowest number of sales?
SELECT TOP 1 YEAR(datesold) AS year, COUNT(*) AS number_of_sales
FROM [Arizona Realestate]
GROUP BY YEAR(datesold)
ORDER BY number_of_sales ASC

--Top six postcodes by year's price
SELECT YEAR(datesold) as year, postcode, price,
         dense_rank() OVER (PARTITION BY YEAR(datesold), postcode ORDER BY price DESC) rnk
INTO #sales2
FROM [Arizona Realestate]

SELECT r.year, r.postcode, r.price
FROM(
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY year ORDER BY price DESC) row_num
    FROM #sales2
    WHERE rnk < 2) r
WHERE r.row_num BETWEEN 1 AND 6

--Identify the top three months with the highest total sales amount, excluding sales made for properties with zero bedrooms.
WITH Valid_Sales AS (
    SELECT YEAR(datesold) AS year,
           MONTH(datesold) AS month,
           SUM(price) AS total_sales_amount
    FROM [Arizona Realestate]
    WHERE bedrooms > 0
    GROUP BY YEAR(datesold), MONTH(datesold)
),
Top_Months AS (
    SELECT TOP 3 year, month, total_sales_amount
    FROM Valid_Sales
    ORDER BY total_sales_amount DESC
)
SELECT year, month, total_sales_amount
FROM Top_Months;
