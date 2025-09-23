/* Welcome to Cloud Bank – The Future of Digital Banking & Cloud Storage
The financial industry is undergoing a digital revolution with the rise of Neo-Banks — modern, fully digital banks that operate without physical branches.

Amidst this transformation, We envisioned a futuristic blend of digital banking, cloud technology, and the world of data. This vision gave rise to Cloud Bank — a next-generation platform that combines traditional banking with distributed, secure cloud storage.

Cloud Bank works like any other digital bank for day-to-day financial activities. However, it also offers a powerful twist: each customer is provided with cloud data storage—and the amount of storage is dynamically linked to their account balance.

This hybrid banking-cloud model opens up new frontiers, but also presents unique challenges. That’s where you come in.

The Cloud Bank leadership team aims to expand their customer base and needs data-driven insights to:

Forecast data storage requirements.

Understand customer behavior and growth patterns.

Optimize resource allocation and future planning.

This case study challenges you to analyze real-world metrics, growth trends, and operational data to help Cloud Bank make smart, scalable business decisions.
*/

Cloud Bank Case Study Questions

A. Customer Node Exploration
How many unique nodes exist within the Cloud Bank system?

What is the distribution of nodes across different regions?

How many customers are allocated to each region?

On average, how many days does a customer stay on a node before being reallocated?

What are the median, 80th percentile, and 95th percentile reallocation durations (in days) for customers in each region?

B. Customer Transactions
What are the unique counts and total amounts for each transaction type (e.g., deposit, withdrawal, purchase)?

What is the average number of historical deposits per customer, along with the average total deposit amount?

For each month, how many Cloud Bank customers made more than one deposit and either one purchase or one withdrawal?

What is the closing balance for each customer at the end of every month?

What percentage of customers increased their closing balance by more than 5% month-over-month?

C. Cloud Storage Allocation Challenge
The Cloud Bank team is experimenting with three storage allocation strategies:

Option 1: Storage is provisioned based on the account balance at the end of the previous month

Option 2: Storage is based on the average daily balance over the previous 30 days

Option 3: Storage is updated in real-time, reflecting the balance after every transaction

To support this analysis, generate the following:

A running balance for each customer that accounts for all transaction activity

The end-of-month balance for every customer

The minimum, average, and maximum running balances per customer

Using this data, estimate how much cloud storage would have been required for each allocation option on a monthly basis.

D. Advanced Challenge: Interest-Based Data Growth
Cloud Bank wants to test a more complex data allocation method: applying an interest-based growth model similar to traditional savings accounts.

If the annual interest rate is 6%, how much additional cloud storage would customers receive if:

Interest is calculated daily, without compounding?

(Optional Bonus) Interest is calculated daily with compounding?
