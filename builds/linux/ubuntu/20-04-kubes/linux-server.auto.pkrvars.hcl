/*
    DESCRIPTION:
    Ubuntu Server 20.04 LTS Kubernetes node variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Guest Operating System Metadata
vm_guest_os_language = "en_US"
vm_guest_os_keyboard = "us"
vm_guest_os_timezone = "America/Chicago"
vm_guest_os_family   = "linux"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type = "ubuntu64Guest"

// Virtual Machine Hardware Settings
vm_name                   = "kubes-u2004"
vm_firmware               = "efi-secure"
vm_cdrom_type             = "sata"
vm_cpu_count              = 2
vm_cpu_cores              = 1
vm_cpu_hot_add            = true
vm_mem_size               = 2048
vm_mem_hot_add            = true
vm_disk_size              = 61440
vm_disk_controller_type   = ["pvscsi"]
vm_disk_thin_provisioned  = true
vm_network_card           = "vmxnet3"

// Removable Media Settings
iso_url             = null
iso_path            = "_ISO"
iso_file            = "ubuntu-20.04.5-live-server-amd64.iso"
iso_checksum_type   = "sha256"
iso_checksum_value  = "5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"

// Boot Settings
vm_boot_order       = "disk,cdrom"
vm_boot_wait        = "4s"
vm_boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

// Communicator Settings
communicator_port     = 22
communicator_timeout  = "20m"

// Provisioner Settings
post_install_scripts = [
  "scripts/linux/wait-for-cloud-init.sh",
  "scripts/linux/cleanup-subiquity.sh",
  "scripts/linux/install-ca-certs.sh",
  "scripts/linux/disable-multipathd.sh",
  "scripts/linux/disable-release-upgrade-motd.sh",
  "scripts/linux/persist-cloud-init-net.sh",
  "scripts/linux/install-kubernetes.sh",
  "scripts/linux/update-packages.sh"
]

pre_final_scripts = [
  "scripts/linux/cleanup-cloud-init.sh",
  "scripts/linux/enable-vmware-customization.sh",
  "scripts/linux/zero-disk.sh",
  "scripts/linux/generalize.sh"
]

// Kubernetes Settings
kubernetes_version = "1.25.3"