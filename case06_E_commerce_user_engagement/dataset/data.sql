
-- Case Study: E-Commerce User Engagement and Campaign Analysis
-- Schema Name: user_engagement
-- Short Project Description: This dataset represents user interactions on an e-commerce platform, including events like page views, add-to-cart actions, purchases, and ad engagements during promotional campaigns. It allows analysis of user behavior, session metrics, and campaign effectiveness.

-- Table Descriptions:
-- event_identifier: Maps numeric event types to descriptive names. Columns: event_type (integer ID), event_name (string description of the event).
-- campaign_identifier: Details on marketing campaigns. Columns: campaign_id (integer ID), products (string range of product IDs, e.g., '1-3'), campaign_name (string name), start_date (datetime start), end_date (datetime end).
-- page_hierarchy: Hierarchy of pages with associated products. Columns: page_id (integer ID), page_name (string name), product_category (string category, nullable), product_id (integer ID, nullable).
-- users: User profiles linking users to cookies over time. Columns: user_id (integer ID), cookie_id (string ID), start_date (date when cookie started).
-- events: Logged user events per visit. Columns: visit_id (string ID), cookie_id (string ID), page_id (integer), event_type (integer referencing event_identifier), sequence_number (integer order in visit), event_time (datetime2 timestamp).

CREATE SCHEMA user_engagement;
GO

-- Table: event_identifier
CREATE TABLE user_engagement.event_identifier (
  [event_type] INT,
  [event_name] VARCHAR(13)
);

INSERT INTO user_engagement.event_identifier ([event_type], [event_name])
VALUES
  (1, 'Page View'),
  (2, 'Add to Cart'),
  (3, 'Purchase'),
  (4, 'Ad Impression'),
  (5, 'Ad Click');

-- Table: campaign_identifier
CREATE TABLE user_engagement.campaign_identifier (
  [campaign_id] INT,
  [products] VARCHAR(3),
  [campaign_name] VARCHAR(33),
  [start_date] DATETIME,
  [end_date] DATETIME
);

INSERT INTO user_engagement.campaign_identifier (
  [campaign_id], [products], [campaign_name], [start_date], [end_date]
)
VALUES
  (1, '1-3', 'BOGOF - Festival Deals', '2020-01-01', '2020-01-14'),
  (2, '4-5', '25% Off - Wedding Essentials', '2020-01-15', '2020-01-28'),
  (3, '6-8', 'Half Off - New Year Bonanza', '2020-02-01', '2020-03-31');

-- Table: page_hierarchy
CREATE TABLE user_engagement.page_hierarchy (
  [page_id] INT,
  [page_name] VARCHAR(30),
  [product_category] VARCHAR(20),
  [product_id] INT
);

INSERT INTO user_engagement.page_hierarchy (
  [page_id], [page_name], [product_category], [product_id]
)
VALUES
  (1, 'Home Page', NULL, NULL),
  (2, 'All Products', NULL, NULL),
  (3, 'Men�s Kurta Collection', 'Ethnic Wear', 1),
  (4, 'Sarees & Lehengas', 'Ethnic Wear', 2),
  (5, 'Casual Footwear', 'Footwear', 3),
  (6, 'Designer Handbags', 'Accessories', 4),
  (7, 'Gold Plated Jewelry', 'Accessories', 5),
  (8, 'Smartphones', 'Electronics', 6),
  (9, 'Laptops', 'Electronics', 7),
  (10, 'Kitchen Appliances', 'Home & Kitchen', 8),
  (11, 'Decor & Furnishings', 'Home & Kitchen', 9),
  (12, 'Checkout', NULL, NULL),
  (13, 'Confirmation', NULL, NULL);

-- Table: users
CREATE TABLE user_engagement.users (
  user_id INT,
  cookie_id VARCHAR(6),
  start_date DATE
);

INSERT INTO user_engagement.users ([user_id], [cookie_id], [start_date])
VALUES
  (1, 'A1B2C3', '2020-01-01'),
  (2, 'D4E5F6', '2020-01-02'),
  (3, 'G7H8I9', '2020-01-03');
  -- Note: Full data may be in separate files like users_data.sql

-- Table: events
CREATE TABLE user_engagement.events (
  "visit_id" VARCHAR(6),
  "cookie_id" VARCHAR(6),
  "page_id" INTEGER,
  "event_type" INTEGER,
  "sequence_number" INTEGER,
  "event_time" DATETIME2
);
-- Note: Inserts for events are in separate files like events_data1.sql; no sample data provided here.