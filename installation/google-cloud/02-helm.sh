#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create serviceaccount tiller --namespace kube-system

# Grant the service-account permissions via a binding.
kubectl create -f ./helm-rbac/

# Perform the init using the newly created account.
helm init --service-account tiller

# Update Helm repo before we return
helm repo update

