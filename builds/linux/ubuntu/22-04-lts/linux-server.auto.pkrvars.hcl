/*
  Ubuntu Server 22.04 LTS  variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Guest Operating System Metadata
vm_guest_os_family        = "linux"
vm_guest_os_keyboard      = "us"
vm_guest_os_language      = "en_US"
vm_guest_os_timezone      = "America/Chicago"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type          = "ubuntu64Guest"

//Virtual Machine Guest Partition Sizes (in MB)
vm_guest_part_audit       = 4096
vm_guest_part_boot        = 512
vm_guest_part_efi         = 512
vm_guest_part_home        = 8192
vm_guest_part_log         = 4096
vm_guest_part_root        = 0
vm_guest_part_swap        = 1024
vm_guest_part_tmp         = 4096
vm_guest_part_var         = 8192
vm_guest_part_vartmp      = 1024

// Virtual Machine Hardware Settings
vm_cdrom_type             = "sata"
vm_cpu_cores              = 1
vm_cpu_count              = 2
vm_cpu_hot_add            = true
vm_disk_controller_type   = ["pvscsi"]
vm_disk_size              = 61440
vm_disk_thin_provisioned  = true
vm_firmware               = "efi-secure"
vm_mem_hot_add            = true
vm_mem_size               = 2048
vm_name                   = "Ubuntu2204"
vm_network_card           = "vmxnet3"

// Removable Media Settings
iso_checksum_type         = "sha256"
iso_checksum_value        = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
iso_file                  = "ubuntu-22.04.2-live-server-amd64.iso"
iso_url                   = null

// Boot Settings
vm_boot_order             = "disk,cdrom"
vm_boot_wait              = "4s"
vm_boot_command = [
    "<esc><wait>c",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

// Communicator Settings
communicator_port         = 22
communicator_timeout      = "25m"

// Provisioner Settings
cloud_init_apt_packages = [
  "cloud-guest-utils",
  "net-tools",
  "perl",
  "vim",
  "wget"
]

post_install_scripts = [
  "scripts/linux/wait-for-cloud-init.sh",
  "scripts/linux/cleanup-subiquity.sh",
  "scripts/linux/install-ca-certs.sh",
  "scripts/linux/disable-multipathd.sh",
  "scripts/linux/disable-release-upgrade-motd.sh",
  "scripts/linux/persist-cloud-init-net.sh",
  "scripts/linux/configure-pam_mkhomedir.sh",
  "scripts/linux/update-packages.sh"
]

pre_final_scripts = [
  "scripts/linux/cleanup-cloud-init.sh",
  "scripts/linux/enable-vmware-customization.sh",
  "scripts/linux/cleanup-packages.sh",
  "builds/linux/ubuntu/22-04-lts/hardening.sh",
  "scripts/linux/zero-disk.sh",
  "scripts/linux/generalize.sh"
]
