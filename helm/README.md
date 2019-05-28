# OS2Display Hosting

## Helm chart
This repository contains the sources for a helm-chart that can host os2display, and the tools necessary for building new releases of it.

Charts are versioned via semver. As we have to track both the chart-sources, and the packaged chart via the same git-repository, a release will be handled via two git-tags.
* The "source" tag "chart-source-[semver]"
* The "release" tag "chart-release-[semver]"

The tools for handling the release only requires the un-prefixed semver, you should never handle any of the above tags manually.

## Initializing the chart repository
Before creating the very first chart release you must initialize the chart-release branch that will host the charts. You can either set up the branch yourself or use the `tools/init-chart-repository` script.
After creation you must configure your github repository to use the branch for github-pages.

## Building a release
You first tag the release, then build and publish it. This done in separate steps.
* Determine the next tag, and update `helm-chart/os2display/Chart.yaml` accordingly.
* Commit your updates.
* Tag the release via `make tag-release TAG=[semver]`
* Publish the release by running `make publish-release TAG=[semver]`

The release is now available via https://reload.github.io/os2display-chart

## Using the chart
You can add the repository to your local helm client via
```
helm repo add os2display https://reload.github.io/os2display-chart
```

You can then install os2display via `helm install os2display/os2display`. Notice that you want inspect the various values for the chart, and probably also version your chart-values. See the os2display-hosting-environments for tools to handle this.
