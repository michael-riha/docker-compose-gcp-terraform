
### Objective

this terraform setup was planned to learn `terraform` in the Google Cloud, by setting up a maschine, firewall & a `docker` environment to deploy services.


## Table of Contents
1. [Let's get started](#so-let's-get-started) with `terraform` in GCP
2. [create infrastructure/resources](#create-infrastructure/resources)
    - [add some maschine](#add-some-maschine) to the mix
    - [destroy all that again](#destroy-all-that-again)

---

## [So let's get started](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)

```
Warning: While everything provisioned in this tutorial
should fall within GCP's free tier, if you provision
resources outside of the free tier, you may be charged. We
are not responsible for any charges you may incur.
```
_from the official documentation linked above_

we will find that our soon! 

I did everything [on that page](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started) 
- create account
- enable APIs
- create & download service account (to the `/credentials`-folder)
<br>
---

## Run `terraform init`
on a local `terraform:light` -container
_[full/final command below](#full_command)_
```bash
docker run -it --entrypoint "sh" -v ${PWD}:/workspace -w /workspace hashicorp/terraform:light
```

in the `sh` I run

`terraform init`

`terraform validate`

seems to be good!

---
## create infrastructure/resources

`terraform apply` -> WORKS

`terraform show`

---

### add some maschine

[how to add a VM to your gxp project from the offcial documentaiton](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-change?in=terraform/gcp-get-started#create-a-new-resource)

`terraform apply` -> WORKS

---
### destroy all that again
& build something "useable"

`terraform destroy` 

DONE

---

## Our goal is <br> gcp + `docker`
### from `terraform`

-  let's [add our SSH keys](https://stackoverflow.com/a/38647811) to the GCP VM

```
metadata = {
  ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
```

[to make this happen, we should create a `variables.tf`](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-variables?in=terraform/gcp-get-started)
```
Terraform automatically loads files called terraform.tfvars
or matching *.auto.tfvars in the working directory when
running operations.
```
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#metadata

## *WARNING!*
We now also need to mount the `~/.ssh/`-folder (not fully smart but I am lazy)

<a name="full_command"></a>
```bash
docker run -it --entrypoint "sh" \
-v ${PWD}:/workspace \
-v ~/.ssh:/workspace/credentials/keys \
-w /workspace hashicorp/terraform:light
```

*works!*

Now let's run `terraform fmt`
& `terraform validate` again -> *works!*

Let's role `terraform apply` -> *works!*

Let's try to connect -> *FAILED*

No, firewall rule is missing
```
// https://stackoverflow.com/a/62245455
resource "google_compute_firewall" "ssh-rule" {
  name    = "demo-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["terraform-instance"]
  source_ranges = ["0.0.0.0/0"]
}
```

`ssh -i ~/.ssh/id_rsa terraformUser@<external outputted IP address>`
<br>
* `-o StrictHostKeyChecking=no`<br>when you don't wanna be asked 
about the keys to add to `unknown_hosts`


---

### Now, let's install `docker` remote!

- take from [HERE](https://collabnix.com/5-minutes-to-run-your-first-docker-container-on-google-cloud-platform-using-terraform/)


- save the plan 
`terraform plan -out=plan_ouput.out`

- see all images on `gcloud` being available?
    
    - `gcloud compute images list`
    
    I needed to change `debian9` from the official documentation to `debian11`

---

## install `graphviz` to get some graphs

for optimization we can show the graph of our `terraform`infrastructure by 
[installing `graphviz`to get `dot`-cli](https://github.com/fgrehm/docker-graphviz/blob/master/Dockerfile) 
that can draw a `*.png` of our infrastructure.

```bash
apk add --update --no-cache \
           graphviz \
           ttf-freefont
```

then we can run `terraform graph | dot -Tpng > ../graphs/terraform.png`

and see a nice image of our structure.

![terraform graph](graphs/terraform.png)