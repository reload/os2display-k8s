#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}/../.."

CHART_BRANCH="gh-pages"

if git rev-parse --quiet --verify ${CHART_BRANCH} > /dev/null; then
    echo "The ${CHART_BRANCH} branch already exists"
    exit 1
fi

if [[ -n $(git status -s) ]]; then
    echo "Dirty git workspace detected, aborting"
    exit 1
fi

echo "Will create a ${CHART_BRANCH} branch and push it to origin in 5 seconds"
sleep 5

git symbolic-ref HEAD refs/heads/${CHART_BRANCH}
rm .git/index
git clean -fdx
touch index.yaml
git add index.yaml
git commit -a -m "Initial chart repo commit"
git push origin ${CHART_BRANCH}
git checkout master
