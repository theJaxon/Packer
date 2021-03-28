# Packer
Testing HashiCorp's Packer - a tool for building Golden Images.

---

### Starting a Packer build:

```bash
# First prettify packer files
packer fmt Jenkins-AMI/

# Validate that the syntax is correct 
packer validate Jenkins-AMI/

# Start the build 
packer build Jenkins-AMI/
```

---

* Some issues were faced as a result of running as `ec2-user` instead of `root`
- To become root `execute_command` is used with the provisioner

<details>
<summary> Becoming root with shell provisioner</summary>
<p>

```HCL
  // Configure AMI as NAT Instance
  provisioner "shell" {
    /* 
    - execute_command changes the default user from ec2-user to root
    - sysctl commands aren't allowed to be run under the default ec2-user as they modify the kernel 
    */
    execute_command = "echo 'packer' | sudo -S env {{ .Vars }} {{ .Path }}"
    inline = [
      # https://www.kabisa.nl/tech/cost-saving-with-nat-instances/
      "sysctl -w net.ipv4.ip_forward=1 >> /etc/sysctl.conf",
      "/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "iptables-save > /etc/iptables.conf",
      "echo 'iptables-restore < /etc/iptables.conf' >> /etc/rc.local"
    ]
  }
```

</p>
</details>
