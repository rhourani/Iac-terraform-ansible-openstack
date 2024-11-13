# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = ""
  tenant_name = "project_2011832"
  password    = ""
  auth_url    = "https://pouta.csc.fi:5001/v3"
  region      = "regionOne"
  user_domain_name = "Default"
}

# Create a web server
#resource "openstack_compute_instance_v2" "test-server" {
  # ...
#}