variable "project" {
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
