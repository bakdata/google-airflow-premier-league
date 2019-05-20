#!/bin/bash

which gcloud

if [ $? -eq 1 ]
then
  echo "gcloud not installed" >&2
  exit 1
fi

gcloud auth login

gcloud organizations list
#read -p "What's your organization ID?: " org_id
export TF_VAR_org_id=711811781267

gcloud beta billing accounts list
#read -p "What's your billing ACCOUNT_ID?: " billing_account_id
export TF_VAR_billing_account=01FC04-43BC30-4AC293

export TF_ADMIN=${USER}-terraform-admin
export TF_CREDS=~/.config/gcloud/${TF_ADMIN}.json

echo "Path to credentials JSON: $TF_CREDS"
echo "Project: $TF_ADMIN"

echo "Create the Terraform Admin Project ..."
gcloud projects create ${TF_ADMIN} \
    --organization ${TF_VAR_org_id} --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
    --billing-account ${TF_VAR_billing_account}

echo "Create the Terraform service account ..."
gcloud iam service-accounts create terraform \
    --display-name "Terraform Service Account"

echo "Grant the service account permission to view the Admin Project and manage Cloud Storage:"
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/bigquery.admin

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/composer.admin

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com

echo "Grant the service account permission to create projects and assign billing accounts:"
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}

terraform init
terraform plan
terraform apply