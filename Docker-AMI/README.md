# Docker AMI Build:
- Packer [Amazon EBS Builder](https://www.packer.io/docs/builders/amazon/ebs) is used to build this AMI based on the latest release of Amazon Linux 2
- Docker installation steps are from [AWS documentation page](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html)
- `ansible` directory contains the role used by [ansible provisioner](https://www.packer.io/docs/provisioners/ansible)
- `docker-ami` role installs and enables docker service, adds ec2-user to the docker group


