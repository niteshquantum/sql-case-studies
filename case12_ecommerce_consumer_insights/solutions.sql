/*
Solutions for Ecommerce Consumer Insights Case Study
Database: consumer_behavior
Table: Consumer
*/
/*
alter table Consumer
add amount float;

update Consumer
set amount =try_convert(float,REPLACE(Purchase_Amount,'$',''));
---------------------------------------------------------------------------------------------------

alter table Consumer
alter column Time_of_Purchase date;
--------------------------------------------------------------------------------------------------
*/

-- LEVEL 1: Basic SELECT, WHERE & ORDER BY
-- Q1: Retrieve all details of customers who are married and have a high income level.
SELECT * FROM Consumer
WHERE Marital_Status = 'Married' AND Income_Level = 'High';

-- Q2: List all customers who made purchases through Online channel and used a credit card.
SELECT Customer_ID, Purchase_Channel, Payment_Method FROM Consumer
WHERE Purchase_Channel = 'Online' AND Payment_Method = 'Credit Card';

-- Q3: Show customers who spent more than $500 in a single purchase.
SELECT Customer_ID, amount FROM Consumer
WHERE amount > 500;

-- Q4: Display Customer_ID, Age, Gender, and Purchase_Category sorted by Age descending.
SELECT Customer_ID, Age, Gender, Purchase_Category FROM Consumer
ORDER BY Age DESC;

-- Q5: Retrieve customers whose Discount_Used is TRUE but Discount_Sensitivity = 'Not Sensitive'.
SELECT Customer_ID, Discount_Used, Discount_Sensitivity FROM Consumer
WHERE Discount_Used = 1 AND Discount_Sensitivity = 'Not Sensitive';

-- Q6: Get customers who are members of loyalty program and have a Customer_Satisfaction >= 8.
SELECT Customer_ID, Customer_Loyalty_Program_Member, Customer_Satisfaction FROM Consumer
WHERE Customer_Loyalty_Program_Member = 1 AND Customer_Satisfaction >= 8;

-- Q7: Find all customers from 'Food & Beverages' or 'Clothing' category.
SELECT Customer_ID, Purchase_Category FROM Consumer
WHERE Purchase_Category IN ('Food & Beverages', 'Clothing');

-- Q8: Show customers who did not use discounts and purchased via In-Store.
SELECT Customer_ID, Discount_Used, Purchase_Channel FROM Consumer
WHERE Discount_Used = 0 AND Purchase_Channel = 'In-Store';

-- Q9: List all customers with Purchase_Intent = 'Impulsive'.
SELECT Customer_ID, Purchase_Intent FROM Consumer
WHERE Purchase_Intent = 'Impulsive';

-- Q10: Retrieve distinct Payment_Methods used by customers.
SELECT DISTINCT Payment_Method FROM Consumer;

-- LEVEL 2: Aggregations (COUNT, SUM, AVG, GROUP BY)
-- Q1: Find the average purchase amount for each Purchase_Category.
SELECT Purchase_Category, AVG(amount) AS Average_Purchase_Amount FROM Consumer
GROUP BY Purchase_Category;

-- Q2: Count how many customers fall into each Income_Level.
SELECT Income_Level, COUNT(DISTINCT Customer_ID) AS Customers_Fall FROM Consumer
GROUP BY Income_Level;

-- Q3: Calculate the total revenue generated from each Purchase_Channel.
SELECT Purchase_Channel, SUM(amount) AS Total_Revenue FROM Consumer
GROUP BY Purchase_Channel;

-- Q4: Determine the average Product_Rating for each Brand_Loyalty level.
SELECT Brand_Loyalty, AVG(Product_Rating) AS Avg_Product_Rating FROM Consumer
GROUP BY Brand_Loyalty;

-- Q5: Find average Customer_Satisfaction grouped by Marital_Status.
SELECT Marital_Status, AVG(Customer_Satisfaction) AS Avg_Customer_Satisfaction FROM Consumer
GROUP BY Marital_Status;

-- Q6: For each Location, count how many purchases were made.
SELECT Location, COUNT(amount) AS Purchase_Made FROM Consumer
GROUP BY Location;

-- Q7: Show average Time_Spent_on_Product_Research grouped by Education_Level.
SELECT Education_Level, AVG(Time_Spent_on_Product_Research_hours) AS Avg_Time_Research FROM Consumer
GROUP BY Education_Level;

-- Q8: Calculate total Purchase_Amount and average Frequency_of_Purchase by Occupation.
SELECT Occupation, SUM(amount) AS Total_Purchase_Amount, AVG(Frequency_of_Purchase) AS Avg_Freq_Amount FROM Consumer
GROUP BY Occupation;

