
-- use funtions
-- Create Schema
CREATE SCHEMA pizza_delivery_india;

-- Drop tables if exist
DROP TABLE IF EXISTS pizza_delivery_india.riders;
DROP TABLE IF EXISTS pizza_delivery_india.customer_orders;
DROP TABLE IF EXISTS pizza_delivery_india.rider_orders;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_names;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_recipes;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_toppings;

-- Riders Table
CREATE TABLE pizza_delivery_india.riders (
  rider_id INT,
  registration_date DATE
);

INSERT INTO pizza_delivery_india.riders (rider_id, registration_date) VALUES
  (1, '2023-01-01'),
  (2, '2023-01-05'),
  (3, '2023-01-10'),
  (4, '2023-01-15');

-- Customer Orders
CREATE TABLE pizza_delivery_india.customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(10),
  extras VARCHAR(10),
  order_time DATETIME
);

INSERT INTO pizza_delivery_india.customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 201, 1, '', '', '2023-01-01 18:05:02'),
  (2, 201, 1, '', '', '2023-01-01 19:00:52'),
  (3, 202, 1, '', '', '2023-01-02 23:51:23'),
  (3, 202, 2, '', NULL, '2023-01-02 23:51:23'),
  (4, 203, 1, '4', '', '2023-01-04 13:23:46'),
  (4, 203, 2, '4', '', '2023-01-04 13:23:46'),
  (5, 204, 1, NULL, '1', '2023-01-08 21:00:29'),
  (6, 201, 2, NULL, NULL, '2023-01-08 21:03:13'),
  (7, 205, 2, NULL, '1', '2023-01-08 21:20:29'),
  (8, 202, 1, NULL, NULL, '2023-01-09 23:54:33'),
  (9, 203, 1, '4', '1, 5', '2023-01-10 11:22:59'),
  (10, 204, 1, NULL, NULL, '2023-01-11 18:34:49'),
  (10, 204, 1, '2, 6', '1, 4', '2023-01-11 18:34:49');

-- Rider Orders
CREATE TABLE pizza_delivery_india.rider_orders (
  order_id INT,
  rider_id INT,
  pickup_time VARCHAR(20),
  distance VARCHAR(10),
  duration VARCHAR(15),
  cancellation VARCHAR(50)
);

INSERT INTO pizza_delivery_india.rider_orders (order_id, rider_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2023-01-01 18:15:34', '5km', '32 minutes', ''),
  (2, 1, '2023-01-01 19:10:54', '6km', '27 minutes', ''),
  (3, 1, '2023-01-03 00:12:37', '4.2km', '20 mins', NULL),
  (4, 2, '2023-01-04 13:53:03', '5.5km', '40', NULL),
  (5, 3, '2023-01-08 21:10:57', '3.3km', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2023-01-08 21:30:45', '6.1km', '25mins', NULL),
  (8, 2, '2023-01-10 00:15:02', '7.2km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2023-01-11 18:50:20', '2.8km', '10minutes', NULL);

-- Pizza Names
CREATE TABLE pizza_delivery_india.pizza_names (
  pizza_id INT,
  pizza_name NVARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Paneer Tikka'),
  (2, 'Veggie Delight');

-- Pizza Recipes
CREATE TABLE pizza_delivery_india.pizza_recipes (
  pizza_id INT,
  toppings NVARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- Pizza Toppings
CREATE TABLE pizza_delivery_india.pizza_toppings (
  topping_id INT,
  topping_name NVARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Paneer'),
  (2, 'Schezwan Sauce'),
  (3, 'Tandoori Chicken'),
  (4, 'Cheese'),
  (5, 'Corn'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Capsicum'),
  (9, 'Red Peppers'),
  (10, 'Black Olives'),
  (11, 'Tomatoes'),
  (12, 'Mint Mayo');
