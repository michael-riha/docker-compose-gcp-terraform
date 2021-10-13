
I do not want to download & install `Terraform` locally, 
<br>
[I decided to use it from a docker container.](https://www.mrjamiebowman.com/software-development/docker/running-terraform-in-docker-locally/)

## WARNING,<br>this is a Terraform newbie project.<br>
_I start from scratch, and improve over time!_

--------
# Basic `terraform` GCP setup for <br> `docker`/ `docker-compose` <br> in a VM

## Table of Contents
1. [Let's get started](/terraform) with `terraform` 
2. [Install `docker` from `terraform`](/terraform/README.md#from-terraform)
3. [Install `k8s` (`k3d`) from `terraform`](/k8s)
5. [Deploy a simple app (`k8s/nginx-deployment`) in `k8s`](/k8s/nginx-deploy)
5. [Deploy & apply `cert-manager` (in `k8s`) to get TLS/SSL for a host](/k8s/ssl-tls)
6. [Summary](#summary)

---

## Summary
we did

- run terraform in a local container
- connect to the cloud with the `google` provider from terraform
- create a network
- create a compute instance
- transfered the ssh keys, to login via `ssh`to this instance
- installed docker on this `debian 11` instance
- installed `k3d` (`k8s`)
  - install the letscrypt `certbot`

TODO:

- add digitalocean as provider to the mix
- run everything on `docker-compose`
- run `konghq`, maybe?
  - `acme`-plugin maybe to get some nice SSL/TLS
- install `wordpress`