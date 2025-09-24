## Dataset Overview
This dataset is stored in the `user_engagement` schema and includes user interactions on an e-commerce platform. Key tables and columns:

- **event_identifier**: event_type (int), event_name (varchar) - Maps event codes to names like 'Page View', 'Add to Cart'.
- **campaign_identifier**: campaign_id (int), products (varchar), campaign_name (varchar), start_date (datetime), end_date (datetime) - Campaign details with product ranges and dates.
- **page_hierarchy**: page_id (int), page_name (varchar), product_category (varchar), product_id (int) - Page details with linked products and categories.
- **users**: user_id (int), cookie_id (varchar), start_date (date) - Links users to cookie IDs over time.
- **events**: visit_id (varchar), cookie_id (varchar), page_id (int), event_type (int), sequence_number (int), event_time (datetime2) - Logs events per visit.

## Questions

# SET A

1. How many distinct users are in the dataset?
2. What is the average number of cookie IDs per user?
3. What is the number of unique site visits by all users per month?
4. What is the count of each event type?
5. What percentage of visits resulted in a purchase?
6. What percentage of visits reached checkout but not purchase?
7. What are the top 3 most viewed pages?
8. What are the views and add-to-cart counts per product category?
9. What are the top 3 products by purchases?

# SET B

10. Create a product-level funnel table with views, cart adds, abandoned carts, and purchases.
11. Create a category-level funnel table with the same metrics as above.
12. Which product had the most views, cart adds, and purchases?
13. Which product was most likely to be abandoned?
14. Which product had the highest view-to-purchase conversion rate?
15. What is the average conversion rate from view to cart add?
16. What is the average conversion rate from cart add to purchase?

# SET C.

17. Create a visit-level summary table with user_id, visit_id, visit start time, event counts, and campaign name.
18. (Optional) Add a column for comma-separated cart products sorted by order of addition.

# Further Investigations

19. Identify users exposed to campaign impressions and compare metrics with those who were not.
20. Does clicking on an impression lead to higher purchase rates?
21. What is the uplift in purchase rate for users who clicked an impression vs. those who didn’t?
22. What metrics can be used to evaluate the success of each campaign?
