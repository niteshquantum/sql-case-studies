# Case 11: Bike_Rental

## Introduction
Emily is the shop owner, and she would like to gather data to help her grow the business. She has hired you as an SQL specialist to get the answers to her business questions such as How many bikes does the shop own by category? What was the rental revenue for each month? etc. The answers are hidden in the database. You just need to figure out how to get them out using SQL.

## Dataset Description
The dataset is provided in `data.sql`, which creates the `bike_rental` database with five tables:
- **customer**: Stores details about the customers of the bike rental shop (`id`, `name`, `email`).
- **bike**: Stores information about bikes the rental shop owns (`id`, `model`, `category`, `price_per_hour`, `price_per_day`, `status`).
- **rental**: Matches customers with bikes they have rented (`id`, `customer_id`, `bike_id`, `start_timestamp`, `duration`, `total_paid`).
- **membership_type**: Contains information about different membership types for purchase (`id`, `name`, `description`, `price`).
- **membership**: Contains information about individual memberships purchased by customers (`id`, `membership_type_id`, `customer_id`, `start_date`, `end_date`, `total_paid`).

## Questions
See [questions.md](questions.md) for the list of business questions to be answered using SQL queries.

## Solutions
SQL solutions for the questions are provided in [solutions.sql](solutions.sql).

## Objective
This case study is designed to practice SQL skills, including joins, aggregations, grouping with subtotals, and conditional logic, to derive actionable business insights from a relational database.