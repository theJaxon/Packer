source "amazon-ebs" "ubuntu" {
  region                      = var.region
  instance_type               = var.instance_type
  associate_public_ip_address = "true"
  ami_name                    = "xfce-ubuntu-{{timestamp}}"
  ami_description             = "ubuntu 20.04 machine with XFCE GUI Enabled"
  ssh_username                = "ubuntu"
  communicator                = "ssh"

  # Gathered with the command 
  # aws ec2 describe-images    --image-ids ami-030b8d2037063bab3
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"] # Ubuntu Owner ID
    most_recent = true
  }

  tags = {
    packer = "true",
    Name   = "xfce-ubuntu"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
  provisioner "shell" {
    inline = [
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install --yes ansible git",
      "ansible-galaxy install git+https://github.com/theJaxon/ansible-role-xfce-ubuntu"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "xfce-ubuntu/xfce-ubuntu.yaml"
    extra_arguments = ["--extra-vars", "\"ubuntu_password=${var.ubuntu_password}\"", "-vvv"]
  }
}