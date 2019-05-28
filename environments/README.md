# OS2Display hosting-environments
This repository is used to manage one or more os2display environments.
The environments themselves are deployed via [Helm](https://helm.sh/), this repo and the tools within it simply makes it easier to handle the installation, upgrade and management of the releases.

The Helm chart itself is hosted at https://reload.github.io/os2display-k8s and the source can be found in the os2display-hosting repository.

Requirements:
* The Helm client
* kubectl and a working connection to the cluster (see os2display-infrastructure for details on how to connect).

## Setting up Helm
You first need to add the chart repository to your local helm client.

```bash
helm repo add os2display https://reload.github.io/os2display-k8s
```

You can verify that you've accessed the repository by listing all charts in the repository.

```bash
helm search os2display/
```

You should see a single os2display chart.

Then verify that you have access to the environment by executing

```bash
helm list
```

This should at the very least list the cert-manager and nginx-ingress used in os2display cluster. You may also see os2display-[environment] releases for each os2display environment handled via Helm.

You are now ready for creating and updating environments.

## Installation of an environment
Use these steps to setup a new os2display environment. Each environment is contained in a seperate Kubernetes namespace that will be created automatically.

### Environment configuration
First create the environment configuration using `./init.sh <environment-name> <admin-release-number>`
```bash
# Create a staging environment using the reload-build-8 release
./init staging 8
```

See https://hub.docker.com/r/reload/os2display-admin-release/tags for at list of available release numbers, you probably want the latest.

This creates a directory named after the environment and instantiates a values.yaml and a secrets.yaml file. The latter should never be committed. 

Inspect the yaml files and make any necessary updates to eg. the admin email or credentials. Note that you are not required to change anything. You rarely need the credentials listed in secrets.yaml, and they can always be extracted from the environment, but you may want to save copy for important environments such as production.

You could commit the values.yaml at this point, but you may just as well wait until you have a working environment.

### Environment creation
You are now ready to create the environment, as all of the configuration is ready, this is a rather simple step. 

First make sure you have the latest helm chart
```bash
helm repo update
```

Then invoke `./install.sh [environment]`

```bash
# Perform the initial installation of the staging environment
./install staging
```

Helm will block until the environment has been created


### Deleting an environment
First have Helm delete the release using `helm delete os2display-[environment]`
```bash
# Delete the "justtesting" environment
helm delete os2display-justtesting
```

Or if you want to completely remove all traces so that you could create a new environment with the same name.
```bash
# Delete the "justtesting" environment completely.
helm delete --purge os2display-justtesting
```

Then remove the namespace using `kubectl delete namespace os2display-[environment]`
```bash
kubectl delete namespace os2display-justtesting
```

# Deploying a release

## Build the images
You need to build and push the release images first. Go to the [building a release page](https://github.com/kkos2/os2display-infrastructure/documentation/building-a-release.md) and follow the steps there if you haven't already.

## Make sure you are set up
Make sure you are setup to use Helm and `kubectl`. You should follow the steps [here](https://github.com/kkos2/os2display-hosting-environments/blob/master/README.md)

## Do the deployment
To deploy to an environment - for instance test, find the folder with the environment name and update the `tag` under `adminRelease` in `[env-dir]/values.yaml`.

Then make sure you have the latest helm chart
```bash
helm repo update
```

Then invoke `./upgrade.sh <environment>`
```bash
# Upgrade the test environment
./upgrade.sh test
```
That's it!

Celebrate, then get back to work. 



