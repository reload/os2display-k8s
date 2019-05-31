#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

if [[ $# -eq 0 ]] ; then
    echo "Syntax: $0 <tag>"
    exit 1
fi

REQUESTED_TAG="$1"
CHART_SOURCE_TAG="chart-source-${REQUESTED_TAG}"
CHART_HOSTING_URL="https://reload.github.io/os2display-k8s"
DESTINATION_BRANCH="gh-pages"
BUILD_BASE_DIR="${SCRIPT_DIR}/../helm/build"
BUILD_SOURCE_DIR="${BUILD_BASE_DIR}/source"
BUILD_DESTINATION_DIR="${BUILD_BASE_DIR}/pages"
RELEASE_TAG="chart-release-${REQUESTED_TAG}"
PACKAGE="os2display-${REQUESTED_TAG}.tgz"


if ! [ -x "$(command -v helm)" ]; then
  echo 'Error: helm is not installed.' >&2
  exit 1
fi

echo "Building chart release ${REQUESTED_TAG}."
echo
echo "Will:"
echo "  - Check out source-tag ${CHART_SOURCE_TAG}"
echo "  - Build chart release ${REQUESTED_TAG}"
echo "  - Publish it to ${CHART_HOSTING_URL}"

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting"
    exit 1
fi

git fetch --tags
set +e
if  ! git rev-parse $CHART_SOURCE_TAG >/dev/null 2>&1 ; then
    echo "You must tag the revision you build as $REQUESTED_TAG as \"$CHART_SOURCE_TAG\"."
    exit 1
fi
set -e  

# Clear out any lingering builds.
if [[ -d "${BUILD_SOURCE_DIR}" ]] ; then
    rm -fr "${BUILD_SOURCE_DIR}"
fi
if [[ -d "${BUILD_DESTINATION_DIR}" ]] ; then
    rm -fr "${BUILD_DESTINATION_DIR}"
fi
git worktree prune

# Make two worktrees, one for building the chart, an another for adding the 
# package to the destination repo.
git fetch origin "${CHART_SOURCE_TAG}:${CHART_SOURCE_TAG}"
git worktree add "${BUILD_SOURCE_DIR}" "${CHART_SOURCE_TAG}"
git fetch origin "${DESTINATION_BRANCH}:${DESTINATION_BRANCH}"
git worktree add "${BUILD_DESTINATION_DIR}" "${DESTINATION_BRANCH}"

cd "${BUILD_SOURCE_DIR}/helm"

set +e
if  ! grep -q "version: ${REQUESTED_TAG}" "${BUILD_SOURCE_DIR}/helm/os2display/Chart.yaml" ; then
    echo "Could not verify tag ${REQUESTED_TAG} in Chart.yaml, please verify that the chart-source-tag corresponds with the chart version in Chart.yaml"
    exit 1
fi
set -e

helm package os2display
if [[ ! -f "${PACKAGE}" ]] ; then
    echo "Could not find package after build, expected to find it at ${PACKAGE}"
fi

cd "${BUILD_DESTINATION_DIR}"
git pull origin "${DESTINATION_BRANCH}"
# Ensure the destination dir exists, this will fail silently if it does.
mkdir -p helm
mv "${BUILD_SOURCE_DIR}/helm/${PACKAGE}" helm/
git add "helm/${PACKAGE}"
helm repo index . --url "${CHART_HOSTING_URL}"
git add index.yaml
git commit -m "Chart release ${REQUESTED_TAG}"
git tag "${RELEASE_TAG}"
git push origin "${DESTINATION_BRANCH}"

rm -fr "${BUILD_BASE_DIR}"
git worktree prune

echo "Chart ${REQUESTED_TAG} published"
