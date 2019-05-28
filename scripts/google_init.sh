#!/bin/bash

## Requirements
# https://cloud.google.com/sdk/docs/quickstart-linux
# curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-231.0.0-linux-x86_64.tar.gz
# tar zxvf google-cloud-sdk-231.0.0-linux-x86_64.tar.gz google-cloud-sdk
# ./google-cloud-sdk/install.sh
# gcloud components update
# new Shell ...
### Accessing a Cloud Composer environment requires the kubernetes commandline client [kubectl].
# gcloud components install kubectl

pushd $( dirname "${BASH_SOURCE[0]}" ) >/dev/null 2>&1

if ! [ -x "$(command -v gcloud)" ]; then
  echo 'Error: gcloud is not installed. After install (https://cloud.google.com/sdk/docs/quickstart-linux) open new shell.' >&2
  exit 1
fi

# gcloud auth login && \
echo "update gcloud components ..." && \
gcloud components update && \
echo "install gcloud component: kubectl ..." && \
gcloud components install kubectl && \

gcloud organizations list && \
read -p "Google Cloud Organization ID: " ORG_ID && \

gcloud beta billing accounts list && \
read -p "Google Cloud Billing ACCOUNT_ID: " BILLING_ID && \

#ORG_ID=711811781267 # gcloud organizations list
#BILLING_ID=01FC04-43BC30-4AC293 #gcloud beta billing accounts list
GC_PROJECT_ID=${USER}-premier-league
BQ_LOCATION="EU"
LOCATION=europe-west1
ZONE=europe-west1-b

### create project
echo "create project ..." && \
gcloud projects create ${GC_PROJECT_ID} \
  --organization ${ORG_ID} \
  --set-as-default && \

gcloud beta billing projects link ${GC_PROJECT_ID} \
  --billing-account ${BILLING_ID} && \

gcloud config set project ${GC_PROJECT_ID} && \

### activate services
echo "activate services ..." && \
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable cloudbilling.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable compute.googleapis.com && \
gcloud services enable composer.googleapis.com && \
gcloud services enable serviceusage.googleapis.com

### prepare datasets
#bq rm -rfd ${GC_PROJECT_ID}:staging && \
#bq rm -rfd ${GC_PROJECT_ID}:warehouse && \
#bq rm -rfd ${GC_PROJECT_ID}:view && \

### create datasets
echo "create datasets ..." && \
bq --location=$BQ_LOCATION mk --default_table_expiration 3600 --dataset ${GC_PROJECT_ID}:staging && \
bq --location=$BQ_LOCATION mk --dataset ${GC_PROJECT_ID}:warehouse && \
bq --location=$BQ_LOCATION mk --dataset ${GC_PROJECT_ID}:view  && \

### create tables
echo "create tables ..." && \
jq '.matchweek.schema += .matchweek.ext_schema' ../dags/description.json | jq -r '.matchweek.schema' > /tmp/matchweek.schema && \
bq --location=${BQ_LOCATION} mk --table ${GC_PROJECT_ID}:warehouse.matchweek /tmp/matchweek.schema && rm /tmp/matchweek.schema && \

jq '.scorer.schema += .scorer.ext_schema' ../dags/description.json | jq -r '.scorer.schema' > /tmp/scorer.schema && \
bq --location=${BQ_LOCATION} mk --table ${GC_PROJECT_ID}:warehouse.scorer /tmp/scorer.schema && rm /tmp/scorer.schema && \

### create views
echo "create views ..." && \
bash create_sql.sh $GC_PROJECT_ID ../data/view/matches.sql view.matches && \
bash create_sql.sh $GC_PROJECT_ID ../data/view/latest_result.sql view.latest_result && \
bash create_sql.sh $GC_PROJECT_ID ../data/view/league_table.sql view.league_table && \
bash create_sql.sh $GC_PROJECT_ID ../data/view/top_goal_scorers.sql view.top_goal_scorers && \

