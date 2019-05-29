# Google-BigQuery-Airflow
This project aims to show how fast and easy data management via airflow and google works. 
This sample integrates the english premier league data into BigQuery ...

We load the data daily in [Google Cloud Storage](https://console.cloud.google.com/storage/browser).
The ETL job then starts automatically and imports the data into BigQuery to analyze the English Premier League data.

## Requirements
 * [Google Cloud SDK](https://cloud.google.com/sdk/install)
 * [jq](https://stedolan.github.io/jq/)

## [Google Deployment](https://cloud.google.com/composer/docs/quickstart)
Just run the `./scripts/google_init.sh` script which sets up a new GCP project, Cloud Composer- and BigQuery environment, 
and deploys this workflow, makes use of [jq](https://stedolan.github.io/jq/), a lightweight terminal application for json parsing and manipulation.
Most Linux distributions ship with it, but if you're running a Mac and don't want to set up a Linux VM, 
you can install it using `brew` (`brew install jq`) or refer to the [official docs](https://stedolan.github.io/jq/download/) for the latest binary.

In the configuration of the [Environment](https://console.cloud.google.com/composer) you get some information, including the Location of Bucket and the Airflow Web UI link.

### Upload Data
Run: `./scripts/google_upload_data.sh`

## Cleaning up
Run: `gcloud projects delete ${GC_PROJECT_ID}`
