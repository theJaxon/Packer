source "amazon-ebs" "docker" {
  /* Grab the latest amazon linux 2 ami as a base image for this build
     This block is used instead of source_ami attribute */
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-hvm-*-x86_64-ebs"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  region        = var.aws_region
  instance_type = var.ec2_instance
  vpc_id        = ""
  subnet_id     = ""
  ssh_username  = "ec2-user"
  ami_name      = "packer_docker_build_{{timestamp}}"
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

build {
  sources = ["source.amazon-ebs.docker"]

  provisioner "ansible" {
    // Worked only by specifying the absolute path
    playbook_file    = ""
    ansible_env_vars = ["ANSIBLE_NOCOWS=1"]
  }
}