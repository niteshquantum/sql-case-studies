# Ecommerce Consumer Insights

## Problem Statement
This case study analyzes consumer behavior in an ecommerce platform, focusing on demographics, purchase patterns, and satisfaction metrics to identify trends, optimize marketing strategies, and improve customer retention.

## Dataset Description
- **File**: [`Ecommerce_Consumer_Behavior_Analysis_Data.csv`](Ecommerce_Consumer_Behavior_Analysis_Data.csv)
- **Schema**: The dataset should be imported into the `consumer_behavior` database, with a single table named `Consumer`.
- **Instructions for Use**:
  - The dataset is provided as a CSV file (`Ecommerce_Consumer_Behavior_Analysis_Data.csv`).
  - Import the CSV into a SQL database SQL Server to create the `Consumer` table in the `consumer_behavior` database.
  - Ensure the `amount` column (float version of `Purchase_Amount` without '$') is derived during import or added via SQL
- **Table Breakdown**:
  - **Consumer**: Stores customer demographics (e.g., Age, Gender, Income_Level), purchase details (e.g., Purchase_Amount, Purchase_Category, Purchase_Channel), and behavioral metrics (e.g., Customer_Satisfaction, Brand_Loyalty, Time_Spent_on_Product_Research_hours). Includes a derived column `amount` (float version of Purchase_Amount).

**Table: Consumer Columns**
- Customer_ID (VARCHAR): Unique identifier for each customer
- Age (INT): Customer's age
- Gender (VARCHAR): Customer's gender
- Income_Level (VARCHAR): Income bracket (Low, Middle, High)
- Marital_Status (VARCHAR): Marital status (Single, Married, Widowed)
- Education_Level (VARCHAR): Education level (High School, Bachelor's, Master's)
- Occupation (VARCHAR): Occupation level (Low, Middle, High)
- Location (VARCHAR): Customer's location
- Purchase_Category (VARCHAR): Category of purchased product
- Purchase_Amount (VARCHAR): Purchase amount with '$' symbol
- Frequency_of_Purchase (INT): Number of purchases made
- Purchase_Channel (VARCHAR): Channel used (Online, In-Store, Mixed)
- Brand_Loyalty (INT): Loyalty score (1-5)
- Product_Rating (INT): Rating given to product (1-5)
- Time_Spent_on_Product_Research_hours (FLOAT): Hours spent researching
- Social_Media_Influence (VARCHAR): Influence level (None, Low, Medium, High)
- Discount_Sensitivity (VARCHAR): Sensitivity to discounts (Not Sensitive, Somewhat Sensitive, Sensitive)
- Return_Rate (INT): Number of returns
- Customer_Satisfaction (INT): Satisfaction score (1-10)
- Engagement_with_Ads (VARCHAR): Ad engagement level (None, Low, Medium, High)
- Device_Used_for_Shopping (VARCHAR): Device used (Smartphone, Tablet, Desktop)
- Payment_Method (VARCHAR): Payment method used
- Time_of_Purchase (DATE): Date of purchase
- Discount_Used (BOOLEAN): Whether a discount was used
- Customer_Loyalty_Program_Member (BOOLEAN): Loyalty program membership
- Purchase_Intent (VARCHAR): Intent type (Need-based, Wants-based, Impulsive, Planned)
- Shipping_Preference (VARCHAR): Shipping preference (Standard, Express, No Preference)
- Time_to_Decision (INT): Days taken to decide purchase
- amount (FLOAT): Derived column for Purchase_Amount without '$'

## Questions
See [questions.md](questions.md) for a detailed list of SQL practice questions across six levels, covering basic queries, aggregations, subqueries, date functions, window functions, and business-oriented analysis.

## Solutions
See [solutions.sql](solutions.sql) for SQL queries addressing the questions in `questions.md`.

## Objective
This case study is designed to practice SQL skills, including data retrieval, aggregation, subqueries, window functions, and business analytics, while exploring ecommerce consumer behavior trends.