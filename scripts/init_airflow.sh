#!/usr/bin/env bash
cd ..

CONNECTION_GOOGLE_EXTRAS='{"extra__google_cloud_platform__project": "'$GC_PROJECT_ID'", "extra__google_cloud_platform__scope": "https://www.googleapis.com/auth/cloud-platform"}'

docker-compose run --rm webserver airflow variables -s bq_dataset_source staging  && \
docker-compose run --rm webserver airflow variables -s bq_dataset_target warehouse && \
docker-compose run --rm webserver airflow variables -s bq_dataset_view view && \
docker-compose run --rm webserver airflow variables -s gc_project_id $GC_PROJECT_ID && \
docker-compose run --rm webserver airflow variables -s gcs_bucket english_premier_league && \
docker-compose run --rm webserver airflow variables -s airflow_home /usr/local/airflow && \
docker-compose run webserver airflow connections -d --conn_id=bigquery_default && \
docker-compose run webserver airflow connections -a --conn_id=bigquery_default --conn_type=google_cloud_platform --conn_extra "$CONNECTION_GOOGLE_EXTRAS" && \
docker-compose run --rm webserver airflow connections -d --conn_id=google_cloud_default && \
docker-compose run --rm webserver airflow connections -a --conn_id=google_cloud_default --conn_type=google_cloud_platform --conn_extra "$CONNECTION_GOOGLE_EXTRAS"
