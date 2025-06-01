packer {
  required_plugins {
    vmware = {
      version = "1.1.0"
      source  = "github.com/hashicorp/vmware"
    }
    vagrant = {
      version = "1.1.5"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "vmware-iso" "fedora" {
  iso_url                        = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-dvd-aarch64-42-1.1.iso"
  iso_checksum                   = "file:https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-42-1.1-aarch64-CHECKSUM"
  guest_os_type                  = "arm-fedora-64"
  cdrom_adapter_type             = "sata"
  disk_adapter_type              = "sata"
  network_adapter_type           = "vmxnet3"
  memory                         = "4096"
  headless                       = false
  usb                            = true
  vmx_remove_ethernet_interfaces = true
  network                        = "nat"
  communicator                   = "ssh"
  ssh_port                       = 22
  ssh_username                   = "vagrant"
  ssh_password                   = "vagrant"
  ssh_timeout                    = "15m"
  boot_wait                      = "1s"
  firmware                       = "efi"

  vmx_data = {
    "usb_xhci.present" = true
    "svga.autodetect"  = true
  }

  boot_command = [
    "<wait><up>e<wait><down><down><end>",
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<F10><wait>"
  ]
  http_port_min    = 8000
  http_port_max    = 8000
  http_directory   = "configuration"
  shutdown_command = "sudo shutdown -h now"
}

build {
  sources = ["source.vmware-iso.fedora"]

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      provider_override   = "vmware"
      output              = "fedora.box"
    }
  }
}