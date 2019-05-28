#!/usr/bin/env bash

set -euxo pipefail

# GCloud settings
PROJECT_ID="[insert-project-id-here]"
REGION="[insert-region-here]"
ZONE="[insert-zone-here]"
ADDRESS_NAME="os2display-ingress-ip"
# Cluster settings
CLUSTER_NAME="[insert-cluster-name-here]"
MACHINE_TYPE="n1-standard-4"
CLUSTER_VER="[insert-cluster-version-here]"
NUM_NODES=1
MAINTENANCE="02:30" # UTC

# Set this after running 01-setup-cluster.sh
# EXTERNAL_IP="[insert-ip-address-here]"
