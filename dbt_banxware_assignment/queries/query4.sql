SELECT 
    customer_id, 
    COUNT(order_id) AS order_count
FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
WHERE order_year = 2023 
  AND order_month = 10
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 1