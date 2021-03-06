#!/usr/bin/env bash
# Sets up a kubectl context for the cluster.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

gcloud compute addresses describe $ADDRESS_NAME --region $REGION --project=$PROJECT_ID --region=$REGION
