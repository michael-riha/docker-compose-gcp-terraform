
Instead of docker (`docker-compose`) I wanted to use Kubernetes.
So the easiest approach was to install [k3d](https://github.com/rancher/k3d#get) on my via `terraform` created maschine on GCP.

`curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash`

get the `kubeconfig`to use from local host

`k3d kubeconfig get dev`
`k3d kubeconfig write dev` 

_on the hiost outside of the `terraform`-container!_
`scp terraformUser@34.68.132.44:/home/terraformUser/.k3d/kubeconfig-dev.yaml ${PWD}/tmp/kubeconfig-dev.yaml`

_load custom config from filesystem and ignore TLS verify_
`KUBECONFIG=~/.kube/kubeconfig-dev.yaml kubectl get pods --insecure-skip-tls-verify`

Resources:

- https://www.sokube.ch/post/k3s-k3d-k8s-a-new-perfect-match-for-dev-and-test
- https://www.upnxtblog.com/index.php/2020/07/10/how-to-setup-2-node-cluster-on-k3s/amp/#Step1_Install_K3s
- https://nimblehq.co/blog/provision-k3s-on-google-cloud-with-terraform-and-k3sup
- https://www.thebookofjoel.com/cheap-production-k3s-with-dashboard-ui
