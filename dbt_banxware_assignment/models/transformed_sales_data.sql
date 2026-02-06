{{ config(materialized='table') }}

WITH base_sales AS (
    SELECT 
        order_id,
        customer_id,
        product_name,
        quantity,
        price,
        order_date::date AS order_date_clean
    FROM {{ ref('raw_sales_data') }}
)

SELECT
    *,
    YEAR(order_date_clean) AS order_year,
    MONTH(order_date_clean) AS order_month,
    DAY(order_date_clean) AS order_day,
    (quantity * price) AS total_sales_amount
FROM base_sales