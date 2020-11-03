#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

kubectl create --dry-run=client -o yaml namespace ingress-nginx | kubectl apply -f

kubectl apply -n ingress-nginx -f ./nginx-ingress/configmap.yaml

helm upgrade \
    --install \
    --namespace ingress-nginx \
    --set rbac.create=true \
    --set controller.kind=DaemonSet \
    --set controller.publishService.enabled=true \
    --set controller.service.loadBalancerIP="${EXTERNAL_IP}" \
    --name ingress-nginx \
    ingress-nginx/ingress-nginx