-- Q9: Find which Device_Used_for_Shopping generates the highest average Purchase_Amount.
SELECT TOP 1 Device_Used_for_Shopping, AVG(amount) AS Avg_Purchase_Amount FROM Consumer
GROUP BY Device_Used_for_Shopping
ORDER BY Avg_Purchase_Amount DESC;

-- Q10: Find average Return_Rate for each Discount_Sensitivity level.
SELECT Discount_Sensitivity, AVG(Return_Rate) AS Avg_Return_Rating FROM Consumer
GROUP BY Discount_Sensitivity;

-- LEVEL 3: Filtering with Aggregations & Subqueries
-- Q1: Find customers who spent more than the average Purchase_Amount overall.
SELECT Customer_ID, amount FROM Consumer
WHERE amount > (SELECT AVG(amount) FROM Consumer);

-- Q2: Retrieve the top 5 locations with the highest average Customer_Satisfaction.
SELECT TOP 5 Location, AVG(Customer_Satisfaction) AS Avg_Customer_Satisfaction FROM Consumer
GROUP BY Location
ORDER BY Avg_Customer_Satisfaction DESC;

-- Q3: Identify the Income_Level with the highest total purchase amount.
SELECT TOP 1 Income_Level, SUM(amount) AS Total_Purchase_Amount FROM Consumer
GROUP BY Income_Level
ORDER BY Total_Purchase_Amount DESC;

-- Q4: Find Purchase_Categories where the average Product_Rating < 3.
SELECT Purchase_Category, AVG(Product_Rating) AS Avg_Product_Rating FROM Consumer
GROUP BY Purchase_Category
HAVING AVG(Product_Rating) < 3;

-- Q5: List customers whose Purchase_Amount is in the top 10% of all purchases.
WITH ranked AS (
    SELECT Customer_ID, amount,
           PERCENT_RANK() OVER (ORDER BY amount) AS pr
    FROM Consumer)
SELECT Customer_ID, amount
FROM ranked
WHERE pr >= 0.9;

-- Q6: Show Education_Level(s) where average Time_to_Decision > 3 days.
SELECT Education_Level, AVG(Time_to_Decision) AS Avg_Time_to_Decision FROM Consumer
GROUP BY Education_Level
HAVING AVG(Time_to_Decision) > 3;

-- Q7: Retrieve customers with Brand_Loyalty = 5 and Product_Rating >= 4, sorted by Purchase_Amount descending.
SELECT Customer_ID, Brand_Loyalty, Product_Rating, amount FROM Consumer
WHERE Brand_Loyalty = 5 AND Product_Rating >= 4
ORDER BY amount DESC;

-- Q8: Find Purchase_Channel that contributes to the highest revenue.
SELECT TOP 1 Purchase_Channel, SUM(amount) AS Total_Revenue FROM Consumer
GROUP BY Purchase_Channel
ORDER BY Total_Revenue DESC;

-- Q9: Display top 3 Occupations based on total Purchase_Amount.
SELECT TOP 3 Occupation, SUM(amount) AS Total_Purchase_Amount FROM Consumer
GROUP BY Occupation
ORDER BY Total_Purchase_Amount DESC;

-- Q10: Find Gender-wise comparison of average Return_Rate.
SELECT Gender, AVG(Return_Rate) AS Avg_Return_Rate FROM Consumer
GROUP BY Gender;

--### LEVEL 4 — Date, String & Conditional Logic
--1. Find the month with the highest total Purchase_Amount.
SELECT TOP 1 FORMAT(Time_of_Purchase, 'yyyy-MM') AS Purchase_Month, SUM(amount) AS Total_Purchase_Amount FROM Consumer
GROUP BY FORMAT(Time_of_Purchase, 'yyyy-MM')
ORDER BY Total_Purchase_Amount DESC;

--2. Extract day of week from Time_of_Purchase and find which day sees most purchases.
SELECT TOP 1 DATENAME(WEEKDAY, Time_of_Purchase) AS Day_of_Week, COUNT(*) AS Purchase_Count FROM Consumer
GROUP BY DATENAME(WEEKDAY, Time_of_Purchase)
ORDER BY Purchase_Count DESC;

--3. Calculate average Purchase_Amount for purchases made using a discount vs without discount.
SELECT Discount_Used, AVG(amount) AS Avg_Purchase_Amount FROM Consumer
GROUP BY Discount_Used;

--4. Show customers who made purchases in 2024 Q1 (Jan–Mar).
SELECT Customer_ID, Time_of_Purchase,DATEPART(QUARTER,Time_of_Purchase) as Quarters FROM Consumer
where DATEPART(QUARTER,Time_of_Purchase)=1;

