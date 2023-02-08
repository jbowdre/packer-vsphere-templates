/*
  CentOS 7 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Guest Operating System Metadata
vm_guest_os_family        = "linux"
vm_guest_os_keyboard      = "us"
vm_guest_os_language      = "en_US"
vm_guest_os_timezone      = "America/Chicago"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type          = "centos7_64Guest"

// Virtual Machine Hardware Settings
vm_cdrom_type             = "sata"
vm_cpu_cores              = 1
vm_cpu_count              = 2
vm_cpu_hot_add            = true
vm_disk_controller_type   = ["pvscsi"]
vm_disk_size              = 61440
vm_disk_thin_provisioned  = true
vm_firmware               = "bios"
vm_mem_hot_add            = true
vm_mem_size               = 2048
vm_name                   = "Cent7"
vm_network_card           = "vmxnet3"

// Removable Media Settings
iso_checksum_type         = "sha256"
iso_checksum_value        = "e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987"
iso_file                  = "CentOS-7-x86_64-DVD-2009.iso"
iso_url                   = null

// Boot Settings
vm_boot_order             = "disk,cdrom"
vm_boot_wait              = "2s"
vm_boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    "text inst.ks=cdrom:/ks.cfg",
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
]

// Communicator Settings
communicator_port         = 22
communicator_timeout      = "25m"

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
