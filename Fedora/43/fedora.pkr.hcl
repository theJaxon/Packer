packer {
  required_plugins {
    virtualbox = {
      version = "1.1.3"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = "1.1.6"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "virtualbox-iso" "fedora" {
  iso_url              = "https://download.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-dvd-aarch64-43-1.6.iso"
  iso_checksum         = "file:https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-43-1.6-aarch64-CHECKSUM"
  iso_interface        = "virtio"
  guest_os_type        = "Fedora_arm64"
  memory               = "4096"
  headless             = false
  hard_drive_interface = "virtio"
  nic_type             = "virtio"
  communicator         = "ssh"
  ssh_port             = 22
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "15m"
  boot_wait            = "10s"
  firmware             = "efi"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vboxsvga"],
    ["modifyvm", "{{.Name}}", "--vram", "64"],
    ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
    ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
    ["modifyvm", "{{.Name}}", "--mouse", "usbtablet"]
  ]
  boot_command = [
    "<up>e<wait5><down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg <F10><wait>"
  ]
  http_port_min    = 8000
  http_port_max    = 8000
  http_directory   = "configuration"
  shutdown_command = "sudo shutdown -h now"
}

build {
  sources = ["source.virtualbox-iso.fedora"]

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      provider_override   = "virtualbox"
      output              = "fedora.box"
    }
  }
}