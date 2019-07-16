resource "null_resource" "generate-sshkey" {
    provisioner "local-exec" {
        command = "yes y | ssh-keygen -b 4096 -t rsa -C 'vscode-deploy' -N '' -f ${var.private_key}"
    }
}

resource "null_resource" "update-sshkey-permissions" {
    provisioner "local-exec" {
        command = "chmod 600 ${var.private_key}*"
    }
}

resource "openstack_compute_keypair_v2" "deploy-vscode-keypair" {
  name       = "deploy-vscode-keypair"
  public_key = "${file(var.public_key)}"
  depends_on = ["null_resource.generate-sshkey"]
}

resource "openstack_compute_secgroup_v2" "deploy-vscode-allow-external-8443" {
  name        = "deploy-vscode-allow-external-8443"
  description = "permitted inbound external TCP 8443 traffic"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8443
    to_port     = 8443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "10.240.0.0/24"
  }

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    cidr        = "10.240.0.0/24"
  }

}

data "openstack_networking_network_v2" "infra-internal" {
  name           = "${var.network-identifier}"
}

data "openstack_networking_subnet_v2" "infra-internal-subnet" {
  name       = "${var.network-identifier}"
  ip_version = 4
}
