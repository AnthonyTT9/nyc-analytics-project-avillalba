

WITH source  AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            zip, 
            proposed_height,
            existing_height,
            total_construction_floor_area,
            proposed_no_of_stories,
            proposed_dwelling_units,
            initial_cost,
            existing_dwelling_units
        ),
        CAST(proposed_height AS FLOAT64) AS proposed_height,
        CAST(existing_height AS FLOAT64) AS existing_height,
        CAST(total_construction_floor_area AS FLOAT64) AS total_construction_floor_area,
        CAST(proposed_no_of_stories AS FLOAT64) AS proposed_no_of_stories,
        CAST(proposed_dwelling_units AS FLOAT64) AS proposed_dwelling_units,
        CAST(initial_cost AS FLOAT64) AS initial_cost,
        CAST(existing_dwelling_units AS FLOAT64) AS existing_dwelling_units,
        
        CASE
            WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA') THEN NULL
            WHEN UPPER(TRIM(CAST(zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
            WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
            WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
            WHEN LENGTH(CAST(zip AS STRING)) = 10
                AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
            THEN CAST(zip AS STRING)
            ELSE NULL
        END AS zip

    FROM source

    WHERE CAST(filing_date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 YEAR)
    AND job_filing_number IS NOT null
    AND filing_date IS NOT null

    QUALIFY ROW_NUMBER() OVER (PARTITION BY job_filing_number ORDER BY filing_date DESC) = 1
)

SELECT *
FROM cleaned