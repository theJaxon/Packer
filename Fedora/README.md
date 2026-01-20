### MKube Packer files
- Used to build the box for MKube project.
- It's currently based on Fedora distribution.

```bash
# Installs the plugins in case they're not present
packer init .

# Build the base box
packer build .
```

- Should result in a new Vagrant Box created.

---

### Testing Locally

```bash
vagrant box add mkube file://fedora.box
```
