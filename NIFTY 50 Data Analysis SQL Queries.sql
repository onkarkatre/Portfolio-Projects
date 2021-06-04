/*  NIFTY 50 Stocks Data Analysis  */

SELECT *
FROM PortfolioProject..[Hindunililvr table]

SELECT *
FROM PortfolioProject..[KotakBank table]

SELECT *
FROM PortfolioProject..[Reliance table]


-- Average Turnover of All Top 3 NIFTY 50 Stocks --

SELECT AVG(turnover)
FROM PortfolioProject..[Hindunililvr table]

SELECT AVG(turnover)
FROM PortfolioProject..[KotakBank table]

SELECT AVG(turnover)
FROM PortfolioProject..[Reliance table]


-- Standardizing Date Format --

SELECT CONVERT(Date, Date)
FROM PortfolioProject..[Hindunililvr table]

ALTER TABLE [Hindunililvr table]
ADD ConvertedDate Date;

UPDATE [Hindunililvr table]
SET ConvertedDate = CONVERT(Date, Date)

ALTER TABLE [Hindunililvr table]
DROP COLUMN Date

SELECT *
FROM PortfolioProject..[Hindunililvr table]
------------------------------------------

SELECT CONVERT(Date, Date)
FROM PortfolioProject..[KotakBank table]

ALTER TABLE [KotakBank table]
ADD ConvertedDate Date;

UPDATE [KotakBank table]
SET ConvertedDate = CONVERT(Date, Date)

ALTER TABLE [KotakBank table]
DROP COLUMN Date

SELECT *
FROM PortfolioProject..[KotakBank table]

--------------------------------------------------

SELECT CONVERT(Date, Date)
FROM PortfolioProject..[Reliance table]

ALTER TABLE [Reliance table]
ADD ConvertedDate Date;

UPDATE [Reliance table]
SET ConvertedDate = CONVERT(Date, Date)

ALTER TABLE [Reliance table]
DROP COLUMN Date

SELECT *
FROM PortfolioProject..[Reliance table]

-- Top 3 Days with Highest Turnover --

SELECT TOP 3 ConvertedDate, Turnover
FROM PortfolioProject..[Hindunililvr table] 
ORDER BY Turnover DESC

SELECT TOP 3 ConvertedDate, Turnover
FROM PortfolioProject..[KotakBank table]
ORDER BY Turnover DESC

SELECT TOP 3 ConvertedDate, Turnover
FROM PortfolioProject..[Reliance table]
ORDER BY Turnover DESC

-- Highest Volume By Months --

SELECT datename(month, ConvertedDate) AS Month, AVG(Volume) AS Avg_Volumn
FROM PortfolioProject..[Hindunililvr table]
WHERE ConvertedDate LIKE '2020%'
GROUP BY datename(month, ConvertedDate)
Order BY Avg_Volumn DESC

SELECT datename(month, ConvertedDate) AS Month, AVG(Volume) AS Avg_Volumn
FROM PortfolioProject..[KotakBank table]
WHERE ConvertedDate LIKE '2020%'
GROUP BY datename(month, ConvertedDate)
Order BY Avg_Volumn DESC

SELECT datename(month, ConvertedDate) AS Month, AVG(Volume) AS Avg_Volumn
FROM PortfolioProject..[Reliance table]
WHERE ConvertedDate LIKE '2020%'
GROUP BY datename(month, ConvertedDate)
Order BY Avg_Volumn DESC

-- Which Month Had Highest High's -- 

SELECT datename(month, ConvertedDate) AS Month, High, [Deliverable Volume]
FROM PortfolioProject..[Hindunililvr table]
WHERE High >= '2000' AND ConvertedDate LIKE '2020%'
ORDER BY High DESC


SELECT datename(month, ConvertedDate) AS Month, High, [Deliverable Volume]
FROM PortfolioProject..[KotakBank table]
WHERE High >= '2000' AND ConvertedDate LIKE '2020%'
ORDER BY High DESC


SELECT datename(month, ConvertedDate) AS Month, High, [Deliverable Volume]
FROM PortfolioProject..[Reliance table]
WHERE High >= '2000' AND ConvertedDate LIKE '2020%'
ORDER BY High DESC

-- Which Month Had Lowest Low's --

SELECT datename(month, ConvertedDate) AS Month, Low, [Deliverable Volume]
FROM PortfolioProject..[Hindunililvr table]
WHERE ConvertedDate LIKE '2020%'
ORDER BY Low

SELECT datename(month, ConvertedDate) AS Month, Low, [Deliverable Volume]
FROM PortfolioProject..[KotakBank table]
WHERE ConvertedDate LIKE '2020%'
ORDER BY Low

SELECT ConvertedDate, datename(month, ConvertedDate) AS Month, Low, [Deliverable Volume]
FROM PortfolioProject..[Reliance table]
WHERE ConvertedDate LIKE '2020%'
ORDER BY Low
