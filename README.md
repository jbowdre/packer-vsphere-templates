# Packer

Build Windows and Linux server templates on vSphere with Packer

### Currently supported builds:
#### Windows
- [Windows Server 2019](builds/windows/server/2019)
- [Windows Server 2022](builds/windows/server/2022)
#### Linux
- [Content Library Rsync appliance](builds/linux/photon/clr/) (details [here](https://github.com/jbowdre/content-library-rsync))
- [CentOS 7](builds/linux/cent/7/)
- [Red Hat Enterprise Linux 7](builds/linux/rhel/7/)
- [Red Hat Enterprise Linux 8](builds/linux/rhel/8/)
- [Red Hat Enterprise Linux 9](builds/linux/rhel/9)
- [Rocky Linux 9](builds/linux/rocky/9/)
- [Ubuntu Server 20.04 LTS](builds/linux/ubuntu/20-04-lts/)
- [Ubuntu Server 22.04 LTS](builds/linux/ubuntu/22-04-lts/)
- [VMware Photon OS 4](builds/linux/photon/4/)

To run a build locally (not via GitLab CI), you'll need to first export a few Vault-related environment variables:
```shell
export VAULT_ADDR="https://vault.lab.example.com"
export VAULT_NAMESPACE="example/LAB"      # (only available in Vault Enterprise)
export VAULT_TOKEN=""                     # insert a Vault token ID
```

Then just copy/paste the corresponding `packer build` line from [.gitlab-ci.yml](.gitlab-ci.yml). For example, to run a Windows Server 2022 build:
```shell
packer build -on-error=abort -force \
  -var-file="builds/common_configs/common.pkrvars.hcl" \
  "builds/windows/server/2022/"
```
