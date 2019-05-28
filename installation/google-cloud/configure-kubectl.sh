#!/usr/bin/env bash
# Sets up a kubectl context for the cluster.

set -euxo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

gcloud --project="${PROJECT_ID}" container clusters get-credentials --region="${REGION}" "${CLUSTER_NAME}"
