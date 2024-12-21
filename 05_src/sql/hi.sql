--temp 

--"if a table named ____ exists, delete it, otherwise do NOTHING
DROP TABLE IF EXISTS new_vendor_inventory;

--make the TABLE
CREATE TEMP TABLE new_vendor_inventory AS

--definition of the TABLE
SELECT *,
original_price*5 as inflation
FROM vendor_inventory;