# Jenkins AMI Build:
- Packer [Amazon EBS Builder](https://www.packer.io/docs/builders/amazon/ebs) is used to build this AMI based on the latest release of Amazon Linux 2
- Jenkins installation steps are from their [documentation page](https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/#Download%20and%20Install%20Jenkins)
- `ansible` directory contains the role used by [ansible provisioner](https://www.packer.io/docs/provisioners/ansible)
- `jenkins-ami` role simply adds Jenkins repo then install, start and enable jenkins service on startup
- `.repo` file is copied into `/etc/yum.repos.d` because the provided URL couldn't be handled using `yum_repository` module as per the [answer](https://stackoverflow.com/a/65933906)

