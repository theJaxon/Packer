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