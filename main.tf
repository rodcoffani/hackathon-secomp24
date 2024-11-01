terraform {
  required_providers {
    mgc = {
      source  = "terraform.local/local/mgc"
      version = "1.0.0"
    }
  }
}

locals {
  # instances_private_ips = [join(",", aws_instance.example[*].id)]
  instances_private_ips = []
}

provider "mgc" {
  alias  = "nordeste"
  region = "br-ne1"
}


resource "mgc_network_vpcs" "mongo_db_vpc" {
  provider = mgc.nordeste
  name        = "${var.hackathon_group}-${var.created_by}-mongodb-vpc"
  description = "${var.hackathon_group}-${var.created_by}-mongodb-vpc"
}

# LER README!!
resource "mgc_network_security_groups" "lb_security_group" {
  provider    = mgc.nordeste
  name = "${var.hackathon_group}-${var.created_by}-mongodb-sec-group"
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  description      = "Allow incoming MongoDB traffic"
  direction        = "ingress"
  ethertype        = "IPv4"
  port_range_max   = 27017
  port_range_min   = 27017
  protocol         = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = var.lb_security_group_id
}

resource "mgc_virtual_machine_instances" "instances" {
  provider = mgc.nordeste
  count    = var.cluster_size
  name     = "${var.hackathon_group}-${var.created_by}-mongodb-node-${count.index}"
  machine_type = {
    name = var.machine_type
  }
  image = {
    name = "cloud-ubuntu-22.04 LTS"
  }
  network = {
    vpc = {
      # id = mgc_network_vpc.mongo_db_vpc.network_id
      id = "240da5c2-7000-4b5e-ac42-f58c5723b78a"
    }
    associate_public_ip = false # If true, will create a public IP
    delete_public_ip    = false
  }

  ssh_key_name = var.ssh_key_name
}

resource "mgc_virtual_machine_instances" "lb" {
  provider = mgc.nordeste
  name     = "${var.hackathon_group}-${var.created_by}-mongodb-lb"
  machine_type = {
    name = "BV1-1-10"
  }
  image = {
    name = "cloud-ubuntu-22.04 LTS"
  }
  network = {
    vpc = {
      # id = mgc_network_vpc.mongo_db_vpc.network_id
      id = "240da5c2-7000-4b5e-ac42-f58c5723b78a"
    }
    associate_public_ip = true
    delete_public_ip    = true
    interface = {
      security_groups = [{ "id" : var.lb_security_group_id }]
    }
  }

  ssh_key_name = var.ssh_key_name
}