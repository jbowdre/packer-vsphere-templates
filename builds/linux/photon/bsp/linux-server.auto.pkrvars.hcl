/*
    DESCRIPTION:
    VMware Photon OS 4 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Guest Operating System Metadata
vm_guest_os_family   = "linux"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type = "vmwarePhoton64Guest"

// Virtual Machine Hardware Settings
vm_name                   = "bsp-appliance"
vm_firmware               = "efi-secure"
vm_cdrom_type             = "sata"
vm_cpu_count              = 2
vm_cpu_cores              = 1
vm_cpu_hot_add            = true
vm_mem_size               = 2048
vm_mem_hot_add            = true
vm_disk_size              = 81920
vm_disk_controller_type   = ["pvscsi"]
vm_disk_thin_provisioned  = true
vm_network_card           = "vmxnet3"

// Removable Media Settings
iso_url             = null
iso_path            = "_ISO"
iso_file            = "photon-4.0-c001795b8.iso"
iso_checksum_type   = "md5"
iso_checksum_value  = "5af288017d0d1198dd6bd02ad40120eb"


// Boot Settings
vm_boot_order       = "disk,cdrom"
vm_boot_wait        = "2s"
vm_boot_command = [
    "<esc><wait>c",
    "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 insecure_installation=1 ks=/dev/sr1:/ks.json photon.media=cdrom",
    "<enter>", "initrd /isolinux/initrd.img",
    "<enter>",
    "boot",
    "<enter>"
  ]

// Communicator Settings
communicator_port     = 22
communicator_timeout  = "20m"

// Provisioner Settings
post_install_scripts = [
  "scripts/linux/wait-for-cloud-init.sh",
  "scripts/linux/install-ca-certs.sh",
  "scripts/linux/persist-cloud-init-net.sh",
  "builds/linux/photon/bsp/setup-bsp.sh",
  "scripts/linux/update-packages.sh"
]

pre_final_scripts = [
  "scripts/linux/cleanup-cloud-init.sh",
  "scripts/linux/enable-vmware-customization.sh",
  "scripts/linux/cleanup-packages.sh",
  "scripts/linux/zero-disk.sh",
  "scripts/linux/generalize.sh"
]
