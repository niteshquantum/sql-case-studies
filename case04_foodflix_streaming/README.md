# Case 04: FoodFlix Subscription Analysis

**Problem Statement:**  
Analyze FoodFlix subscription data to understand customer behavior, plan preferences, churn trends, and revenue impact.  
This case study focuses on transitions between free trials, paid plans, and churn, as well as monthly/annual revenue contributions.


## Dataset / Schema
All dataset creation scripts are located in `dataset/foodflix_data.sql`.

### Tables:
1. **plans** (plan_id, plan_name, price)  
   - Contains available subscription plans (trial, monthly, annual, churn).  

2. **subscriptions** (customer_id, plan_id, start_date)  
   - Records subscription activity: which plan a customer subscribed to and when.  
   - Multiple rows per customer possible (due to upgrades, downgrades, churn). 

**Questions:**  
- See `questions.md` for all  questions.

**Solutions:**  
- SQL queries are in `solutions.sql`,`solution_chalange.sql` ,`solution_psql.sql`.
