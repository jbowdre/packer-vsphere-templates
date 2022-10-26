/*
    DESCRIPTION:
    Rocky Linux 9 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Guest Operating System Metadata
vm_guest_os_language = "en_US"
vm_guest_os_keyboard = "us"
vm_guest_os_timezone = "America/Chicago"
vm_guest_os_family   = "linux"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type = "other5xLinux64Guest"

// Virtual Machine Hardware Settings
vm_name                   = "Rocky9"
vm_firmware               = "efi"
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
iso_path            = ""
iso_file            = "Rocky-9.0-20220805.0-x86_64-minimal.iso"
iso_checksum_type   = "sha256"
iso_checksum_value  = "b16bc85f4fd14facf3174cd0cf8434ee048d81e5470292f3e1cfff47af2463b7"

// Boot Settings
vm_boot_order       = "disk,cdrom"
vm_boot_wait        = "2s"
vm_boot_command     = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    "text inst.ks=cdrom:/ks.cfg",
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
]

// Communicator Settings
communicator_port     = 22
communicator_timeout  = "20m"

// Provisioner Settings
post_install_scripts = [
  "scripts/linux/configure-sshd.sh",
  "scripts/linux/install-ca-certs.sh",
   "scripts/linux/update-packages.sh"
]

pre_final_scripts = [
  "scripts/linux/install-cloud-init.sh",
  "scripts/linux/persist-cloud-init-net.sh",
  "scripts/linux/cleanup-cloud-init.sh",
  "scripts/linux/enable-vmware-customization.sh",
  "scripts/linux/cleanup-packages.sh",
  "scripts/linux/zero-disk.sh",
  "scripts/linux/generalize.sh"
]
