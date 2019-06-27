#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

helm upgrade \
    --install \
    --namespace default \
    --set rbac.create=true \
    --set controller.kind=DaemonSet \
    --set controller.publishService.enabled=true \
    --set controller.service.loadBalancerIP="${EXTERNAL_IP}" \
    nginx-ingress \
    stable/nginx-ingress

kubectl apply -n default -f ./nginx-ingress/configmap.yaml
