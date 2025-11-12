# Gaming Analytics with dbt

This dbt project provides a scalable and maintainable data model for analyzing gaming data. It follows the Medallion architecture to transform raw user metrics into clean, analytics-ready data marts.

## Architecture: The Medallion Model

The project is structured using the Bronze, Silver, and Gold layers:

*   **Bronze:** The raw source data (`game_analytics.raw_user_metrics`).
*   **Silver:** The staging models that clean and conform the raw data (`stg_user_daily_metrics`).
*   **Gold:** The final dimensional model (star schema) and aggregated data marts, ready for analytics.

### Gold Layer Models

The Gold layer is composed of a dimensional model and aggregated marts:

*   **Dimensions:**
    *   `dim_date`: A comprehensive date dimension.
    *   `dim_platform`: Platform dimension.
    *   `dim_country`: Country dimension.
    *   `dim_user`: A Type 2 Slowly Changing Dimension that tracks the history of user attributes.
*   **Facts:**
    *   `fact_daily_user_activity`: A fact table containing daily user activities and metrics, forming the core of the dimensional model.
*   **Marts:**
    *   `daily_metrics`: An aggregated table providing key business metrics like DAU and ARPDAU, built on top of the dimensional model.

## Setup and Run Instructions

1.  **Prerequisites:**
    *   dbt Core installed.
    *   A configured `profiles.yml` file with credentials for your BigQuery project.

2.  **Install dependencies:**
    *   Run the following command to install the required dbt packages:
        ```bash
        dbt deps
        ```

3.  **Run the project:**
    *   The recommended order of execution is:
        1.  **Run the staging and dimension models:**
            ```bash
            dbt run --exclude fact_daily_user_activity+
            ```
        2.  **Create the snapshots:**
            ```bash
            dbt snapshot
            ```
        3.  **Run the rest of the models** (the fact table and final mart):
            ```bash
            dbt run --select fact_daily_user_activity+
            ```
        4.  **Run the tests:**
            ```bash
            dbt test
            ```

## Models Overview

*   `models/staging/stg_user_daily_metrics.sql`: Cleans and prepares the raw source data.
*   `models/marts/dim_*.sql`: The dimension tables.
*   `snapshots/user_snapshot.sql`: The snapshot that builds the historical user dimension.
*   `models/marts/fact_daily_user_activity.sql`: The incremental fact table.
*   `models/marts/daily_metrics.sql`: The final aggregated mart.

## Potential Insights

This data model can be used to answer a wide range of business questions, such as:

*   What are the daily trends of DAU, revenue, and ARPDAU?
*   How do these metrics differ by country and platform?
*   What is the win/loss ratio of players?
*   How does user behavior change over time?