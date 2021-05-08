terraform {
  required_version = "= 0.15.3"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "= 0.12.0"
    }

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "= 1.41.0"
    }
  }
}

variable flavor {
  default = "s1-2"
}

variable region {
  default = "GRA3"
}

variable keypair {
  default = "keypair"
}

variable project_name {
  default = "acme-test"
}

variable image_name {
  default = "Ubuntu 20.04"
}

variable ssh_user {
  default = "ubuntu"
}

variable net_public {
  default = "Ext-Net"
}

variable parent_domain {}

variable le_email {}

variable le_param_common {
  default = ""
}