### create bucket
echo "create bucket ..." && \
#gsutil -m rm -r gs://${GC_PROJECT_ID} && \
gsutil mb -p ${GC_PROJECT_ID} -l ${BQ_LOCATION} -c multi_regional gs://${GC_PROJECT_ID}/ && \
gsutil -m cp ../data/matchweek/* gs://${GC_PROJECT_ID} && \
gsutil -m cp ../data/scorer/* gs://${GC_PROJECT_ID} && \

### create environment airflow
echo "create airflow environment ..." && \
gcloud beta composer environments create ${GC_PROJECT_ID} \
	--project=${GC_PROJECT_ID} \
	--location=${LOCATION} \
	--zone=$ZONE \
	--disk-size=50GB \
	--python-version=3 \
	--machine-type=n1-standard-1 \
	--image-version=composer-1.7.0-airflow-1.10 && \

### Airflow Connections
echo "create airflow connections ..." && \
gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} connections -- --delete \
	 --conn_id=bigquery_default && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} connections -- --add \
	 --conn_id=bigquery_default --conn_type=google_cloud_platform \
	 --conn_extra '{"extra__google_cloud_platform__project": "'${GC_PROJECT_ID}'", "extra__google_cloud_platform__key_path": "/home/airflow/gcs/dags/keyfile.json", "extra__google_cloud_platform__scope": "https://www.googleapis.com/auth/cloud-platform"}' && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} connections -- --delete \
	 --conn_id=google_cloud_default && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} connections -- --add \
	 --conn_id=google_cloud_default --conn_type=google_cloud_platform \
	 --conn_extra '{"extra__google_cloud_platform__project": "'${GC_PROJECT_ID}'", "extra__google_cloud_platform__key_path": "/home/airflow/gcs/dags/keyfile.json", "extra__google_cloud_platform__scope": "https://www.googleapis.com/auth/cloud-platform"}' && \

### Airflow Variables
echo "create airflow variables ..." && \
echo '{
		"bq_dataset_source": "staging", 
		"bq_dataset_target": "warehouse", 
		"bq_dataset_view": "view", 
		"gc_project_id": "'${GC_PROJECT_ID}'", 
		"gcs_bucket": "'${GC_PROJECT_ID}'"
	  }' > /tmp/variables.json && \

gcloud composer environments storage data import \
    --environment ${GC_PROJECT_ID} \
    --location ${LOCATION} \
    --source /tmp/variables.json && rm /tmp/variables.json && \

gcloud composer environments run ${GC_PROJECT_ID} \
	 --location ${LOCATION} variables -- --import /home/airflow/gcs/data/variables.json && \

## create gcp service account
echo "create gcp service account ..." && \
gcloud iam service-accounts create ${GC_PROJECT_ID} && \

gcloud projects add-iam-policy-binding ${GC_PROJECT_ID} \
  --member serviceAccount:${GC_PROJECT_ID}@${GC_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/editor && \

echo "create service account key ..." && \
gcloud iam service-accounts keys create /tmp/keyfile.json \
	--iam-account=${GC_PROJECT_ID}@${GC_PROJECT_ID}.iam.gserviceaccount.com && \

gcloud composer environments storage dags import \
    --environment ${GC_PROJECT_ID} \
    --location ${LOCATION} \
    --source /tmp/keyfile.json && rm /tmp/keyfile.json && \

### Airflow deploy DAG's
echo "deploy airflow DAG's" && \
BUCKET_NAME=$(gcloud composer environments describe ${GC_PROJECT_ID} --location ${LOCATION} --format="get(config.dagGcsPrefix)")
BUCKET_NAME=${BUCKET_NAME%dags}

bash google_deploy.sh && \

gsutil -m cp -r ../google_deploy/* ${BUCKET_NAME} 

#### Airflow trigger DAG's
#gcloud composer environments run ${GC_PROJECT_ID} \
#	 --location ${LOCATION} trigger_dag -- matchweek_data_to_gc && \
#
#gcloud composer environments run ${GC_PROJECT_ID} \
#	 --location ${LOCATION} list_dag_runs -- scorer_data_to_gc

### detroy project
#gcloud projects delete ${GC_PROJECT_ID}

popd >/dev/null 2>&1
