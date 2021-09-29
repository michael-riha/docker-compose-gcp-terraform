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

// https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image
data "google_compute_image" "gcp_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["terraform-instance"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.gcp_image.self_link
    }
  }

  metadata = {
    ssh-keys = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.gcp_ssh_user
      private_key = file("${var.gcp_ssh_priv_key_file}")
      agent       = false
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`",
      "sudo docker run -d -p 80:80 nginx"
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

// https://collabnix.com/5-minutes-to-run-your-first-docker-container-on-google-cloud-platform-using-terraform/
resource "google_compute_firewall" "www-rule" {
  name    = "tf-www-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraform-instance"]
}