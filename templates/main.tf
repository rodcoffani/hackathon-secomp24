terraform {
    required_providers {
        mgc = {
        source = "MagaluCloud/mgc"
        }
    }
}

# Configuration options
provider "mgc" {
  region="br-ne1"
  alias = "nordeste"
}

// virtual_machines.tf
resource "mgc_virtual-machine_instances" "myvm" {
    provider = "mgc"
    name = "my-tf-vm"
    machine_type = {
        name = "cloud-bs1.xsmall"
    }

    image = {
        name = "cloud-ubuntu-22.04 LTS"
    }

    ssh_key_name = "my_ssh_key"
}