/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
  product_name || ', ' || 
  COALESCE(product_size, '') || ' (' || 
  COALESCE(product_qty_type, 'unit') || ')'
FROM product;

--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

SELECT 
customer_id
,market_date
,ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS visit_number
FROM customer_purchases;

/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

--Part 1
SELECT
customer_id
,market_date
,row_number() OVER (PARTITION BY customer_id ORDER BY market_date DESC) As visit_number_reversed
FROM customer_purchases;

--Part 2
--create temp table 
CREATE temp table NumberedVisits AS
SELECT 
customer_id
,market_date
,ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date DESC) AS visit_number
FROM customer_purchases;

--temp table to filter most recent visit
SELECT
customer_id
,market_date
FROM numbered_visits
WHERE visit_number = 1;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

SELECT
customer_id
,product_id
,market_date
,COUNT(*) OVER(PARTITION BY customer_id, product_id ORDER BY market_date DESC) AS product_purchase_count
FROM customer_purchases;

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT 
 product_name
,CASE 
    WHEN INSTR(product_name, ' - ') > 0 THEN TRIM(SUBSTR(product_name, INSTR(product_name, ' - ') + 3))
    ELSE NULL
  END AS description
FROM product;

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

SELECT product_name, product_size
FROM product
WHERE product_size REGEXP '\d';

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

-- Create a temporary table to store total sales per market date
CREATE temp table temp_total_sales_per_date AS
SELECT 
market_date
,SUM(quantity* cost_to_customer_per_qty) AS total_sales
FROM customer_purchases
GROUP BY market_date;

-- Create a second temporary table with ranking for best and worst day
CREATE temp table temp_ranked_sales AS
SELECT 
market_date,
total_sales,
-- Rank the market dates by total_sales (highest first) for best day
RANK() OVER (ORDER BY total_sales DESC) AS best_rank,
-- Rank the market dates by total_sales (lowest first) for worst day
RANK() OVER (ORDER BY total_sales ASC) AS worst_rank
FROM temp_total_sales_per_date;

--Query the second temporary table to get the best and worst days
SELECT market_date, total_sales
FROM temp_ranked_sales
WHERE best_rank = 1  -- Best day (highest total sales)
UNION
SELECT market_date, total_sales
FROM temp_ranked_sales
WHERE worst_rank = 1  -- Worst day (lowest total sales)
ORDER BY total_sales DESC;  -- order the result by total sales

/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

-- Calculate total revenue for each vendor-product assuming 5 units sold to each customer.
SELECT 
    v.vendor_name,
    p.product_name,
-- Revenue per product per customer (5 units per customer)
    (vi.original_price * 5) AS revenue_per_vendor_product,  
-- Total revenue for all customers (5 units sold to each customer)
    (vi.original_price * 5 * COUNT(DISTINCT c.customer_id)) AS total_revenue_per_product
FROM 
    vendor_inventory vi
JOIN 
    product p ON vi.product_id = p.product_id
JOIN 
    vendor v ON vi.vendor_id = v.vendor_id
JOIN
    customer c ON 1=1 -- Join with customer table to get the count of distinct customers
GROUP BY
    v.vendor_name, p.product_name, vi.original_price
ORDER BY 
    v.vendor_name, p.product_name;



-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

-- Create the product_units table with the required columns and snapshot_timestamp
CREATE TABLE product_units (
    product_id INTEGER,
    product_name VARCHAR,
    product_size VARCHAR,
    product_qty_type VARCHAR,
    product_category_id INTEGER,
    snapshot_timestamp TEXT 
);
--Insert data into the product_units table where product_qty_type = 'unit'
INSERT INTO product_units (product_id, product_name, product_size, product_qty_type, product_category_id, snapshot_timestamp)
SELECT 
    product_id, 
    product_name, 
    product_size, 
    product_qty_type, 
    product_category_id, 
    CURRENT_TIMESTAMP  
FROM 
    product
WHERE 
    product_qty_type = 'unit';


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

-- Insert a new row into the product_units table
INSERT INTO product_units (product_id, product_name, product_size, product_qty_type, product_category_id, snapshot_timestamp)
VALUES (
    9,                               -- product_id 
    'Sweet Potatoes',                     -- product_name
    'Medium',                         -- product_size
    'unit',                           -- product_qty_type
    4,                             -- product_category_id (example category ID)
    CURRENT_TIMESTAMP                -- snapshot_timestamp (current timestamp)
);


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

-- Delete the older record for Sweet Potatoes 
DELETE FROM product_units
WHERE product_id = 9
AND snapshot_timestamp < (SELECT MAX(snapshot_timestamp) FROM product_units WHERE product_id = 9);

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */


-- Add a new column current_quantity to the product_units table
ALTER TABLE product_units
ADD current_quantity INT;

UPDATE product_units
SET current_quantity = 0
WHERE product_id IN (6, 10, 12, 18, 19, 20, 21, 23, 9)
AND current_quantity IS NULL;

UPDATE product_units AS pu
SET current_quantity = (
    SELECT COALESCE(vi.quantity, 0) 
    FROM vendor_inventory vi
    WHERE vi.product_id = pu.product_id 
    ORDER BY vi.market_date DESC  
    LIMIT 1 
)
WHERE pu.product_id IN (
    SELECT vi.product_id
    FROM vendor_inventory vi 
)
OR pu.current_quantity IS NULL; 





