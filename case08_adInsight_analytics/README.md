# AdInsight Customer Interest Analytics

## Problem Statement
AdInsight Analytics, a digital marketing agency, seeks to analyze customer behavior by examining online ad click trends. The goal is to uncover actionable insights into customer interests to optimize targeted marketing strategies for a major client.

## Dataset Description
The dataset is provided in [`data.sql`](dataset/data.sql), which creates the `adinsight_analytics` schema with two tables:
- **interest_metrics**: Contains monthly aggregated data on customer interactions with interests, including `month_year`, `interest_id`, `composition`, `index_value`, `ranking`, and `percentile_ranking`.
- **interest_map**: Maps `interest_id` to human-readable `interest_name` and `interest_summary`, along with `created_at` and `last_modified` timestamps.

### Tables Breakdown
- **interest_metrics**: Tracks engagement metrics (e.g., `composition` as the percentage of customers engaging with an interest, `index_value` comparing engagement to other clients).
- **interest_map**: Provides descriptive metadata for each interest, linking `id` to `interest_metrics.interest_id`.

## Questions
A set of analytical questions to explore the dataset is provided in [questions.md](questions.md).

## Solutions
SQL queries addressing the questions are provided in [solutions.sql](solutions.sql).

## Objective
This case study is designed to practice advanced SQL skills, including data cleansing, joins, aggregations, and window functions, while deriving business insights from customer behavior data for targeted marketing.