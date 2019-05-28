#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

if [[ $# -lt 2 ]] ; then
    echo "Syntax: $0 <environment> <initial-admin-release-number>"
    exit 1
fi

ENV=$1
ADMIN_RELEASE_NUMBER=$2
TEMPLATES_PATH="${SCRIPT_DIR}/templates"
VALUES_PATH="${ENV}/values.yaml"
SECRETS_PATH="${ENV}/secrets.yaml"

if [[ -d "${ENV}" ]] ; then 
  echo "The ${ENV} directory already exists, aborting init"
  exit 1
fi

if ! [ -x "$(command -v envsubst)" ]; then
  echo 'Error: envsubst is not installed.' >&2
  exit 1
fi

mkdir "${ENV}"

export ENVIRONMENT=$ENV
export ADMIN_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export ADMIN_RELEASE_NUMBER=$ADMIN_RELEASE_NUMBER
export SEARCH_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export SEARCH_ADMIN_USERNAME=admin-$(head /dev/urandom | tr -dc a-z0-9 | head -c5)
export SEARCH_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc a-z0-9 | head -c10)
export MIDDLEWARE_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export MIDDLEWARE_ADMIN_USERNAME=admin-$(head /dev/urandom | tr -dc a-z0-9 | head -c5)
export MIDDLEWARE_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc a-z0-9 | head -c10)

envsubst < "${TEMPLATES_PATH}/values-template.yaml" > "${VALUES_PATH}"
envsubst < "${TEMPLATES_PATH}/secrets-template.yaml" > "${SECRETS_PATH}"

echo "${VALUES_PATH} and ${SECRETS_PATH} has been generated, inspect the files and when you are ready, proceede to executing"
echo "./install.sh ${ENV}"
