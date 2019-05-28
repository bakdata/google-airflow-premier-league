# Google-BigQuery-Airflow
This project aims to show how fast and easy data management via airflow and google works. 
This sample integrates the english premier league data into BigQuery ...

We load the data daily in [Google Cloud Storage](https://console.cloud.google.com/storage/browser).
The ETL job then starts automatically and imports the data into BigQuery to analyze the English Premier League data.

## Requirements

### Software
 * [Docker](https://docs.docker.com/v17.12/install/)
 * [Docker-Compose](https://docs.docker.com/compose/install/#install-compose)
 * [Google Cloud SDK](https://cloud.google.com/sdk/install)
 * [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
 
### [Google Cloud](https://console.cloud.google.com)
 * create Google Cloud Project
    * `export GC_PROJECT_ID=<my-google-cloud-project-id>`
 * https://console.cloud.google.com/apis/credentials/serviceaccountkey
 * https://console.developers.google.com/apis/library/iam.googleapis.com
    
### Configuration
Airflow Variables:
```json
{
  "bq_dataset_source": "staging",
  "bq_dataset_target": "warehouse",
  "bq_dataset_view": "view",
  "gc_project_id": "<gc_project_id>",
  "gcs_bucket": "<gcs_bucket_name>",
  "airflow_home": "/home/airflow/gcs/"
}
```

Connections:
```json
{
  "bigquery_default": {
  	"Project Id": "<gc_project_id>"
  },
  "google_cloud_default": {
  	"Project Id": "<gc_project_id>"
  }
}
```

## Local Deployment
 * Generate a Fernet Key (optional):
```bash
pip install cryptography && \
export AIRFLOW_FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY))"
```
More about that [here](https://airflow.readthedocs.io/en/stable/howto/secure-connections.html)

Then run `docker-compose up`

Airflow will be available via http://localhost:8080
Monitoring via Flower http://localhost:5555

After Container is started run `bash scripts/init_airflow.sh` for initialize [Connections](http://localhost:8080/admin/connection/) and [Variables](http://localhost:8080/admin/variable/)

## [Google Deployment](https://cloud.google.com/composer/docs/quickstart)

### Prerequisites

The `google_init.sh` script which sets up a new GCP project, Cloud Composer- and BigQuery environment, and deploys this workflow, makes use of [jq](https://stedolan.github.io/jq/), a lightweight terminal application for json parsing and manipulation.
Most Linux distributions ship with it, but if you're running a Mac and don't want to set up a Linux VM, you can install it using `brew` (`brew install jq`) or refer to the [official docs](https://stedolan.github.io/jq/download/) for the latest binary.


 * create environment on [Google Cloud Composer](https://console.cloud.google.com/composer/environments/create)
    * set Name, Node count (3) and the Location
    * finally choice Image (latest) and Python version (3)

In the configuration of the environment you get some information, including the Location of Bucket and the Airflow Web UI link.
Now deploy the DAG's and Plugins into the Bucket.

More about that [here](https://cloud.google.com/composer/docs/concepts)


## Development
To set up a local development environment install pipenv:
`pipenv install`

Then install run `SLUGIFY_USES_TEXT_UNIDECODE=yes pipenv install`

Open the folder with PyCharm and mark both `dags/` and `plugins/` as source folders.
