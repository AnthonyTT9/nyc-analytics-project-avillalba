## Overview

This project builds a data warehouse that combines two NYC Open Data sources:
- **DOHMH Restaurant Inspection Results:** one row per violation per inspection
- **311 Service Requests:** requests about restaurants and food establishments


The pipeline follows an ELT pattern: raw data is loaded into BigQuery first, then transformed inside the warehouse with dbt.

1. **Extract and Load:** Cloud Run functions, triggered by Cloud Scheduler, pull data from the NYC Open Data (Socrata) API and load it into BigQuery as raw tables.
2. **Transform (dbt):** dbt models clean the raw tables into staging tables.
3. **Marts (next step):** staging tables will feed dimensional models (Kimball Dimensional Model).

At the end there will be 8 dimensions and 2 fact tables.
