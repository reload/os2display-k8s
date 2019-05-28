#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

# Config
gcloud config set container/new_scopes_behavior true

# Enable services
gcloud services enable compute.googleapis.com --project=$PROJECT_ID
gcloud services enable sql-component.googleapis.com --project=$PROJECT_ID

# Ingress IP
gcloud compute addresses create $ADDRESS_NAME --region=$REGION --project=$PROJECT_ID --region=$REGION
gcloud compute addresses describe $ADDRESS_NAME --region $REGION --project=$PROJECT_ID --region=$REGION

# Provision machines
gcloud container clusters create $CLUSTER_NAME \
    --cluster-version=$CLUSTER_VER \
    --enable-autorepair \
    --enable-autoupgrade \
    --issue-client-certificate \
    --machine-type=$MACHINE_TYPE \
    --maintenance-window=$MAINTENANCE \
    --num-nodes=$NUM_NODES \
    --scopes=gke-default \
    --region=$REGION \
    --node-locations=$ZONE \
    --project=$PROJECT_ID

