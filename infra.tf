data "openstack_compute_keypair_v2" "keypair" {
  name = var.keypair
}

resource "openstack_compute_secgroup_v2" "secgroup_onlyssh" {
  name        = "onlyssh-${var.project_name}"
  description = "Only ssh for ${var.project_name}"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_onlyhttp" {
  name        = "onlyhttp-${var.project_name}"
  description = "Only http for ${var.project_name}"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "${var.project_name}.${var.parent_domain}"
  provider        = openstack
  security_groups = [
    "${openstack_compute_secgroup_v2.secgroup_onlyssh.name}",
    "${openstack_compute_secgroup_v2.secgroup_onlyhttp.name}",
  ]
  image_name      = var.image_name
  flavor_name     = var.flavor
  region          = var.region

  key_pair = data.openstack_compute_keypair_v2.keypair.name

  network {
		name = var.net_public
	}

  lifecycle {
    ignore_changes = [image_name]
  }

  connection {
		host = openstack_compute_instance_v2.vm.access_ip_v4
    user = "ubuntu"
  }

  provisioner "file" {
    content     = <<-EOT
export LE_EMAIL="${var.le_email}"
export DOMAIN="${openstack_compute_instance_v2.vm.name}"
export LE_PARAM_COMMON="${var.le_param_common}"
EOT
    destination = "/home/ubuntu/certbot_config.sh"
  }

  provisioner "file" {
    source      = "files/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "file" {
    source      = "files/update_certificates.sh"
    destination = "/home/ubuntu/update_certificates.sh"
  }

  provisioner "remote-exec" {
    script = "scripts/install-00.sh"
  }

  provisioner "remote-exec" {
    script = "scripts/install-01.sh"
  }
}

resource "ovh_domain_zone_record" "poc" {
  provider  = ovh
  zone      = var.parent_domain
  subdomain = var.project_name
  fieldtype = "A"
  ttl       = "300"
  target    = openstack_compute_instance_v2.vm.access_ip_v4
}

resource "local_file" "ssh_config" {
    content     = <<-EOT
Host ${openstack_compute_instance_v2.vm.name} ${openstack_compute_instance_v2.vm.name}-tun
  User ${var.ssh_user}
  Hostname ${openstack_compute_instance_v2.vm.access_ip_v4}
  UserKnownHostsFile ${path.module}/.ssh_known_hosts

Host ${openstack_compute_instance_v2.vm.name}-tun
  LocalForward 8080 127.0.0.1:8080
EOT
    filename = "${path.module}/.ssh_config"
}

output "ssh_command" {
  value = "ssh -F ${path.module}/.ssh_config ${openstack_compute_instance_v2.vm.name}"
}

output "ssh_tun_command" {
  value = "ssh -F ${path.module}/.ssh_config ${openstack_compute_instance_v2.vm.name}-tun"
}

output "scp_command" {
  value = "scp -F ${path.module}/.ssh_config files/docker-compose.yml files/update_certificates.sh ${openstack_compute_instance_v2.vm.name}:"
}

output "vm_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "vm_name" {
  value = openstack_compute_instance_v2.vm.name
}
