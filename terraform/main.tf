terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image
data "google_compute_image" "gcp_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.gcp_maschine_type
  tags         = ["terraform-instance"]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.gcp_image.self_link
    }
  }
  metadata = {
    ssh-keys = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
  }
  # share the connection all over the provisionares -> https://github.com/hashicorp/terraform/issues/17164#issuecomment-512538227
  connection {
    host        = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.gcp_ssh_user
    private_key = file("${var.gcp_ssh_priv_key_file}")
    agent       = false
  }

  # Copies the `install.sh`-script file to the remote maschine `/tmp/k8s_install.sh` -> https://www.terraform.io/docs/language/resources/provisioners/file.html#example-usage
  provisioner "file" {
    source      = "../k8s/initial_scripts/install.sh"
    destination = "/tmp/k8s_install.sh"
  }

  #this is maschine related basic installation of `docker`
  provisioner "file" {
    source      = "initial_scripts/install.sh"
    destination = "/tmp/maschine_install.sh"
  }

  # Copies the k3d `config`file to the remote maschine `/tmp/k3config`
  provisioner "file" {
    source      = "../k8s/k3d/config.yaml"
    destination = "/tmp/k3d-config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'now we start installing on the remote maschine'",
      "chmod +x /tmp/maschine_install.sh && /tmp/maschine_install.sh &&",
      "chmod +x /tmp/k8s_install.sh && /tmp/k8s_install.sh"
    ]
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

// https://stackoverflow.com/a/62245455
resource "google_compute_firewall" "ssh-rule" {
  name    = "tf-ssh-firewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["terraform-instance"]
  source_ranges = ["0.0.0.0/0"]
}

# https://collabnix.com/5-minutes-to-run-your-first-docker-container-on-google-cloud-platform-using-terraform/
resource "google_compute_firewall" "www-rule" {
  name    = "tf-www-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraform-instance"]
}

# firewall for kubernetes API
resource "google_compute_firewall" "k8s-rule" {
  name    = "tf-k8s-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["6550"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraform-instance"]
}

#safe the external IP to a file -> https://stackoverflow.com/questions/63845957/terraform-saving-output-to-file
resource "local_file" "external_ip" {
  content  = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
  filename = "../tmp/ip.txt"
}

#time the local resource as it is depending on the remote to finish
resource "null_resource" "local_setup" {
  #https://www.terraform.io/docs/language/resources/provisioners/local-exec.html#command
  provisioner "local-exec" {
    #command = "echo ${self.private_ip} >> private_ips.txt"
    # & multipline comments -> https://github.com/hashicorp/terraform/issues/3360#issuecomment-145393146
    command = <<EOT
      echo "local provisioning starting, now"
      K8S_IP=${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip} \
      HOST_USER=${var.gcp_ssh_user} \
      provisioning/local/provision.sh
    EOT
  }
  depends_on = [google_compute_instance.vm_instance]
}