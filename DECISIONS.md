# Case Study Decisions Document - Junior Data Engineer Banxware
This project manages the end-to-end transformation of retail sales data using Snowflake and dbt. It ingests raw customer and sales data and transforms it into a "Silver" layer dataset where data is cleaned, types are cast, and key metrics are pre-calculated for downstream analysis performance. [Case study can be found here](https://bitbucket.org/panther-ci/data-engineering-home-assignment/src/main/). 

## Implementation
In order to complete this case study I followed the guide displayed in the *Setting Up Your Enviroment* section, which allowed me to set up my Snowflake account and the dbt configuration. I made sure everything was working properly using the command `dbt debug`. Once the connections was assured I move on to the next steps.  

In order to ingest both datasets into Snowflake I decided to go for the command `dbt seed` because of it's readiness of use and because it looked like the simpler option. In order to do this I had to manually move the datasets into the `seed` folder and rename them manually, which makes me think that if I had a lot of more datasets I would need some bash or python script to actually inegst them all (and rename them properly!). 

Once ingested I made the dbt model to allow the cast transformations, I optimized the query so that instead of performing transformations in the final output, I utilized a CT to handle type casting at the earliest possible stage, this reduces the CPU cycles required by the warehouse. 

I intentionally avoided `SELECT *` from the source table, choosing instead gto explicitly define the schema in the `base_sales` CTE. 

Finally, to ensure the model is self-documenting, I explicitly defined the final schema instead of using SELECT *. The final script is:
```sql
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
    order_id,
    customer_id,
    product_name,
    quantity,
    price,
    order_date_clean,
    YEAR(order_date_clean) AS order_year,
    MONTH(order_date_clean) AS order_month,
    DAY(order_date_clean) AS order_day,
    (quantity * price) AS total_sales_amount
FROM base_sales
```
As comparison, a not optimized query would look something like this
```sql
{{ config(materialized='table') }}

WITH base_sales AS (
    SELECT * FROM {{ ref('raw_sales_data') }}
)

SELECT
    *,
    YEAR(order_date:::date) AS order_year,
    MONTH(order_date::date) AS order_month,
    DAY(order_date::date) AS order_day,
    (quantity * price) AS total_sales_amount
FROM base_sales
```
## Results
The SQL queries to answer the specific business questions (Top products, top customers, etc) is located in the `queries/` folder. These scripts are designed to be run once the pipeline has finished. Answering the business questions:

1. What are the top 5 product by total sales in the year 2023?
   The query may be found in file `query1.sql`
   ```sql
   SELECT 
    product_name
    FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
    WHERE order_year = 2023
    GROUP BY product_name
    ORDER BY SUM(total_sales_amount) DESC
    LIMIT 5
   ```
   <img width="483" height="263" alt="{06CABF3F-BC03-48A2-B2F2-307EC16D2DDA}" src="https://github.com/user-attachments/assets/6517830b-f1b0-4bac-8e78-aab1a8ccd2e3" />

2. What are the names of the top 5 customers by total sales amount in the year 2023?
   
   **Some comments**: I used a CTE to get the top 5 `customer_id` in the `transformed_sales_data` before doing any type of join. This way the database only has to perform 5 join operations to get the customer names, rather than joining thousands of sales records to the customers table.
   ```sql
       WITH top_customers AS (
    -- Aggregate first to minimize join volume
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
   ```
   <img width="484" height="259" alt="{8CA3A927-0D4A-4069-9CF9-541C2C4949D2}" src="https://github.com/user-attachments/assets/67865ed0-67df-4b5d-80f6-6dc53f737700" />

    As seen in the image, it performs at 84ms while the not optimized query written as follows performs at 40ms. While this second query performs slightly faster at this current scale due to the lower scale of the data I structuctured the query to be architecturally scalable. As the sales table grows int the billions of rows, pre-aggregating before joining prevents heeavy joins. 
   ```sql
     SELECT
        c.name
    FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA s
    JOIN HOME_ASSIGNMENT.PUBLIC.RAW_CUSTOMER_DATA c ON s.customer_id = c.id
    WHERE s.order_year = 2023
    GROUP BY c.id, c.name
    ORDER BY SUM(s.total_sales_amount) DESC
    LIMIT 5; 
   ```
   <img width="485" height="271" alt="{E11FFDAB-3081-4204-8B57-45726A0EE171}" src="https://github.com/user-attachments/assets/a5664cf5-5a06-4f1d-bd5c-4746abbf84fe" />

3. What is the average order value for each month in the year 2023?

   Comments: I did use the function `ROUND` to round the final order values to the second decimal so it is shown more conveniently.

   ```sql
   SELECT 
    order_month, ROUND(AVG(total_sales_amount), 2)
    FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
    WHERE order_year = 2023
    GROUP BY order_month
    ORDER BY order_month ASC
   ```
    <img width="485" height="522" alt="{B554E5AF-97CF-40FA-A4B4-DF4E493A0543}" src="https://github.com/user-attachments/assets/781879d6-8641-468b-91ee-0216bf57a9dd" />

4. Which customers had the highest order volume in the month of October 2023?
   ```sql
   SELECT 
    customer_id, 
    COUNT(order_id) AS order_count
    FROM HOME_ASSIGNMENT.PUBLIC.TRANSFORMED_SALES_DATA
    WHERE order_year = 2023 
      AND order_month = 10
    GROUP BY customer_id
    ORDER BY order_count DESC
    LIMIT 1
