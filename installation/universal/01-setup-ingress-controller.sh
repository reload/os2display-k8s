#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

helm install \
    --name nginx-ingress stable/nginx-ingress \
    --set rbac.create=true \
    --set controller.service.loadBalancerIP="${EXTERNAL_IP}"
