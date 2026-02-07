# Case Study Running Guide - Junior Data Engineer Banxwar
This project manages the end-to-end transformation of retail sales data using Snowflake and dbt. It ingests raw customer and sales data and transforms it into a "Silver" layer dataset where data is cleaned, types are cast, and key metrics are pre-calculated for downstream analysis performance. [Case study can be found here](https://bitbucket.org/panther-ci/data-engineering-home-assignment/src/main/). While the documentation for the decisions made [can be found here at the DECISIONS.md file](https://github.com/rbravez/banxware-home-de/edit/main/DECISIONS.md)

## Project Structure  
```
root/
└── dbt_banxware_assignment/
    ├── models/                   # Contains transformed_sales_data.sql
    ├── seeds/                    # Contains raw_sales_data.csv & raw_customer_data.csv
    ├── queries/                  # The 4 .sql files answering the questions
    │   ├── top_5_products_2023.sql
    │   ├── top_5_customers_2023.sql
    │   ├── avg_order_value_2023.sql
    │   └── highest_volume_oct_2023.sql
    ├── dbt_project.yml           
    └── (other dbt folders)       
├── README.md                     
├── DECISIONS.md                  
└── .gitignore                   
```

## How to run it
**1. Prerequisites**
   - Python 3.10+
   - Snowflake account with a database named HOME_ASSIGMENT
   - dbt-snowflake adapter installed
     
**2. Set up**

  Clone this repository and set up the virtual enviroment. You must have a `profiles.yml` file located in your `~/.dbt/` directory for the connection to work.

  ```bash
python -m venv .venv
# Windows:
.\.venv\Scripts\Activate.ps1
# Mac/Linux:
source .venv/bin/activate

pip install dbt-snowflake
```
**3. Running the pipeline**

  Navigate to the project directory and run the following commands

  ```bash
cd dbt_banxware_assignment
dbt debug   # Verifying connection and set up
dbt seed    # Load raw csv data into snowflake
dbt run     # Run pipeline
```

Or alternatively (and more easily) just run `dbt build` inside the `dbt_banxware_assignment` directory.

