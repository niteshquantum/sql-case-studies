# Consumer Behavior Dataset - SQL Practice

## Dataset Overview
The dataset is stored in the `consumer_behavior` database, with a single table `Consumer`. It captures ecommerce consumer behavior, including demographics, purchase details, and satisfaction metrics. The dataset is provided as a CSV file (`Ecommerce_Consumer_Behavior_Analysis_Data.csv`) and should be imported into the `Consumer` table. Ensure the `amount` column (float version of `Purchase_Amount` without '$') and `Time_of_Purchase` (DATE type) are properly derived or converted during import.

**Table: Consumer**
- **Columns**: Customer_ID, Age, Gender, Income_Level, Marital_Status, Education_Level, Occupation, Location, Purchase_Category, Purchase_Amount, Frequency_of_Purchase, Purchase_Channel, Brand_Loyalty, Product_Rating, Time_Spent_on_Product_Research_hours, Social_Media_Influence, Discount_Sensitivity, Return_Rate, Customer_Satisfaction, Engagement_with_Ads, Device_Used_for_Shopping, Payment_Method, Time_of_Purchase, Discount_Used, Customer_Loyalty_Program_Member, Purchase_Intent, Shipping_Preference, Time_to_Decision, amount (derived, float version of Purchase_Amount).

## Questions

### LEVEL 1 — Basic SELECT, WHERE & ORDER BY
1. Retrieve all details of customers who are married and have a high income level.
2. List all customers who made purchases through Online channel and used a credit card.
3. Show customers who spent more than $500 in a single purchase.
4. Display Customer_ID, Age, Gender, and Purchase_Category sorted by Age descending.
5. Retrieve customers whose Discount_Used is TRUE but Discount_Sensitivity = 'Not Sensitive'.
6. Get customers who are members of loyalty program and have a Customer_Satisfaction >= 8.
7. Find all customers from 'Food & Beverages' or 'Clothing' category.
8. Show customers who did not use discounts and purchased via In-Store.
9. List all customers with Purchase_Intent = 'Impulsive'.
10. Retrieve distinct Payment_Methods used by customers.

### LEVEL 2 — Aggregations (COUNT, SUM, AVG, GROUP BY)
1. Find the average purchase amount for each Purchase_Category.
2. Count how many customers fall into each Income_Level.
3. Calculate the total revenue generated from each Purchase_Channel.
4. Determine the average Product_Rating for each Brand_Loyalty level.
5. Find average Customer_Satisfaction grouped by Marital_Status.
6. For each Location, count how many purchases were made.
7. Show average Time_Spent_on_Product_Research grouped by Education_Level.
8. Calculate total Purchase_Amount and average Frequency_of_Purchase by Occupation.
9. Find which Device_Used_for_Shopping generates the highest average Purchase_Amount.
10. Find average Return_Rate for each Discount_Sensitivity level.

### LEVEL 3 — Filtering with Aggregations & Subqueries
1. Find customers who spent more than the average Purchase_Amount overall.
2. Retrieve the top 5 locations with the highest average Customer_Satisfaction.
3. Identify the Income_Level with the highest total purchase amount.
4. Find Purchase_Categories where the average Product_Rating < 3.
5. List customers whose Purchase_Amount is in the top 10% of all purchases.
6. Show Education_Level(s) where average Time_to_Decision > 3 days.
7. Retrieve customers with Brand_Loyalty = 5 and Product_Rating >= 4, sorted by Purchase_Amount descending.
8. Find Purchase_Channel that contributes to the highest revenue.
9. Display top 3 Occupations based on total Purchase_Amount.
10. Find Gender-wise comparison of average Return_Rate.

### LEVEL 4 — Date, String & Conditional Logic
1. Find the month with the highest total Purchase_Amount.
2. Extract day of week from Time_of_Purchase and find which day sees most purchases.
3. Calculate average Purchase_Amount for purchases made using a discount vs without discount.
4. Show customers who made purchases in 2024 Q1 (Jan–Mar).
5. Display Age groups (<25, 25–40, >40) and their average Purchase_Amount.
6. Count how many purchases were made using PayPal vs Credit Card.
7. Find customers whose Purchase_Intent = 'Planned' but Discount_Used = TRUE.
8. Create a derived column 'Purchase_Type' (Discounted vs Full Price) and group by Purchase_Type to get total sales.
9. Find average Time_to_Decision for each Purchase_Intent.
10. Determine percentage of customers who are Loyalty Program Members.

### LEVEL 5 — Window Functions & Analytical Insights
1. Rank customers by Purchase_Amount within each Purchase_Category.
2. Find cumulative Purchase_Amount by Location ordered by Purchase_Amount.
3. For each Occupation, find average Purchase_Amount and show how each customer compares to the average.
4. Show running total of Purchase_Amount by Time_of_Purchase.
5. Calculate percentile rank of customers based on Brand_Loyalty.
6. For each Income_Level, show the top 3 most satisfied customers.
7. For each Purchase_Channel, find average Time_to_Decision and standard deviation.
8. Compare average Engagement_with_Ads levels (convert categorical to numeric).
9. Identify loyal customers whose Brand_Loyalty >= 4 and Customer_Satisfaction >= 8 and compute their share in total revenue.
10. Find customers who spend above the 75th percentile of Purchase_Amount.

### LEVEL 6 — Business-Oriented Case Studies
1. Identify the customer segment (based on Income_Level & Age group) that spends the most.
2. Find the most profitable Purchase_Category among customers with High Social Media Influence.
3. Determine whether Online or In-Store purchases have higher Customer_Satisfaction.
4. Analyze how Discount_Sensitivity affects Return_Rate.
5. Find the relationship between Brand_Loyalty and Frequency_of_Purchase.
6. Identify which Payment_Methods are preferred by Married customers.
7. Compare average Purchase_Amount across different devices used for shopping.
8. Find locations where customers spend the most time on research before buying.
9. Find customers who have high satisfaction (>=9) but low brand loyalty (<=2) — possible brand switchers.
10. Build a loyalty segment table grouped by Customer_Loyalty_Program_Member showing total customers, avg purchase amount, satisfaction, and loyalty.