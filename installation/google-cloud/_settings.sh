#!/usr/bin/env bash

set -euxo pipefail

# GCloud settings
PROJECT_ID="os2display-kff"
REGION="europe-west1"
ZONE="europe-west1-b"
ADDRESS_NAME="os2display-ingress-ip"
# Cluster settings
CLUSTER_NAME="os2kff-cluster-1"
MACHINE_TYPE="n1-standard-4"
CLUSTER_VER="1.11.2-gke.18"
NUM_NODES=1
MAINTENANCE="02:30" # UTC
# Set this after running 01-setup-cluster.sh
EXTERNAL_IP="35.233.40.250"
