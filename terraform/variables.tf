variable "project" {
}

// f1-micro good enough to start, but with docker & k8s, not good enough!
variable "maschine_type" {
  default = "f1-micro"
}

variable "credentials_file" {
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "gcp_ssh_user" {
  default = "terraformUser"
}

variable "gcp_ssh_pub_key_file" {
}

variable "gcp_ssh_priv_key_file" {
}

variable "ssh_keys" {
  type = map(any)
  default = {
    "some" = "key"
  }
}
