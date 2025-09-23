### A. Customer and Plan Insights (Foodflix)

1. How many unique customers have ever signed up with Foodflix?

2. What is the monthly distribution of trial plan start dates in the dataset?

3. Which plan start dates occur after 2020?

4. What is the total number and percentage of customers who have churned?

5. How many customers churned immediately after their free trial?

6. What is the count and percentage of customers who transitioned to a paid plan after their initial trial?

7. As of 2020-12-31, what is the count and percentage of customers in each of the 5 plan types?

8. How many customers upgraded to an annual plan during the year 2020?

9. On average, how many days does it take for a customer to upgrade to an annual plan from their sign-up date?

10. Can you break down the average days to upgrade to an annual plan into 30-day intervals?

11. How many customers downgraded from a Pro Monthly to a Basic Monthly plan in 2020?

---

## Challenge – Payments Table for Foodflix (2020)

The Foodflix team would like you to generate a payments table for the year 2020 that reflects actual payment activity. The logic should include:

* Monthly payments are charged on the same day of the month as the start date of the plan.
* Upgrades from Basic to Pro plans are charged immediately, with the upgrade cost reduced by the amount already paid in that month.
* Upgrades from Pro Monthly to Pro Annual are charged at the end of the current monthly billing cycle, and the new plan starts at the end of that cycle.
* Once a customer churns, no further payments are made.

Example output rows for the payments table could include:
("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")

