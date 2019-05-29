# Google-BigQuery-Airflow
This project aims to show how fast and easy data management via airflow and google works. 
This sample integrates the english premier league data into BigQuery ...

We load the data daily in [Google Cloud Storage](https://console.cloud.google.com/storage/browser).
The ETL job then starts automatically and imports the data into BigQuery to analyze the English Premier League data.

## Requirements
 * [Google Cloud SDK](https://cloud.google.com/sdk/install)
 * [jq](https://stedolan.github.io/jq/) (a lightweight terminal application for json parsing and manipulation)

## [Google Deployment](https://cloud.google.com/composer/docs/quickstart)
Just run the `./scripts/google_init.sh` script which sets up a new GCP project, 
Cloud Composer- and BigQuery environment, and deploys this workflow.

In the configuration of the [Environment](https://console.cloud.google.com/composer) you get some information, including the Location of Bucket and the Airflow Web UI link.

If environment running, run the DAG's over the Airflow Web UI or run:
```bash
gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} trigger_dag -- matchweek_data_to_gc && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} list_dag_runs -- scorer_data_to_gc
```

### Upload Premier League Data
After then upload the data to [Storage](https://console.cloud.google.com/storage), just run: `./scripts/google_upload_data.sh`


## Cleaning up
Run: `gcloud projects delete ${GC_PROJECT_ID}`
