WITH source AS (
   SELECT * FROM {{ source('raw', 'dohmh_restaurant_inspection_data') }}
),

cleaned AS (
    
)