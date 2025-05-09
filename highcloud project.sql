create database highcloud;
use highcloud;
select * from maindata;
select count(*) from maindata;
SELECT COUNT(DISTINCT `%Airline ID`) AS distinct_airlines FROM maindata;
SELECT COUNT(DISTINCT `Carrier Name`) AS distinct_airlines FROM maindata;
SELECT COUNT(DISTINCT `Origin Country`) AS distinct_country FROM maindata;


-- "1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)"
--   A.Year
  -- B.Monthno
  -- C.Monthfullname
   -- D.Quarter(Q1,Q2,Q3,Q4)
   -- E. YearMonth ( YYYY-MMM)
   -- F. Weekdayno
   -- G.Weekdayname
   -- H.FinancialMOnth
   -- I. Financial Quarter 

set sql_safe_updates = 0;
ALTER TABLE maindata ADD COLUMN Full_Date DATE;
UPDATE maindata  
SET Full_Date = DATE(CONCAT(Year, '-', `Month (#)`, '-', Day));
SELECT Year, `Month (#)`, Day, Full_Date FROM maindata;
set sql_safe_updates = 1;

CREATE VIEW Date_Details AS  
SELECT  
    Year,  
    `Month (#)` AS MonthNo,  
    DATE_FORMAT(Full_Date, '%M') AS MonthFullName,  
    CASE  
        WHEN MONTH(Full_Date) BETWEEN 1 AND 3 THEN 'Q1'  
        WHEN MONTH(Full_Date) BETWEEN 4 AND 6 THEN 'Q2'  
        WHEN MONTH(Full_Date) BETWEEN 7 AND 9 THEN 'Q3'  
        ELSE 'Q4'  
    END AS Quarter,  
    DATE_FORMAT(Full_Date, '%Y-%b') AS YearMonth,  
    DAYOFWEEK(Full_Date) AS WeekdayNo,  
    DATE_FORMAT(Full_Date, '%W') AS WeekdayName,  
    DATE_FORMAT(Full_Date, '%m-%Y') AS FinancialMonth,  
    CASE  
        WHEN MONTH(Full_Date) BETWEEN 4 AND 6 THEN 'Q1'  
        WHEN MONTH(Full_Date) BETWEEN 7 AND 9 THEN 'Q2'  
        WHEN MONTH(Full_Date) BETWEEN 10 AND 12 THEN 'Q3'  
        ELSE 'Q4'  
    END AS FinancialQuarter  
FROM maindata;

select * from Date_details;



-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

CREATE VIEW yearly_load_factor AS  
SELECT YEAR(full_date) AS year,  
CONCAT(ROUND((SUM(`# Transported Passengers`) * 100 / SUM(`# Available Seats`)), 2), '%') AS load_factor_percentage  
FROM maindata  
GROUP BY YEAR(full_date);

CREATE VIEW quarterly_load_factor AS  
SELECT YEAR(full_date) AS year,  
QUARTER(full_date) AS quarter,  
CONCAT(ROUND((SUM(`# Transported Passengers`) * 100 / SUM(`# Available Seats`)), 2), '%') AS load_factor_percentage  
FROM maindata  
GROUP BY YEAR(full_date), QUARTER(full_date);


CREATE VIEW monthly_load_factor AS  
SELECT  
    YEAR(full_date) AS year,  
    MONTH(full_date) AS month_number,  
    DATE_FORMAT(full_date, '%M') AS month_name,  
    CONCAT(ROUND((SUM(`# Transported Passengers`) * 100 / SUM(`# Available Seats`)), 2), '%') AS load_factor_percentage  
FROM maindata  
GROUP BY YEAR(full_date), MONTH(full_date), month_name  
ORDER BY year, month_number;


-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

CREATE VIEW Load_Factor_By_Carrier AS  
SELECT  
    `Carrier Name`,  
    CONCAT(ROUND((SUM(`# Transported Passengers`) / SUM(`# Available Seats`)) * 100, 2), '%') AS Load_Factor_Percentage  
FROM maindata  
GROUP BY `Carrier Name`  
ORDER BY (SUM(`# Transported Passengers`) / SUM(`# Available Seats`)) DESC;

SELECT * FROM Load_Factor_By_Carrier;

-- 4. Identify Top 10 Carrier Names based passengers preference 

CREATE VIEW Top_10_Carriers AS
SELECT 
    `Carrier Name`, 
    SUM(`# Transported Passengers`) AS Total_Passengers
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Total_Passengers DESC
LIMIT 10;

SELECT * FROM Top_10_Carriers;

-- 5. Display top Routes ( from-to City) based on Number of Flights 

CREATE VIEW Top_10_Routes AS
SELECT `From - To City`, COUNT(*) AS total_flights
FROM maindata
GROUP BY `From - To City`
ORDER BY total_flights DESC
LIMIT 10;

SELECT * FROM Top_10_Routes;

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.

CREATE VIEW weekend_weekday AS  
SELECT  
    CASE  
        WHEN DAYOFWEEK(full_date) IN (1, 7) THEN 'Weekend'  
        ELSE 'Weekday'  
    END AS Day_Type,  
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM maindata), 2) AS Load_Factor_Percentage  
FROM maindata  
GROUP BY Day_Type;  


SELECT * FROM weekend_weekday;

-- 7. Identify number of flights based on Distance group

CREATE VIEW Distance_Group AS  
SELECT  
    CASE  
        WHEN distance < 1000 THEN 'Short'  
        WHEN distance BETWEEN 1000 AND 2500 THEN 'Medium'  
        ELSE 'Long'  
    END AS Distance_Group,  
    CONCAT(ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM maindata), 2), '%') AS Flight_Percentage  
FROM maindata  
GROUP BY Distance_Group;


SELECT * FROM Distance_Group;












