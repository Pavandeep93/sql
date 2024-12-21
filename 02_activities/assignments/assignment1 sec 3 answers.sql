--AGGREGATE

--Write a query that determines how many times each vendor has rented a booth at the farmer’s market by counting the vendor booth assignments per vendor_id.

SELECT vendor_id,count(booth_number) as booth_rentals
FROM vendor_booth_assignments
GROUP BY vendor_id;

--The Farmer’s Market Customer Appreciation Committee wants to give a bumper sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list of customers for them to give stickers to, sorted by last name, then first name.*/

SELECT c.customer_id
,customer_first_name
,customer_last_name
,SUM(quantity*cost_to_customer_per_qty) AS total_spent
FROM customer AS c
   INNER JOIN customer_purchases as cp
   ON c.customer_id = cp.customer_id
GROUP BY c.customer_id
HAVING SUM(quantity *cost_to_customer_per_qty) > 2000
ORDER BY customer_last_name, customer_first_name;

--Temp Table

--Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosentha


CREATE TEMP TABLE temp.new_vendor AS
SELECT * 
FROM vendor;

INSERT INTO temp.new_vendor (vendor_id, vendor_name, vendor_type, vendor_owner_first_name, vendor_owner_last_name)
VALUES (10, 'Thomass Superfood Store', 'Fresh Focused store', 'Thomas', 'Rosenthal');

--Date

--Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

SELECT customer_id
,strftime('%m', market_date) AS month
,strftime('%Y', market_date) AS year
FROM customer_purchases;

--Using the previous query as a base, determine how much money each customer spent in April 2022. Remember that money spent is quantity*cost_to_customer_per_qty.
--HINTS: you will need to AGGREGATE, GROUP BY, and filter...but remember, STRFTIME returns a STRING for your WHERE statement!!

SELECT customer_id
,SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM customer_purchases
WHERE strftime('%Y-%m', market_date) = '2022-04'
GROUP BY customer_id;
