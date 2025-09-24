# DMart Case Study Questions

## Dataset Overview
The dataset consists of a single table, `dmart.qt.weekly_sales`, which captures weekly sales data for DMart. The table includes the following columns:
- **week_date** (VARCHAR): Start date of the sales week (DD/MM/YY).
- **region** (VARCHAR): Geographic region (e.g., ASIA, USA, EUROPE).
- **platform** (VARCHAR): Sales platform (Offline-Store or Online-Store).
- **segment** (VARCHAR): Customer segment based on age/demographic (e.g., C3, F1, or null).
- **customer_type** (VARCHAR): Customer type (New or Guest).
- **transactions** (INTEGER): Number of unique purchases.
- **sales** (INTEGER): Total sales value in rupees.

## Data Cleansing
Create a new table `dmart.qt.clean_weekly_sales` with the following transformations:
- Convert `week_date` to DATE format.
- Add `week_number` (e.g., 1 for Jan 1–7, 2 for Jan 8–14, etc.).
- Add `month_number` for the calendar month.
- Add `calendar_year` (2018, 2019, or 2020).
- Add `age_band` based on segment number (refer to provided mapping).
- Add `demographic` (Couples for 'C', Families for 'F').
- Replace null segment values with "unknown" in `segment`, `age_band`, and `demographic`.
- Add `avg_transaction` (sales/transactions, rounded to 2 decimal places).

## Data Exploration Questions
1. What day of the week does each `week_date` fall on?
2. What range of week numbers are missing from the dataset?
3. How many purchases were made in total for each year?
4. How much was sold in each region every month?
5. How many transactions happened on each platform?
6. What share of total sales came from Offline vs Online each month?
7. What percentage of total sales came from each demographic group each year?
8. Which age groups and demographic categories had the highest sales in physical stores?
9. Can we use the `avg_transaction` column to calculate average purchase size by year and platform? If not, how should we do it?

## Pre-Change vs Post-Change Analysis
Using `2020-06-15` as the baseline for sustainable packaging changes:
1. What is the total sales for the 4 weeks pre and post 2020-06-15? What is the growth/reduction rate in actual values and percentage?
2. What is the total sales for the 12 weeks pre and post 2020-06-15? What is the growth/reduction rate in actual values and percentage?
3. How do the sales metrics for these periods compare with 2018 and 2019?

## Bonus Question
Which areas of the business (`region`, `platform`, `age_band`, `demographic`, `customer_type`) had the highest negative impact on sales metrics in 2020 for the 12-week pre and post period?