-- OR 
SELECT Customer_ID, Time_of_Purchase FROM Consumer
WHERE Time_of_Purchase BETWEEN '2024-01-01' AND '2024-03-31';

--5. Display Age groups (<25, 25–40, >40) and their average Purchase_Amount.
SELECT CASE  WHEN Age < 25 THEN '<25' WHEN Age BETWEEN 25 AND 40 THEN '25-40' ELSE '>40' END AS Age_Group,
		AVG(amount) AS Avg_Purchase_Amount
FROM Consumer
GROUP BY CASE WHEN Age < 25 THEN '<25' WHEN Age BETWEEN 25 AND 40 THEN '25-40' ELSE '>40' END;

--OR 
SELECT Age_Group,AVG(c.amount) AS Avg_Purchase_Amount FROM (
SELECT Customer_ID, CASE  WHEN Age < 25 THEN '<25' WHEN Age BETWEEN 25 AND 40 THEN '25-40' ELSE '>40' END AS Age_Group ,amount
FROM Consumer ) c GROUP BY Age_Group;

--6. Count how many purchases were made using PayPal vs Credit Card.
SELECT Payment_Method, COUNT(*) AS Purchase_Count FROM Consumer
WHERE Payment_Method IN ('PayPal', 'Credit Card') GROUP BY Payment_Method;

--7. Find customers whose Purchase_Intent = 'Planned' but Discount_Used = TRUE.
SELECT Customer_ID, Purchase_Intent, Discount_Used FROM Consumer
WHERE Purchase_Intent = 'Planned' AND Discount_Used = 1;

--8. Create a derived column 'Purchase_Type' (Discounted vs Full Price) and group by Purchase_Type to get total sales.
SELECT  CASE WHEN Discount_Used = 1 THEN 'Discounted' ELSE 'Full Price' END AS Purchase_Type,
    SUM(amount) AS Total_Sales FROM Consumer
GROUP BY CASE WHEN Discount_Used = 1 THEN 'Discounted' ELSE 'Full Price' END;

--9. Find average Time_to_Decision for each Purchase_Intent.
SELECT Purchase_Intent, AVG(Time_to_Decision) AS Avg_Time_to_Decision FROM Consumer
GROUP BY Purchase_Intent;

--10. Determine percentage of customers who are Loyalty Program Members.
SELECT 100.0 * SUM(CASE WHEN Customer_Loyalty_Program_Member = 1 THEN 1 ELSE 0 END) / COUNT(*) AS Percentage_Loyalty_Members
FROM Consumer;

--### LEVEL 5 — Window Functions & Analytical Insights
--1. Rank customers by Purchase_Amount within each Purchase_Category.
SELECT Customer_ID, Purchase_Category,amount, 
    RANK() OVER (PARTITION BY Purchase_Category ORDER BY amount DESC) AS Purchase_Rank
FROM Consumer;

--2. Find cumulative Purchase_Amount by Location ordered by Purchase_Amount.
SELECT Location, amount, 
    SUM(amount) OVER (PARTITION BY Location ORDER BY amount) AS Cumulative_Purchase_Amount
FROM Consumer;

--3. For each Occupation, find average Purchase_Amount and show how each customer compares to the average.
SELECT Customer_ID, Occupation, amount, 
    AVG(amount) OVER (PARTITION BY Occupation) AS Avg_Purchase_Amount,
    amount - AVG(amount) OVER (PARTITION BY Occupation) AS Difference_From_Avg
FROM Consumer;

--4. Show running total of Purchase_Amount by Time_of_Purchase.
SELECT DISTINCT Time_of_Purchase,
	sum(amount)OVER(PARTITION BY Time_of_purchase) AS amount,
    SUM(amount) OVER (ORDER BY Time_of_Purchase) AS Running_Total
FROM Consumer;

--5. Calculate percentile rank of customers based on Brand_Loyalty.
SELECT Customer_ID, Brand_Loyalty, PERCENT_RANK() OVER (ORDER BY Brand_Loyalty) AS Percentile_Rank
FROM Consumer;

--6. For each Income_Level, show the top 3 most satisfied customers.
SELECT *
FROM (
    SELECT Customer_ID, Income_Level, Customer_Satisfaction, 
        RANK() OVER (PARTITION BY Income_Level ORDER BY Customer_Satisfaction DESC) AS Satisfaction_Rank
    FROM Consumer ) AS Ranked
WHERE Satisfaction_Rank <4;

--7. For each Purchase_Channel, find average Time_to_Decision and standard deviation.
SELECT Purchase_Channel, 
    AVG(Time_to_Decision) AS Avg_Time_to_Decision, 
    STDEV(Time_to_Decision) AS StdDev_Time_to_Decision
