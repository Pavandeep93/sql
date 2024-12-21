--DISTINCT
--wihtout DISTINCT, only wed/sat 150x
SELECT market_day
FROM market_date_info;

--with DISTINCT, only once EACH
SELECT DISTINCT market_day
FROM market_date_info;

/* which vendor has sold product to a customer */
SELECT DISTINCT vendor_id
FROM customer_purchases;

/* which vendor has sold product to a customer and which proudct was it */
SELECT DISTINCT vendor_id, product_id
FROM customer_purchases;

/* which vendor has sold product to a customer and which proudct was it and which customer bought it */
SELECT DISTINCT vendor_id, product_id, customer_id
FROM customer_purchases
-- ORDER BY product_id, vendor_id, customer_id;


