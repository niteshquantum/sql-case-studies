# Clothing Retail Insights - Questions

## Dataset Overview
The dataset consists of four tables under the schema `dt`:

1. **product_hierarchy**: Defines the hierarchy of products (Category → Segment → Style).
   - Columns: `id`, `parent_id`, `level_text`, `level_name`
2. **product_prices**: Stores product prices.
   - Columns: `id`, `product_id`, `price`
3. **product_details**: Contains detailed product information.
   - Columns: `product_id`, `price`, `product_name`, `category_id`, `segment_id`, `style_id`, `category_name`, `segment_name`, `style_name`
4. **sales**: Records sales transactions.
   - Columns: `prod_id`, `qty`, `price`, `discount`, `member`, `txn_id`, `start_txn_time`


## Question
## 📈 A. High Level Sales Analysis

**1. What was the total quantity sold for all products?**
**2. What is the total generated revenue for all products before discounts?**
**3. What was the total discount amount for all products?**

## 🧾 B. Transaction Analysis

**1. How many unique transactions were there?**
**2. What is the average unique products purchased in each transaction?**
**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**
**4. What is the average discount value per transaction?**
**5. What is the percentage split of all transactions for members vs non-members?**
**6. What is the average revenue for member transactions and non-member transactions?**


## 👚 C. Product Analysis

**1. What are the top 3 products by total revenue before discount?**
**2. What is the total quantity, revenue and discount for each segment?**
**3. What is the top selling product for each segment?**
**4. What is the total quantity, revenue and discount for each category?**
**5. What is the top selling product for each category?**
**6. What is the percentage split of revenue by product for each segment?**
**7. What is the percentage split of revenue by segment for each category?**
**8. What is the percentage split of total revenue by category?**
**9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**
**10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**

## 📝 Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the QT team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also QT) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

***

## 💡 Bonus Challenge

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

***