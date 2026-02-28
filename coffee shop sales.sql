--How have Maven Roasters sales trended over time?

SELECT 
  DATE_TRUNC('month',transaction_date) AS month,
  SUM(unit_price * transaction_qty) AS revenue
FROM coffee_shop_sales 
GROUP BY month
ORDER BY month; 


--Which days of the week tend to be busiest, and why do you think that's the case? 

SELECT 
 TO_CHAR(transaction_date,'Day') AS day_of_week,
 SUM(unit_price * transaction_qty) AS revenue,
 COUNT(DISTINCT transaction_id) AS transactions 
FROM coffee_shop_sales 
GROUP BY day_of_week 
ORDER BY revenue DESC
---
--Midweek days generate the highest revenue, with Thursday and Wednesday leading in both total sales and number of transactions.
--This suggests that Maven Roasters’ primary customer base consists of office workers who purchase coffee as part of their daily routine.
--Weekend sales are slightly lower, likely due to reduced commuting and more time spent at home or in leisure activities.

--- 


---Which products are sold most and least often? 
 --   Which drive the most revenue for the business? 

   --Best sellers  

SELECT product_type,
       SUM(transaction_qty) AS total_units_sold 
FROM coffee_shop_sales 
GROUP BY product_type
ORDER BY total_units_sold DESC 
LIMIT 10
   

-- Least popular

SELECT product_type,
       SUM(transaction_qty) AS total_units_sold 
FROM coffee_shop_sales 
GROUP BY product_type 
ORDER BY total_units_sold ASC 
LIMIT 10 

--Products with maximum revenue 
SELECT product_type, 
       SUM(unit_price * transaction_qty) AS revenue 
FROM coffee_shop_sales 
GROUP BY product_type 
ORDER BY revenue DESC 
LIMIT 10 


--Average order value (AOV) 


---Peak hours 

SELECT 
   EXTRACT(HOUR FROM transaction_time) AS hour, 
   SUM(unit_price * transaction_qty) AS revenue
FROM coffee_shop_sales 
GROUP BY hour 
ORDER BY revenue DESC

--Morning vs evening 
SELECT
  CASE
    WHEN EXTRACT(HOUR FROM transaction_time) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM transaction_time) < 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS day_part,
  SUM(unit_price * transaction_qty) AS revenue
FROM coffee_shop_sales
GROUP BY day_part
ORDER BY revenue DESC;

----Store Performance 
SELECT store_location,
       SUM(unit_price * transaction_qty) AS revenue 
FROM coffee_shop_sales 
GROUP BY store_location 
ORDER BY revenue DESC
	   
--Average check by location 
WITH orders AS (
  SELECT
    transaction_id,
    store_location,
    SUM(unit_price * transaction_qty) AS order_value
  FROM coffee_shop_sales
  GROUP BY transaction_id, store_location
)
SELECT
  store_location,
  ROUND(AVG(order_value),2) AS avg_check
FROM orders
GROUP BY store_location;


---Share of category in revenue 
SELECT product_category, 
ROUND(
  SUM(unit_price * transaction_qty) * 100.0 / 
  SUM(SUM(unit_price * transaction_qty)) OVER (),2 ) AS revenue_share_procent
FROM coffee_shop_sales 
GROUP BY product_category 
ORDER BY revenue_share_procent DESC

	   
--Top product in every location 
SELECT * 
FROM ( 
  SELECT  
      store_location,
	  product_type,
	  SUM(unit_price * transaction_qty) AS revenue, 
	  RANK () OVER(PARTITION BY store_location ORDER BY SUM(unit_price * transaction_qty)DESC) AS rnk
  FROM coffee_shop_sales 
  GROUP BY store_location,product_type
) AS t 
Where rnk = 1


SELECT
  transaction_date,
  SUM(unit_price * transaction_qty) AS revenue,
  AVG(SUM(unit_price * transaction_qty)) OVER (
    ORDER BY transaction_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS revenue_ma7
FROM coffee_shop_sales
GROUP BY transaction_date;











