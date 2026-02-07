SELECT 
 order_month, ROUND(AVG(total_sales_amount), 2)
 FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
 WHERE order_year = 2023
 GROUP BY order_month
 ORDER BY order_month ASC
