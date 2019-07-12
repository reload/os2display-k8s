#!/usr/bin/env bash
#
# Sets up a backup schedule for a disk.
# 
# TODO: We can deduce the name of the disk from following the 
# <namespace>/uploads-claim pvc to its pv which has the sourcedisk. This script
# should just take the namespace of the environment, and set everything up.
#
set -euo pipefail
IFS=$'\n\t'

# Setup a temporary volume that will hold the gcloud sdk / kubectl
# authentication information.
function sdk_setup_volume() {
    docker volume create "${SDK_CONFIG_VOLUME}" > /dev/null
}

# Configure a docker-run sdk-instance with the authentication information from
# the local cloud sdk.
function sdk_setup() {
    docker run \
      --rm\
      -v "${SDK_CONFIG_VOLUME}:/root/.config"\
      -v "${HOME}/.config:/populate/.config"\
      google/cloud-sdk:latest\
      rsync -a /populate/.config/gcloud /root/.config/ --exclude logs > /dev/null
}

# Get rid of the temporary volume and output manual deletion instructions.
# We may print out instructions for things that has not yet been created due
# to errors.
function cleanup() {
    docker volume rm -f "${SDK_CONFIG_VOLUME}" > /dev/null
}

# Wrap a docker run invocation of the sdk.
function sdk() {
    docker run \
      --rm\
      --volume "${SDK_CONFIG_VOLUME}:/root/.config"\
      google/cloud-sdk:latest\
      "$@"
}

if [[ $# -lt 2 ]] ; then
    echo "Syntax: $0 <project> <disk> <location> <zone>"
    exit 1
fi

PROJECT=$1
DISK_NAME=$2

SCHEDULE_NAME="dailysnapshot"

# Ensure the local cloud-sdk has access to the project before doing anything.
if ! gcloud projects describe ${PROJECT} &> /dev/null ; then
    echo "Your local Google Cloud SDk dos not have not access to the project ${PROJECT}"
    exit
fi

echo # newline
echo "* Configuring Google Cloud SDK"
SDK_CONFIG_VOLUME="${RANDOM}_cloud_sdk_auth"
sdk_setup_volume
trap cleanup EXIT
sdk_setup

if [[ -z "${3:-}" || -z "${4:-}" ]] ; then
    echo "Syntax: $0 <project> <disk> <location> <zone>"
    echo "Listing disks"
    sdk gcloud compute disks list
    exit 1    
fi
LOCATION=$3
ZONE=$4


echo # newline

# TODO - detect existing schedule
if ! sdk gcloud beta compute resource-policies describe --region "${LOCATION}" "${SCHEDULE_NAME}" &> /dev/null ; then
    echo "* Creating daily disk snapshot schedule in ${PROJECT}"
    # TODO switch to "create snapshot-schedule" when we go to version 253 of the sdk
    sdk gcloud beta compute resource-policies create-snapshot-schedule "${SCHEDULE_NAME}" \
        --description "Daily disk snapshot, 10 day rentention" \
        --max-retention-days 10 \
        --start-time 03:00 \
        --daily-schedule \
        --project "${PROJECT}" \
        --region "${LOCATION}" \
        --on-source-disk-delete keep-auto-snapshots \
        --storage-location "${LOCATION}"
fi

echo "* Attaching daily snapshot schedule to disk ${DISK_NAME}"

sdk gcloud beta compute disks add-resource-policies "${DISK_NAME}" \
    --resource-policies "${SCHEDULE_NAME}" \
    --zone "${ZONE}"

echo #newline
echo "Success"

# Signal cleanup() that we're good.
SUCCESS=1
