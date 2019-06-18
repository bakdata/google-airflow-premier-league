# Google-BigQuery-Airflow
This project aims to show how fast and easy data management via Airflow and Google Cloud Platform works. 
This sample integrates the English Premier League data into BigQuery.

We load the daily data in [Google Cloud Storage](https://console.cloud.google.com/storage/browser).
The ETL job then starts automatically and imports the data into BigQuery to analyze the data.

## Requirements
 * [Google Cloud SDK](https://cloud.google.com/sdk/install)
    * before start update components
        ```bash
        gcloud components update
        ```
    * Accessing a Cloud Composer environment requires the kubernetes commandline client [kubectl].
        ```bash
        gcloud components install kubectl
        ```
 * [jq](https://stedolan.github.io/jq/) - a lightweight terminal application for json parsing and manipulation

## [Google Deployment](https://cloud.google.com/composer/docs/quickstart)
Just run the `./scripts/google_init.sh` script which sets up a new GCP project, 
Cloud Composer, BigQuery and deploys this workflow.

In the configuration of the [Environment](https://console.cloud.google.com/composer) you get some information, including the location of Bucket and the Airflow Web UI link.

When the environment is in place, kick off the DAGs via the Airflow Web UI or run:
```bash
gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} trigger_dag -- matchweek_data_to_gc && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} list_dag_runs -- scorer_data_to_gc
```

### Upload Premier League Data
Upload the data to [Storage](https://console.cloud.google.com/storage) with:
```bash
./scripts/google_upload_data.sh
```

### Cleaning up
```bash
gcloud projects delete ${GC_PROJECT_ID}
```

## Local Deployment
Set the project ID as an environment variable.
```bash
export GC_PROJECT_ID=[YOU_GC_PROJECT_ID]
```
 
Create a key for the [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) 
and store to `airflow/data/keyfile.json`.

Start the Airflow Webserver: `docker-compose up`, then execute the `./scripts/local/init.sh` script to create variables and connections.

Airflow will be available via http://localhost:8080.

## Development
To set up a local development environment install pipenv: `pip install pipenv`.

Then install run `SLUGIFY_USES_TEXT_UNIDECODE=yes pipenv install`.

Open the folder with PyCharm and mark both `dags/` and `plugins/` as source folders.
