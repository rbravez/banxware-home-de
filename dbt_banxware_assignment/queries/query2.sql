    WITH top_customers AS (
 SELECT 
     customer_id,
     SUM(total_sales_amount) AS total_spent
 FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
 WHERE order_year = 2023
 GROUP BY customer_id
 ORDER BY total_spent DESC
 LIMIT 5
 )

 SELECT 
     c.name,
     t.total_spent
 FROM top_customers t
 JOIN HOME_ASSIGNMENT.PUBLIC.RAW_CUSTOMER_DATA c ON t.customer_id = c.id
 ORDER BY t.total_spent DESC;
