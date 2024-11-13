resource "openstack_compute_keypair_v2" "cloud-key" {
  name       = "ridvanKey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSXNHRNERD+4CMML2cLXCDLAgZ2KlvwXCTwv26IkSxPzscUJyttUrwH5BrgSPnpApkmSIJKAE60HYrEt/8rxysjGuU6MHKzE36Tnvpcqo5qVFYkzHToC5Vj035vCDE9y7bbaqPJLYcu1Mn0omBB6SIFG+7Q225l4m026FngreLcozDk9sqYmqarpyZFxZZlfOgJQt+N+YeDQdcO3RB7jbzCJceC9QxExWSDbEA1adJxYUo82FtStj1vDKge+vArkkz0H7GqjljX+s63yuLC6jm/Tx7RnWgi3v864tucKTcwn2phUiScPFrpLC91PUxVaxYW+DmLogse2lfhB0SV7Lp"
}

resource "openstack_compute_instance_v2" "external_node" {
  name            = "VM-1"
  image_name      = "Ubuntu-24.04"
  flavor_name     = "standard.small"
  key_pair        = "${openstack_compute_keypair_v2.cloud-key.name}"
  security_groups = [openstack_networking_secgroup_v2.secgroup_vm1.name]

  network {
    name = "project_2011832"
  }
}

resource "openstack_compute_instance_v2" "internal_nodes" {
  name            = "VM-${count.index+2}"
  image_name      = "Ubuntu-24.04"
  flavor_name     = "standard.small"
  key_pair        = "${openstack_compute_keypair_v2.cloud-key.name}"
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