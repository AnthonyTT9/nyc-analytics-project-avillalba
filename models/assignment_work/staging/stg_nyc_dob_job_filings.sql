

WITH source  AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT * EXCEPT (
        zip, 
        proposed_height,
        existing_height,
        total_construction_floor_area,
        proposed_no_of_stories,
        proposed_dwelling_units,
        initial_cost,
        existing_dwelling_units
    ),
    CAST(proposed_height AS FLOAT) AS proposed_height,
    CAST(existing_height AS FLOAT) AS existing_height,
    CAST(total_construction_floor_area AS FLOAT) AS total_construction_floor_area,
    CASt(proposed_no_of_stories AS FLOAT) AS proposed_no_of_stories,
    CAST(proposed_dwelling_units AS FLOAT) AS proposed_dwelling_units,
    CAST(initial_cost AS FLOAT) AS initial_cost,
    CAST(existing_dwelling_units AS FLOAT) AS existing_dwelling_units

)