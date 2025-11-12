# Data Warehouse Architecture Proposal

This document outlines the proposed Data Warehouse (DWH) architecture for analyzing gaming data. The architecture is designed to be scalable, performant, and cost-effective, supporting a wide range of analytical use cases.

## 1. DWH Architecture: The Medallion Model

The architecture follows the industry-standard Medallion model, which organizes data into three distinct layers: Bronze, Silver, and Gold.

```
---------------------------------
|         BRONZE LAYER          |
| (Raw, Untouched Source Data)  |
---------------------------------
             |
             v
---------------------------------
|         SILVER LAYER          |
| (Cleaned, Conformed Data)     |
---------------------------------
             |
             v
---------------------------------
|          GOLD LAYER           |
| (Analytics-Ready Data Marts)  |
---------------------------------
```

*   **Bronze Layer:** Raw, immutable data is ingested into the `raw_user_metrics` table. This layer provides a historical archive of the source data.
*   **Silver Layer:** The `stg_user_daily_metrics` model cleans, standardizes, and conforms the raw data, preparing it for the Gold layer.
*   **Gold Layer:** This layer contains the analytics-ready data, structured as a dimensional model (star schema) for easy querying and a pre-aggregated data mart for reporting.
    *   **Dimensional Model:** `dim_date`, `dim_platform`, `dim_country`, `dim_user`, and `fact_daily_user_activity`.
    *   **Aggregated Mart:** `daily_metrics`.

## 2. Data Model: Star Schema

The core of the Gold layer is a star schema, which is optimized for analytical queries.

*   **Fact Table:** `fact_daily_user_activity`
    *   Contains quantitative measures of user activity (e.g., revenue, session counts, match counts).
    *   Each row represents a user's activity for a single day.
*   **Dimension Tables:**
    *   `dim_user`: Stores information about each user.
    *   `dim_date`: A comprehensive date dimension for time-based analysis.
    *   `dim_platform`: Stores platform information (e.g., Android, iOS).
    *   `dim_country`: Stores country information.

This model allows analysts to easily slice and dice the data by different attributes (user, time, platform, country) to uncover insights.

## 3. Incremental Loading & Historical Tracking

To ensure the DWH is scalable and efficient, we employ the following strategies:

*   **Incremental Loading:** The main fact table, `fact_daily_user_activity`, is built as an incremental model in dbt. This means that on each run, only new or updated data is processed, dramatically reducing query costs and pipeline run times.
*   **Historical Data Tracking (SCD Type 2):** The `dim_user` dimension is a Type 2 Slowly Changing Dimension, built using a dbt snapshot. This allows us to track changes to user attributes over time (e.g., if a user changes their country), providing a complete historical view of user data.

## 4. Production Orchestration Flow

For a production environment, we propose the following automated orchestration flow using Google Cloud services:

```
--------------------      --------------------      --------------------
|   Data Sources   |----->|  Ingestion Layer   |----->|    Bronze Layer    |
| (Game Servers)   |      | (Pub/Sub, Dataflow)|      | (BigQuery Raw Data)|
--------------------      --------------------      --------------------
                                                           |
                                                           v
--------------------      --------------------      --------------------
|  Orchestration   |<---->| Transformation     |<---->|   Silver & Gold  |
| (Cloud Composer) |      |      (dbt)         |      | (BigQuery Modeled)|
--------------------      --------------------      --------------------
```

1.  **Ingestion:** Data is streamed from game servers via Pub/Sub and loaded into the Bronze layer in BigQuery.
2.  **Orchestration:** A Cloud Composer (managed Airflow) DAG is scheduled to run the transformation pipeline periodically.
3.  **Transformation:** The DAG triggers `dbt run` to update the Silver and Gold tables incrementally.
4.  **Data Quality:** After the run, `dbt test` is triggered to ensure data integrity.

## 5. Performance & Cost Optimization

The following strategies are implemented to ensure the DWH is performant and cost-effective:

*   **Incremental Models:** Reduces the volume of data processed in each dbt run.
*   **BigQuery Partitioning & Clustering:** The fact table will be partitioned by date and clustered by `platform_key` and `country_key` to minimize the amount of data scanned in queries.
*   **Optimized Joins:** The star schema uses surrogate integer keys, which are more performant for joins than string keys.
*   **Aggregated Marts:** The `daily_metrics` table pre-calculates key business metrics, providing fast query performance for dashboards and reports.
