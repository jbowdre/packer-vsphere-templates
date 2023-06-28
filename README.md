# Packer

Build Windows and Linux server templates on vSphere with Packer

### Currently supported builds:
#### Windows
- [Windows Server 2019](builds/windows/server/2019) (`ws2019`)
- [Windows Server 2022](builds/windows/server/2022) (`ws2022`)
#### Linux
- [Content Library Rsync appliance](builds/linux/photon/clr/) (`clr`) (details [here](https://github.com/jbowdre/content-library-rsync))
- [CentOS 7](builds/linux/cent/7/) (`cent7`)
- [Red Hat Enterprise Linux 7](builds/linux/rhel/7/) (`rhel7`)
- [Red Hat Enterprise Linux 8](builds/linux/rhel/8/) (`rhel8`)
- [Red Hat Enterprise Linux 9](builds/linux/rhel/9) (`rhel9`)
- [Rocky Linux 9](builds/linux/rocky/9/) (`rocky9`)
- [Ubuntu Server 20.04 LTS](builds/linux/ubuntu/20-04-lts/) (`ubuntu2004`)
- [Ubuntu Server 22.04 LTS](builds/linux/ubuntu/22-04-lts/) (`ubuntu2204`)
- [VMware Photon OS 4](builds/linux/photon/4/) (`photon4`)

To run a build locally (not via GitLab CI), you'll need to first export a few Vault-related environment variables:
```shell
export VAULT_ADDR="https://vault.lab.example.com/"      # your Vault server
export VAULT_NAMESPACE="example/LAB"                    # (if using namespaces in Vault Enterprise)
export VAULT_TOKEN="abcdefg"                            # insert a Vault token ID
```

Alternatively, put those same `export` commands into a script called `vault-env.sh`.

Then just run `./build.sh [BUILD]`, where `[BUILD]` is one of the descriptors listed above. For example, to build Ubuntu 22.04:
```shell
./build.sh ubuntu2204
```
