# Cloud-independent installation
The following steps can be carried out in a cloud that has been prepared (see installation/google-cloud)

The documentation assumes you have the following installed
* The kubernetes commandline tools installed (eg. from the gcloud sdk)
* envsubst (included in the gettext package in most linux distros, on mac it can be installed via `brew install gettext && brew link --force gettext`)

1. Edit _settings.sh and fill out the configuration
2. Run `01-setup-ingress-controller.sh` to install a ingress controller via Helm
3. Run `02-setup-certificate-issuer.sh` to setup a cluster-issuer that will request certificates from letsencrypt.

