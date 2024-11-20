resource "openstack_compute_keypair_v2" "master_key" {
  name       = "master"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCil0P1jjiuPmEPF8zdySOC55t70pYdNESXUKOngZsQd6e4yTeOhZ8iZtCFpzVtiF3qLDCcDAwuScB2hw0+LDQHHsNSLOZi3xR+H9w7yxRLEQfSKIhpuBnsmvUHOX/9vjezYmZt6C7+txr7Rk8gyjzvy/PHDxlzsl8Z5owhbcmsxvW+JvQKqEjZkIDXQZqB/agAps54OFp8cmFkDMgZZseW7rmGLyIyuIZYzrWUIs8OshTgqebPFGMEOEzqYLLh28l9g6AYX/9QIES573ykcajGdCrIAFG6426B01BDGVTQVOLQvyugFUbYYJ1t7QFbpMdrX/tiNGJM/gUQgcgQTDb1 Generated-by-Nova"
}

resource "openstack_compute_instance_v2" "external_node" {
  name            = "VM-1"
  image_name      = "Ubuntu-24.04"
  flavor_name     = "standard.small"
  key_pair        = "${openstack_compute_keypair_v2.master_key.name}"
  security_groups = [openstack_networking_secgroup_v2.secgroup_vm1.name]

  network {
    name = "project_2011832"
  }
}

resource "openstack_compute_instance_v2" "internal_nodes" {
  name            = "VM-${count.index+2}"
  image_name      = "Ubuntu-24.04"
  flavor_name     = "standard.small"
  key_pair        = "${openstack_compute_keypair_v2.master_key.name}"
  security_groups = [openstack_networking_secgroup_v2.secgroup_vm_2_to_4.name]
  count           = 3

  network {
    name = "project_2011832"
  }
}

resource "openstack_networking_floatingip_v2" "fip_external_node" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_external_node" {
  floating_ip = openstack_networking_floatingip_v2.fip_external_node.address
  instance_id = openstack_compute_instance_v2.external_node.id
}


resource "openstack_networking_secgroup_v2" "secgroup_vm1" {
  name        = "VM-1 security group"
  description = "This security group is for public VM-1 created for ex 5 initially. It allows HTTP, SSH and internal communications in the project."
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "secgruop_vm1_inbound_projectnetwork" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min = 1 
  port_range_max = 65535 
  protocol = "tcp"
  remote_ip_prefix = "192.168.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_vm1_inbound_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min = 22
  port_range_max = 22
  protocol = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_vm1_inbound_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min = 80
  port_range_max = 80
  protocol = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_vm1_outbound_ssh" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_vm_2_to_4_outbound_ssh" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm_2_to_4.id
}

resource "openstack_networking_secgroup_v2" "secgroup_vm_2_to_4" {
  name        = "VMs-2-4 security group"
  description = "Internal communication to VM-1 only"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "secgruop_vm2_4_inbound_projectnetwork" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min = 1 
  port_range_max = 65535 
  protocol = "tcp"
  remote_ip_prefix  = "192.168.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.secgroup_vm_2_to_4.id
}