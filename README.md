# OS2display on Kubernetes
This repository contains the tools we use to host OS2display on kubernetes
* /installation - scripts for provisioning resources for hosting os2display
* /helm - helm chart and scripts for releasing it
* /environments - tracks helm chart deployments into environments

## Getting started
First go through the steps outlined in  [installation/google-cloud/README.md](installation/google-cloud/README.md) to prepare a kubernetes cluster.

Then deploy a chart by following the steps outlined in [helm/README.md](helm/README.md)
