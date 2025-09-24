# Case 06: E-Commerce User Engagement and Campaign Analysis

## Detailed Problem Statement
This case study examines user engagement on an e-commerce platform featuring products like ethnic wear, electronics, and home goods during targeted promotional campaigns. The business focus is on optimizing marketing efforts by analyzing user journeys, ad interactions, and conversion funnels. The analysis emphasizes metrics such as user counts, session behaviors, cart additions, and campaign exposure to uncover insights into user retention, purchase patterns, and the impact of ads on overall engagement.

## Dataset Description

The dataset is provided inside the `dataset/` folder.  
- The main SQL script is [`data.sql`](dataset/data.sql), which creates the `user_engagement` schema and its tables with some sample insert statements.  
- Additional data files like [`users_data.sql`](dataset/users_data.sql) and [`events_data.sql`](dataset/events_data.sql) are also included for inserting extended sample data.

Schema Summary: Captures e-commerce events, users, pages, and campaigns for behavioral analysis.

Tables Breakdown:
- **event_identifier**: Event type mappings (e.g., Page View, Purchase).
- **campaign_identifier**: Campaign details including product ranges and durations.
- **page_hierarchy**: Page names with product categories and IDs.
- **users**: User-cookie linkages with start dates.
- **events**: Visit logs with timestamps, event types, and sequences.

## Questions Section
See [questions.md](questions.md) for the list of analysis questions.

## Solutions Section
See [solutions.sql](solutions.sql) for SQL queries addressing each question.

## Objective
This case study is designed to practice advanced SQL skills, including joins across tables, aggregations, window functions, string manipulations, and subqueries for data analysis. It helps in honing abilities to derive business insights from user behavior data, such as campaign effectiveness and user segmentation.