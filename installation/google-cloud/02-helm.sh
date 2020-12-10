#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Add ingress-nginx repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/

# Update Helm repo before we return
helm repo update
