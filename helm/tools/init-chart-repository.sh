#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${SCRIPT_DIR}/../.."

if git rev-parse --quiet --verify chart-release > /dev/null; then
    echo "The chart-release branch already exists"
    exit 1
fi

if [[ -n $(git status -s) ]]; then
    echo "Dirty git workspace detected, aborting"
    exit 1
fi

echo "Will create a chart-release branch and push it to origin in 5 seconds"
sleep 5

git symbolic-ref HEAD refs/heads/chart-release
rm .git/index
git clean -fdx
touch index.yaml
git add index.yaml
git commit -a -m "Initial chart repo commit"
git push origin chart-release
git checkout master
