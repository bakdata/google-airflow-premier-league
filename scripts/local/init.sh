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

### create tables
echo "create tables ..." && \
jq '.matchweek.schema += .matchweek.ext_schema' ../../airflow/dags/description.json | jq -r '.matchweek.schema' > /tmp/matchweek.schema && \
bq --location=${BQ_LOCATION} mk --table ${GC_PROJECT_ID}:warehouse.matchweek /tmp/matchweek.schema && rm /tmp/matchweek.schema && \

jq '.scorer.schema += .scorer.ext_schema' ../../airflow/dags/description.json | jq -r '.scorer.schema' > /tmp/scorer.schema && \
bq --location=${BQ_LOCATION} mk --table ${GC_PROJECT_ID}:warehouse.scorer /tmp/scorer.schema && rm /tmp/scorer.schema && \

### create views
echo "create views ..." && \
bash ../create_sql.sh $GC_PROJECT_ID ../../bq/sql/matches.sql view.matches && \
bash ../create_sql.sh $GC_PROJECT_ID ../../bq/sql/latest_result.sql view.latest_result && \
bash ../create_sql.sh $GC_PROJECT_ID ../../bq/sql/league_table.sql view.league_table && \
bash ../create_sql.sh $GC_PROJECT_ID ../../bq/sql/top_goal_scorers.sql view.top_goal_scorers

popd >/dev/null 2>&1