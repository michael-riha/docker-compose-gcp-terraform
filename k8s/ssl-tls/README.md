# SSL & TLS
https://medium.com/@alexgued3s/how-to-easily-ish-471307f276a9

~~`kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.crds.yaml`~~<br>
~~`kubectl get crd` seems to be available~~<br>
~~`kubectl create namespace cert-manager`~~<br>

## install `cert-manager`

`kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml`

> `kubectl get pods --namespace cert-manager`<br>
You should see three pods running: `cert-manager`, `cert-manager-cainjector` and `cert-manager-webhook`.

✅

I added an `A`-Record to map my domain `<some host domain>` to the public IP of the server.


`kubectl create namespace nginx-deploy`
`kubectl apply -n nginx-deploy -f ../k8s/nginx-deployment/nginx-deployment.yaml`
you can/could deploy the `nginx-ingress.yaml` as well to see the output already on the server via the IP!

Let me see what is all available `kubectl get all --all-namespaces` 
watch all the happens -> `watch kubectl get pod,svc,ing` (install watch via `brew`on MacOS, FYI)

## To get `cert-manager` + `letsencrypt` working
- install `cert-manager` (as above)
- apply the `ClusterIssuer`/`cert-issuer` as found in `k8s/ssl-tls/cert-issuer.yaml`
- apply the `Certificate` as found in `k8s/ssl-tls/cert.yaml`
- apply the "new" `Ingress` with `host`& `secret` set
- go with your browser to `https://<host>` and try if it works
<br>
    - to debug further [the concept](https://cert-manager.io/docs/concepts/certificate/) ->  [old cert-manager docu](https://docs.cert-manager.io/en/release-0.11/reference/orders.html)

        based on https://stackoverflow.com/a/65809340

        `kubectl describe certificate k8s.beyondthestatic.com -n nginx-deploy`<br>
        in the `Events` section you will see something like -> 'Created new CertificateRequest resource "k8s.beyondthestatic.com-xyz"'<br>
        `kubectl describe certificaterequest k8s.beyondthestatic.com-xyz -n nginx-deploy`<br>
        in the `Events` section you will see something like -> 'Created Order resource ....'<br>
        ` kubectl describe order k8s.beyondthestatic.com-xyz-123 -n nginx-deploy`<br>

### ! BE AWARE !

> [An Issuer is a namespaced resource, and it is not possible to issue certificates from an Issuer in a different namespace. This means you will need to create an Issuer in each namespace you wish to obtain Certificates in.

> If you want to create a single Issuer that can be consumed in multiple namespaces, you should consider creating a ClusterIssuer resource. This is almost identical to the Issuer resource, however is non-namespaced so it can be used to issue Certificates across all namespaces.

](https://cert-manager.io/docs/concepts/issuer/#namespaces)

## delete the Certificate again

https://github.com/kelseyhightower/kube-cert-manager/blob/master/docs/delete-a-certificate.md

`kubectl get certificates` -> `k8s.beyondthestatic.com`
`kubectl get pods -n cert-manager` -> look at the logs here `cert-manager-xyz`
`kubectl delete certificates k8s.beyondthestatic.com`

### Resources:

- [more on cert-manager & TLS&SSL](https://www.youtube.com/watch?v=6BrFXxbFoh4&t=1641s)
- 