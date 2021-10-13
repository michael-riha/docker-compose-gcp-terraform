
# k3d 

Instead of docker (`docker-compose`) I wanted to use Kubernetes.
So the easiest approach was to install [k3d](https://github.com/rancher/k3d#get) on my, via `terraform` created, maschine on GCP.

`curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash`
<br>
<br>

## attach to local `kubctl`

get the `kubeconfig` to use from local host

`k3d kubeconfig get dev`
`k3d kubeconfig write dev` 
<br>
<br>
if you have a new maschine with the same IP you need to clean `known_hosts` to avoid error does to another key from a fresh maschine.

`ssh-keygen -R <public IP of the server> -f ../credentials/keys/known_hosts`

<br>
_on the hiost outside of the `terraform`-container!_
`scp -o StrictHostKeyChecking=no terraformUser@<public IP of the server>:/root/.k3d/kubeconfig-dev.yaml ${PWD}/tmp/kubeconfig-dev.yaml`
<br>
<br>
**INFO:**

replace the IP address (`0.0.0.0`) in the `kubeconfig-dev.yaml` with `<public IP of the server>`
<br>
<br>
_[load custom config from filesystem and ignore TLS verify](https://ahmet.im/blog/mastering-kubeconfig/)_

`KUBECONFIG=~/.kube/kubeconfig-dev.yaml kubectl get pods --insecure-skip-tls-verify`

to avoid the `--insecure-skip-tls-verify` on every command
you can also [add it to the `kubeconfig-xxxx.yaml`](https://github.com/kubernetes-client/javascript/issues/7#issue-291266788) <br>_& delete `certificate-authority-data`-attribute as well!_

eg.
```yaml
- cluster:
    insecure-skip-tls-verify: true
    server: https://127.0.0.1:443
  name: my-cluster
```

### merge the new cluster config
merge the `config`.yaml (`kubeconfig-dev.yaml`) to the general one called `~/.kube/config`

- backup the original one:<br>
`cp ~/.kube/config ~/.kube/config_backup`
- [merge and flatten](https://ahmet.im/blog/mastering-kubeconfig/) the new one with the default `config`<br> 
`KUBECONFIG=~/.kube/kubeconfig-dev.yaml:~/.kube/config kubectl config view --merge --flatten > ~/.kube/config`
- [check contexts](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration) without `KUBECONFIG` env now<br>
`kubectl config get-contexts`<br>the new one should be there now `admin@k3d-dev`
## Mastering `kubeconfig` 
https://ahmet.im/blog/mastering-kubeconfig/

- stripped my `config` with just one cluster I still need
`kubectl config view --minify --flatten --context=docker-desktop >stripped-config`

- merged that simple config with the one we fetch from the `k3d` cluster<br>
`KUBECONFIG=tmp/stripped-config:tmp/kubeconfig-dev.yaml kubectl config view --merge --flatten > ~/.kube/config`

- use context <br>`config use-context k3d-dev`


## now, we can play around with `kubectl`

https://kubernetes.io/de/docs/reference/kubectl/cheatsheet/

## get the logs

https://rancher.com/docs/k3s/latest/en/advanced/#starting-the-server-with-the-installation-script

to enter the `pod` to have direct access to `k3s` itself.

on the host where `k3d` runs execute `docker ps`
you should see two container

```
rancher/k3d-proxy:x.x.x
rancher/k3s:vx.x.x-k3s1
```
enter the `pod` to look into the logs
`docker exec -it <CONTAINER ID of "rancher/k3s:vx.x.x-k3s1"> sh`
and now `/var/log/` and investigate! 🤷‍♂️

---

## get the `traefik`-dashboard

```bash
k3d version v4.4.8
k3s version v1.21.3-k3s1 (default)
```

[with this post I got it to work](https://stackoverflow.com/a/69033555)

`kubectl get pods -n kube-system`

look for the `traefik-xxxx` pod.

you can not let it describe to you

`kubectl -n kube-system describe pod traefik-xxxx`

and if the dashboard is anabled and listening to `:9000` you can then portforward to your local maschine

`kubectl port-forward traefik-xxxx -n kube-system 9000:9000`

`http://localhost:9000/dashboard/` -> works

## final step, get `certmanager` working

https://opensource.com/article/20/3/ssl-letsencrypt-k3s

https://www.edvpfau.de/keycloak-im-k3s-kubernetes-cluster-aufsetzen/ <br>
https://www.edvpfau.de/cert-manager-in-kubernetes-installieren/ (german!)


`curl --location <your file url> | kubectl apply -f -`

`curl --location https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.yaml | KUBECONFIG=../tmp/kubeconfig-dev.yaml kubectl apply -f - --insecure-skip-tls-verify`

# SSL & TLS

including:
    
- `cert-manager`
- how do get a `Certificate``
- debug stored secrets with keys inside

    ### [__all here__ ( `ssl-tls/` )](/ssl-tls)


# dashboards and monitoring

[we try to install the kubernetes dashboard](https://gist.github.com/smijar/64e76808c8a349eb64f56c71dc03d8d8)

`kubectl create -f https://raw.githubuserctent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml`

get the token used to login to the dashboard
`kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token`

port-forward to look at the dashboard
`kubectl port-forward kubernetes-dashboard-<xyz> -n kubernetes-dashboard 8443:8443`

- go with your browser to `https://localhost:8443` be aware that it is an insecure endpoint due to the missing certificates

# install another test application

- `kubectl apply -f k8s/whoami-deployment/whoami-deployment.yaml`
- `kubectl apply -f k8s/whoami-deployment/whoami-service.yaml`
- `kubectl apply -f k8s/whoami-deployment/whoami-ingress.yaml`
- go with your browser to `https://<host from ../ssl-tls/cert.yaml>/whoami`

# using a external container registry

https://blog.container-solutions.com/using-google-container-registry-with-kubernetes

we already have a service-account created for terraform (`/.credentials/<somefile>.json`), so let's reuse it

```
kubectl create secret docker-registry gcr-json-key \
--docker-server=eu.gcr.io \
--docker-username=_json_key \
--docker-password="$(cat credentials/moonlit-nature-284615-b3b29f44e8c7.json)" \
--docker-email=michael.riha@gmail.com
```
[as seen here](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets)

test it `get secret gcr-json-key created -o yaml`

test if ot works `kubectl apply -f k8s/external_registry/deployment.yaml`

WARNING: I failed to load my container (2GB, don't ask why but there is a reason called CEF) failed
```
failed to pull and unpack image "<IMAGE>": 
failed to extract layer sha256:a1e97e6ec27ccc3f22c1cadbc4f1e6219ef7c437e37f032ce50030cbec0b4b71: write <somefile>: 
no space left on device: unknown```

https://k3d.io/faq/faq/

---

## TODOs:

- make snapshot and reset the cluster -> https://github.com/k3s-io/k3s/issues/2758#issuecomment-777034524
- mount persitent volume
- 

### Resources:

- https://www.sokube.ch/post/k3s-k3d-k8s-a-new-perfect-match-for-dev-and-test
- https://www.upnxtblog.com/index.php/2020/07/10/how-to-setup-2-node-cluster-on-k3s/amp/#Step1_Install_K3s
- https://nimblehq.co/blog/provision-k3s-on-google-cloud-with-terraform-and-k3sup
- https://www.thebookofjoel.com/cheap-production-k3s-with-dashboard-ui


