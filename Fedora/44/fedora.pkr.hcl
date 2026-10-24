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

# Kubernetes version the box is built for. kubeadm in the box must match it exactly,
# and images.txt must contain every image `kubeadm config images list` asks for.
locals {
  kubernetes_version = "v1.37.1"
}

# Where the build VM disk and the final fedora.box go. Point it at an external drive
# to keep multi-GB build artifacts off the internal disk.
variable "build_dir" {
  type    = string
  default = "."
}

source "virtualbox-iso" "fedora" {
  iso_url              = "https://download.fedoraproject.org/pub/fedora/linux/releases/44/Server/aarch64/iso/Fedora-Server-dvd-aarch64-44-1.7.iso"
  iso_checksum         = "file:https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Server/aarch64/iso/Fedora-Server-44-1.7-aarch64-CHECKSUM"
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

  # Lets fstrim in scripts/cleanup.sh release free blocks from the disk image
  hard_drive_discard       = true
  hard_drive_nonrotational = true

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
  output_directory = "${var.build_dir}/output-fedora"
}

build {
  sources = ["source.virtualbox-iso.fedora"]

  provisioner "file" {
    source      = "images.txt"
    destination = "/tmp/images.txt"
  }

  # Verify pinned versions, then pre-pull every image MKube deploys so provisioning skips registries
  provisioner "shell" {
    script           = "scripts/prepull.sh"
    environment_vars = ["KUBERNETES_VERSION=${local.kubernetes_version}", "IMAGES_FILE=/tmp/images.txt"]
    execute_command  = "sudo env {{ .Vars }} bash '{{ .Path }}'"
  }

  # Last step: drop caches and free space so the exported disk compresses well
  provisioner "shell" {
    script          = "scripts/cleanup.sh"
    execute_command = "sudo bash '{{ .Path }}'"
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      provider_override   = "virtualbox"
      compression_level   = 9
      output              = "${var.build_dir}/fedora.box"
    }
  }
}