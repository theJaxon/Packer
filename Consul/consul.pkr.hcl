source "amazon-ebs" "consul" {
  region                      = var.region
  instance_type               = var.instance_type
  associate_public_ip_address = "true"
  vpc_id                      = ""
  subnet_id                   = ""
  ami_name                    = "consul-{{timestamp}}"
  ami_description             = "Consul Machine Built with Packer"
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
    packer    = "true",
    is_server = var.is_server
  }
}

build {
  sources = ["source.amazon-ebs.consul"]
  provisioner "shell" {
    inline = [
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install --yes ansible git",
      "ansible-galaxy install git+https://github.com/theJaxon/Molecule_Testing"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "./consul.yml"
    extra_arguments = ["--extra-vars", "\"is_server=${var.is_server}\""]
  }

  provisioner "shell" {
    inline = [
      "cat /etc/consul.d/consul.hcl"
    ]
  }
}
