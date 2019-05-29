# Google-BigQuery-Airflow
This project aims to show how fast and easy data management via airflow and google works. 
This sample integrates the english premier league data into BigQuery ...

We load the data daily in [Google Cloud Storage](https://console.cloud.google.com/storage/browser).
The ETL job then starts automatically and imports the data into BigQuery to analyze the English Premier League data.

## Requirements
 * [Google Cloud SDK](https://cloud.google.com/sdk/install)
 * [jq](https://stedolan.github.io/jq/)

## [Google Deployment](https://cloud.google.com/composer/docs/quickstart)
Just run the script: `./scripts/google_init.sh`

In the configuration of the [Environment](https://console.cloud.google.com/composer) you get some information, including the Location of Bucket and the Airflow Web UI link.

### Upload Data
Run: `./scripts/google_upload_data.sh`

## Cleaning up
run `gcloud projects delete [PROJECT_ID]`