FROM Consumer GROUP BY Purchase_Channel;

--8. Compare average Engagement_with_Ads levels (convert categorical to numeric).
SELECT  Engagement_with_Ads,
    AVG(CASE WHEN Engagement_with_Ads = 'None' THEN 0 WHEN Engagement_with_Ads = 'Low' THEN 1
        WHEN Engagement_with_Ads = 'Medium' THEN 2 WHEN Engagement_with_Ads = 'High' THEN 3
    END) AS Avg_Engagement_Score
FROM Consumer GROUP BY Engagement_with_Ads;

--9. Identify loyal customers whose Brand_Loyalty >= 4 and Customer_Satisfaction >= 8 and compute their share in total revenue.
SELECT 
    SUM(CASE WHEN Brand_Loyalty >= 4 AND Customer_Satisfaction >= 8 THEN amount ELSE 0 END) AS Loyal_Customer_Revenue,
    SUM(amount) AS Total_Revenue,
    100.0 * SUM(CASE WHEN Brand_Loyalty >= 4 AND Customer_Satisfaction >= 8 THEN amount ELSE 0 END) / SUM(amount) AS Revenue_Share_Percentage
FROM Consumer;

--10. Find customers who spend above the 75th percentile of Purchase_Amount.
SELECT Customer_ID, amount FROM Consumer
WHERE amount >= (SELECT DISTINCT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) OVER () FROM Consumer);


--### LEVEL 6 — Business-Oriented Case Studies
--1. Identify the customer segment (based on Income_Level & Age group) that spends the most.
SELECT TOP 1 Income_Level,
    CASE WHEN Age < 25 THEN '<25' WHEN Age BETWEEN 25 AND 40 THEN '25-40' ELSE '>40' END AS Age_Group,
    SUM(amount) AS Total_Spend FROM Consumer
GROUP BY Income_Level,CASE WHEN Age < 25 THEN '<25' WHEN Age BETWEEN 25 AND 40 THEN '25-40' ELSE '>40' END
ORDER BY Total_Spend DESC;

--2. Find the most profitable Purchase_Category among customers with High Social Media Influence.
SELECT TOP 1 Purchase_Category,SUM(amount) AS Total_Revenue
FROM Consumer
WHERE Social_Media_Influence = 'High' GROUP BY Purchase_Category ORDER BY Total_Revenue DESC;

--3. Determine whether Online or In-Store purchases have higher Customer_Satisfaction.
SELECT Purchase_Channel,
    AVG(Customer_Satisfaction) AS Avg_Customer_Satisfaction
FROM Consumer
WHERE Purchase_Channel IN ('Online', 'In-Store') GROUP BY Purchase_Channel;

--4. Analyze how Discount_Sensitivity affects Return_Rate.
SELECT  Discount_Sensitivity, AVG(Return_Rate) AS Avg_Return_Rate
FROM Consumer GROUP BY Discount_Sensitivity;

--5. Find the relationship between Brand_Loyalty and Frequency_of_Purchase.
SELECT Brand_Loyalty,AVG(Frequency_of_Purchase) AS Avg_Frequency_of_Purchase
FROM Consumer GROUP BY Brand_Loyalty ORDER BY Brand_Loyalty;

--7. Compare average Purchase_Amount across different devices used for shopping.
SELECT Device_Used_for_Shopping,AVG(amount) AS Avg_Purchase_Amount
FROM Consumer GROUP BY Device_Used_for_Shopping;

--8. Find locations where customers spend the most time on research before buying.
SELECT TOP 1 Location, AVG(Time_Spent_on_Product_Research_hours) AS Avg_Research_Time
FROM Consumer GROUP BY Location ORDER BY Avg_Research_Time DESC;

--9. Find customers who have high satisfaction (>=9) but low brand loyalty (<=2) — possible brand switchers.
SELECT Customer_ID, Customer_Satisfaction, Brand_Loyalty
FROM Consumer WHERE Customer_Satisfaction >= 9 AND Brand_Loyalty <= 2;

--10. Build a loyalty segment table grouped by Customer_Loyalty_Program_Member showing total customers, avg purchase amount, satisfaction, and loyalty.
SELECT Customer_Loyalty_Program_Member,COUNT(DISTINCT Customer_ID) AS Total_Customers,
    AVG(amount) AS Avg_Purchase_Amount,AVG(Customer_Satisfaction) AS Avg_Satisfaction,
    AVG(Brand_Loyalty) AS Avg_Loyalty
FROM Consumer GROUP BY Customer_Loyalty_Program_Member;