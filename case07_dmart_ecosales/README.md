# Case 07: Dmart Ecosales

## Problem Statement
DMart, a fresh produce retailer, switched to sustainable packaging in June 2020. This case study analyzes the impact of this change on sales across regions, platforms, customer segments, and demographics, aiming to identify trends and strategies to mitigate future disruptions.

## Dataset Description
- **File**: `dataset/data.sql`
- **Schema**: `dmart.qt`
- **Table**: `weekly_sales`
  - **Columns**:
    - `week_date` (VARCHAR): Week start date (DD/MM/YY).
    - `region` (VARCHAR): Geographic region (e.g., ASIA, USA, EUROPE).
    - `platform` (VARCHAR): Sales platform (Offline-Store or Online-Store).
    - `segment` (VARCHAR): Customer segment (e.g., C3, F1, or null).
    - `customer_type` (VARCHAR): Customer type (New or Guest).
    - `transactions` (INTEGER): Number of unique purchases.
    - `sales` (INTEGER): Total sales value in rupees.
- **Description**: The dataset provides weekly sales summaries to analyze sales trends and the impact of sustainable packaging changes.

## DMart.md Context
The file `DMart.md` contains the original case study context, including the introduction, problem statement, and data details. It was sourced from the initial case study documentation and serves as the foundation for this analysis. Refer to [DMart.md](DMart.md) for background information on DMart's business and the sustainable packaging initiative.

## Questions
See [questions.md](questions.md) for data exploration and pre/post-change analysis questions.

## Solutions
SQL queries addressing the questions are available in [solutions.sql](solutions.sql).

## Objective
This case study helps practice SQL skills for data cleansing, aggregation, and time-based analysis, focusing on evaluating the business impact of sustainable packaging changes on sales metrics.