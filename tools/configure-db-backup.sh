#!/usr/bin/env bash
#
# Sets up a service-account, bucket and k8s secret for doing database backups.
# Set the helm value adminDb.backup.enabled to true after running this script.
#
# The script assumes you have access to the google cloud project and that your
# local sdk has been set up with access.
#
set -euo pipefail
IFS=$'\n\t'

# Setup a temporary volume that will hold the gcloud sdk / kubectl
# authentication information.
function sdk_setup_volume() {
    docker volume create "${SDK_CONFIG_VOLUME}" > /dev/null
    docker volume create "${KUBE_CONFIG_VOLUME}" > /dev/null
}

# Configure a docker-run sdk-instance with the authentication information from
# the local cloud sdk.
function sdk_setup() {
    local CLUSTER_NAME=$1
    docker run \
      --rm\
      -v "${SDK_CONFIG_VOLUME}:/root/.config"\
      -v "${HOME}/.config:/populate/.config"\
      google/cloud-sdk:latest\
      rsync -a /populate/.config/gcloud /root/.config/ --exclude logs > /dev/null
    sdk gcloud container clusters get-credentials "${CLUSTER_NAME}" > /dev/null
}

# Get rid of the temporary volume and output manual deletion instructions.
# We may print out instructions for things that has not yet been created due
# to errors.
function cleanup() {
    docker volume rm -f "${SDK_CONFIG_VOLUME}" > /dev/null
    docker volume rm -f "${KUBE_CONFIG_VOLUME}" > /dev/null
    
    echo # newline
    echo "Manual deletion/cleanup instructions"
    if [[ ! -z "${SUCCESS:-}" ]] ; then
        echo "Be aware that as the script failed, some resources may not have been created."
    fi
    echo "  gcloud iam service-accounts delete -q ${SERVICE_ACCOUNT_FQN}"
    echo "  gsutil rm -rf ${BUCKET_NAME}"
    echo "  kubectl --namespace ${NAMESPACE} delete secret ${SECRET_NAME}"
}

# Wrap a docker run invocation of the sdk.
function sdk() {
    docker run \
      --rm\
      --volume "${KUBE_CONFIG_VOLUME}:/root/.kube"\
      --volume "${SDK_CONFIG_VOLUME}:/root/.config"\
      google/cloud-sdk:latest\
      "$@"
}

if [[ $# -lt 3 ]] ; then
    echo "Syntax: $0 <project> <namespace> <cluster> [location]"
    echo "The namespace for environment foo will most likely be os2display-foo"
    exit 1
fi

PROJECT=$1
NAMESPACE=$2
CLUSTER=$3
LOCATION=${4:-eu}

SERVICE_ACCOUNT_NAME="${NAMESPACE}-db-backup"
SERVICE_ACCOUNT_FQN="${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com"
BUCKET_NAME="gs://db-backup-${PROJECT}-${NAMESPACE}"
SECRET_NAME="db-backup-sa"

# Ensure the local cloud-sdk has access to the project before doing anything.
if ! gcloud projects describe ${PROJECT} &> /dev/null ; then
    echo "Your local Google Cloud SDk dos not have not access to the project ${PROJECT}"
    exit
fi

echo # newline
echo "* Configuring Google Cloud SDK"
SDK_CONFIG_VOLUME="${RANDOM}_cloud_sdk_auth"
KUBE_CONFIG_VOLUME="${RANDOM}_cloud_kube"
sdk_setup_volume
trap cleanup EXIT
sdk_setup "${CLUSTER}"

# Ensure the namespace exists.
if ! sdk kubectl get namespace "${NAMESPACE}" &> /dev/null ; then
    echo "Namespace ${NAMESPACE} does not exist"
    exit
fi

echo # newline
echo "* Creating serviceacount ${SERVICE_ACCOUNT_NAME} in project ${PROJECT}"
sdk gcloud beta iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --project "${PROJECT}" \
    --description "Serviceaccount for backing up the database in ${NAMESPACE}" \
    --display-name "${NAMESPACE} database backup"

# # Create a nearline (storage is cheaper, retrival is more expensive) bucket for the project
echo # newline
echo "* Creating bucket ${BUCKET_NAME}"
sdk gsutil mb -p "${PROJECT}" -c nearline -l "${LOCATION}" "${BUCKET_NAME}"

# Grant the service-account creation access.
echo # newline
echo "* Granting ${SERVICE_ACCOUNT_NAME} objectCreator access to ${BUCKET_NAME}"
sdk gsutil iam ch "serviceAccount:${SERVICE_ACCOUNT_FQN}:objectCreator" "${BUCKET_NAME}"

echo # newline
echo "* Retriving access-keys for ${SERVICE_ACCOUNT_NAME} and creating secret in ${NAMESPACE}"
# We have a temporary volume in /root/.config that will go away when this 
# script completes so we may as well use if for temporary storage of the keyfile.
sdk gcloud iam service-accounts keys create "/root/.config/keyfile.json" \
  --project "${PROJECT}" \
  --iam-account "${SERVICE_ACCOUNT_FQN}"

sdk kubectl create secret generic "${SECRET_NAME}" --namespace="${NAMESPACE}" --from-file="key.json=/root/.config/keyfile.json"

echo #newline
echo "Success, summary:"
echo "  - Created serviceaccount ${SERVICE_ACCOUNT_FQN}"
echo "  - Created a nearline Google Storage bucket at ${BUCKET_NAME} in ${LOCATION}"
echo "  - Granted the service account objectCreator access to the bucket"
echo "  - Created the secret ${SECRET_NAME} in the namespace ${NAMESPACE} containing an access-key for the service account"

# Signal cleanup() that we're good.
SUCCESS=1
