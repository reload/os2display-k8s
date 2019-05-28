#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

if [[ $# -eq 0 ]] ; then
    echo "Syntax: $0 <tag>"
    exit 1
fi

REQUESTED_TAG=$1
CHART_SOURCE_TAG="chart-source-${REQUESTED_TAG}"
CHART_DIR="${SCRIPT_DIR}/../helm-chart/os2display"

set +e
if  ! grep -q "version: ${REQUESTED_TAG}" "${CHART_DIR}/Chart.yaml" ; then
    echo "Could not verify tag ${REQUESTED_TAG} in Chart.yaml in ${CHART_DIR}, please verify that the chart-source-tag corresponds with the chart version in Chart.yaml"
    exit 1
fi
set -e

if [[ ! -z $(git status -s) ]] ; then
    echo "Your working-tree is dirty, won't tag"
    exit 1
fi

echo "Creating tag for chart source version ${REQUESTED_TAG}."
echo
echo "Will:"
echo "  - Create tag ${CHART_SOURCE_TAG}"
echo "  - Push it to origin"

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting"
    exit 1
fi

git tag "${CHART_SOURCE_TAG}"
git push origin "${CHART_SOURCE_TAG}"

echo "Tag pushed"
