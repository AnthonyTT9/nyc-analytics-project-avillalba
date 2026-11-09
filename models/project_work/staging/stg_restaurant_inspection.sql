WITH source AS (
   SELECT * FROM {{ source('raw', 'dohmh_restaurant_inspection_data') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            camis,
            dba,
            cuisine_description,
            inspection_date,
            grade_date,
            record_date,
            zipcode,
            boro,            
            grade,
            critical_flag
        ),
        -- Renaming columns 
        CAST(camis AS STRING) AS unique_id,
        CAST(dba AS STRING) AS restaurant_name,
        CAST(cuisine_description AS STRING) AS cuisine_type,

        -- Time/date columns
        CAST(inspection_date AS TIMESTAMP) AS inspection_date,
        CAST(grade_date AS TIMESTAMP) AS grade_date,
        CAST(record_date AS TIMESTAMP) AS record_date,

        -- Cleaning Zip (only contains zipcode of length 5 so not much needed)
        CASE
            WHEN UPPER(TRIM(CAST(zipcode AS STRING))) IN ('N/A', 'NA') THEN NULL
            WHEN LENGTH(CAST(zipcode AS STRING)) = 5 THEN CAST(zipcode AS STRING)
            -- handle future zips
            WHEN LENGTH(CAST(zipcode AS STRING)) = 9 THEN CAST(zipcode AS STRING)
            WHEN LENGTH(CAST(zipcode AS STRING)) = 10
                AND REGEXP_CONTAINS(CAST(zipcode AS STRING), r'^\d{5}-\d{4}')
            THEN CAST(zipcode AS STRING)            
            ELSE NULL
        END AS zip, -- consistent name for confomred dim

        -- Cleaning borough
        CASE
            WHEN UPPER(TRIM(boro)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
            WHEN UPPER(TRIM(boro)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(boro)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
            WHEN UPPER(TRIM(boro)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
            WHEN UPPER(TRIM(boro)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
            ELSE 'UNKNOWN or CITYWIDE'
        END AS borough,

        -- Metrics
        UPPER(TRIM(CAST(grade AS STRING))) AS grade,
        UPPER(TRIM(CAST(critical_flag AS STRING))) AS critical_flag,

        CASE
            WHEN UPPER(TRIM(critical_flag)) = 'CRITICAL' THEN TRUE
            WHEN UPPER(TRIM(critical_flag)) = 'NOT CRITICAL' THEN FALSE
            ELSE NULL
        END AS is_critical,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Filters
    WHERE camis IS NOT NULL
    AND inspection_date IS NOT NULL
    AND borough IS NOT NULL

    -- Deduplicate
    QUALIFY ROW_NUMBER() OVER (PARTITION BY camis, inspection_date, violation_code, inspection_type ORDER BY inspection_date DESC) = 1
)
SELECT * FROM cleaned