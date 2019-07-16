variable "private_key" {
  default = "/root/.ssh/id_rsa-deploy-vscode"
}

variable "public_key" {
  default = "/root/.ssh/id_rsa-deploy-vscode.pub"
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "network-identifier" {
  default = "infra-internal"
}
