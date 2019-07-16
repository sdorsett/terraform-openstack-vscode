provider "openstack" {}

data "openstack_images_image_v2" "ubuntu_18_04" {
  name = "Ubuntu 18.04"
  most_recent = true
}

data "openstack_compute_flavor_v2" "s1-2" {
  name = "s1-8"
}

resource "openstack_compute_instance_v2" "vscode" {
  name            = "vscode"
  image_id        = "${data.openstack_images_image_v2.ubuntu_18_04.id}"
  flavor_id       = "${data.openstack_compute_flavor_v2.s1-2.id}"
  key_pair        = "${openstack_compute_keypair_v2.deploy-vscode-keypair.name}"
  security_groups = ["${openstack_compute_secgroup_v2.deploy-vscode-allow-external-8443.name}"]
  user_data       = "${file("./cloudinit.txt")}" 

  network {
    name = "Ext-Net",
  }

  network {
    name = "${data.openstack_networking_network_v2.infra-internal.name}"
    fixed_ip_v4 = "10.240.0.1"
  }

  metadata {
    deploy-k8s = "vscode"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostname -f",
    ]
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key)}"
    }
  }

  provisioner "file" {
    source      = "openrc.sh"
    destination = "/tmp/openrc.sh"
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key)}"
    }
  }
}

