#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
set -o allexport 
source "_settings.sh"
set +o allexport

envsubst < certmanager/issuer.yaml | kubectl apply -n default -f - 
