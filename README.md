# Packer

Packer Templates 

### Currently supported builds:
#### Windows
- [Windows Server 2019](builds/windows/server/2019)
- [Windows Server 2022](builds/windows/server/2022)
#### Linux
- [Rocky Linux 9](builds/linux/rocky/9/)
- [Red Hat Enterprise Linux 7](builds/linux/rhel/7/)
- [Red Hat Enterprise Linux 8](builds/linux/rhel/8/)
- [Red Hat Enterprise Linux 9](builds/linux/rhel/9)
- [Ubuntu Server 20.04 LTS](builds/linux/ubuntu/20-04-lts/)
- [VMware Photon OS 4](builds/linux/photon/4/)
- [Library syncer appliance](builds/linux/photon/bsp/)

To run a build locally (not via GitLab CI), just copy/paste the corresponding `packer build` line from [.gitlab-ci.yml](.gitlab-ci.yml). For example, to run a Windows Server 2022 build:
```shell
packer build -on-error=abort -force \
  -var-file="builds/common_configs/vsphere.pkrvars.hcl" \
  -var-file="builds/common_configs/build-win.pkrvars.hcl" \
  -var-file="builds/common_configs/common.pkrvars.hcl" \
  "builds/windows/server/2022/" 
  ```