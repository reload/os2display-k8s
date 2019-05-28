# Initial cluster installation
The following describes how to use the scripts in `provisioning/initial-setup`
to provision a GKE Kubernetes cluster and prepare for settings up an actual
installation of OS2display.

The documentation assumes you have the following installed
* The [gcloud sdk](https://cloud.google.com/sdk/install)
* The [Helm client](https://docs.helm.sh/using_helm/#installing-helm)
* The kubernetes commandline tools installed (eg. from the gcloud sdk)

And that you've created a google cloud project.

1. Edit _settings.sh and fill out the project and cluster details, leave 
   `EXTERNAL_IP` out for now
2. Run `01-setup-cluster.sh` to provision the cluster and IP
3. Run `configure-kubectl.sh` to configure your local kubectl - this might 
   require a couple of tries as the cluster is being provisioned.
4. Verify that the cluster is available by running `kubectl get nodes`
5. Run `02-helm.sh` to prepare the cluster for Helm and install Tiller.
6. Run `get-external-ip.sh`, insert the ip-address listet under "address" in 
   `_settings.sh` and uncomment the line. (Try a couple of times if the IP is 
   not available yet).
7. Follow the steps described in installation/universal to complete the remaining cloud-independent setup.s
