#!/usr/bin/env bash

pushd $( dirname "${BASH_SOURCE[0]}" ) >/dev/null 2>&1

CONNECTION_GOOGLE_EXTRAS='{"extra__google_cloud_platform__project": "'$GC_PROJECT_ID'", "extra__google_cloud_platform__key_path": "/usr/local/airflow/data/keyfile.json"}'

docker-compose run --rm webserver airflow variables -s bq_dataset_source staging  && \
docker-compose run --rm webserver airflow variables -s bq_dataset_target warehouse && \
docker-compose run --rm webserver airflow variables -s bq_dataset_view view && \
docker-compose run --rm webserver airflow variables -s gc_project_id $GC_PROJECT_ID && \
docker-compose run --rm webserver airflow variables -s gcs_bucket $GC_PROJECT_ID && \
docker-compose run webserver airflow connections -d --conn_id=bigquery_default && \
docker-compose run webserver airflow connections -a --conn_id=bigquery_default --conn_type=google_cloud_platform --conn_extra "$CONNECTION_GOOGLE_EXTRAS" && \
docker-compose run --rm webserver airflow connections -d --conn_id=google_cloud_default && \
docker-compose run --rm webserver airflow connections -a --conn_id=google_cloud_default --conn_type=google_cloud_platform --conn_extra "$CONNECTION_GOOGLE_EXTRAS"

popd >/dev/null 2>&1