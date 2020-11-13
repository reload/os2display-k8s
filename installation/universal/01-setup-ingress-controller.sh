#!/usr/bin/env bash

set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}"
source "_settings.sh"

kubectl create --dry-run=client -o yaml namespace ingress-nginx | kubectl apply -f

kubectl apply -n ingress-nginx -f ./ingress-nginx/configmap.yaml

helm upgrade \
    --install \
    --namespace ingress-nginx \
    --set rbac.create=true \
    --set controller.kind=DaemonSet \
    --set controller.service.loadBalancerIP="${EXTERNAL_IP}" \
    ingress-nginx ingress-nginx/ingress-nginx
