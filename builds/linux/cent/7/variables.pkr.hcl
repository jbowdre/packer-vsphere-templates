/*
  CentOS 7 variables using the Packer Builder for VMware vSphere (vsphere-iso).
*/

//  BLOCK: variable
//  Defines the input variables.

// Virtual Machine Settings

variable "common_remove_cdrom" {
  type          = bool
  description   = "Remove the virtual CD-ROM(s)."
  default       = true
}

variable "common_tools_upgrade_policy" {
  type          = bool
  description   = "Upgrade VMware Tools on reboot."
  default       = true
}

variable "common_vm_version" {
  type          = number
  description   = "The vSphere virtual hardware version. (e.g. '19')"
}

variable "vm_name" {
  type          = string
  description   = "Name of the new VM to create."
}

variable "vm_cdrom_type" {
  type          = string
  description   = "The virtual machine CD-ROM type. (e.g. 'sata', or 'ide')"
  default       = "sata"
}

variable "vm_cpu_cores" {
  type          = number
  description   = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "vm_cpu_count" {
  type          = number
  description   = "The number of virtual CPUs. (e.g. '2')"
}

variable "vm_cpu_hot_add" {
  type          = bool
  description   = "Enable hot add CPU."
  default       = true
}

variable "vm_disk_controller_type" {
  type          = list(string)
  description   = "The virtual disk controller types in sequence. (e.g. 'pvscsi')"
  default       = ["pvscsi"]
}

variable "vm_disk_eagerly_scrub" {
  type          = bool
  description   = "Enable VMDK eager scrubbing for VM."
  default       = false
}

variable "vm_disk_size" {
  type          = number
  description   = "The size for the virtual disk in MB. (e.g. '61440' = 60GB)"
  default       = 61440
}

variable "vm_disk_thin_provisioned" {
  type          = bool
  description   = "Thin provision the virtual disk."
  default       = true
}

variable "vm_firmware" {
  type          = string
  description   = "The virtual machine firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
  default       = "efi"
}

variable "vm_guest_os_family" {
  type          = string
  description   = "The guest operating system family. Used for naming. (e.g. 'linux')"
}

variable "vm_guest_os_keyboard" {
  type          = string
  description   = "The guest operating system keyboard input."
  default       = "us"
}

variable "vm_guest_os_language" {
  type          = string
  description   = "The guest operating system lanugage."
  default       = "en_US"
}

variable "vm_guest_os_timezone" {
  type          = string
  description   = "The guest operating system timezone."
  default       = "UTC"
}

variable "vm_guest_os_type" {
  type          = string
  description   = "The guest operating system type, also know as guestid. (e.g. 'ubuntu64Guest')"
}

variable "vm_mem_hot_add" {
  type          = bool
  description   = "Enable hot add memory."
  default       = true
}

variable "vm_mem_size" {
  type          = number
  description   = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_network_card" {
  type          = string
  description   = "The virtual network card type. (e.g. 'vmxnet3' or 'e1000e')"
  default       = "vmxnet3"
}

// VM Guest Partition Sizes
variable "vm_guest_part_audit" {
  type          = number
  description   = "Size of the /var/log/audit partition in MB."
}

variable "vm_guest_part_boot" {
  type          = number
  description   = "Size of the /boot partition in MB."
}

variable "vm_guest_part_home" {
  type          = number
  description   = "Size of the /home partition in MB."
}

variable "vm_guest_part_log" {
  type          = number
  description   = "Size of the /var/log partition in MB."
}

variable "vm_guest_part_root" {
  type          = number
  description   = "Size of the /var partition in MB. Set to 0 to consume all remaining free space."
  default       = 0
}

variable "vm_guest_part_swap" {
  type          = number
  description   = "Size of the swap partition in MB."
}

variable "vm_guest_part_tmp" {
  type          = number
  description   = "Size of the /tmp partition in MB."
}

variable "vm_guest_part_var" {
  type          = number
  description   = "Size of the /var partition in MB."
}

variable "vm_guest_part_vartmp" {
  type          = number
  description   = "Size of the /var/tmp partition in MB."
}

// Template and Content Library Settings

variable "common_content_library_destroy" {
  type          = bool
  description   = "Delete the virtual machine after exporting to the content library."
  default       = true
}

variable "common_content_library_name" {
  type          = string
  description   = "The name of the target vSphere content library, if used. (e.g. 'sfo-w01-cl01-lib01')"
  default       = null
}

variable "common_content_library_ovf" {
  type          = bool
  description   = "Export to content library as an OVF template."
  default       = false
}

variable "common_content_library_skip_export" {
  type          = bool
  description   = "Skip exporting the virtual machine to the content library. Option allows for testing / debugging without saving the machine image."
  default       = false
}

variable "common_template_conversion" {
  type          = bool
  description   = "Convert the virtual machine to template. Must be 'false' for content library."
  default       = false
}

// Snapshot Settings

variable "common_snapshot_creation" {
  type          = bool
  description   = "Create a snapshot for Linked Clones."
  default       = false
}

variable "common_snapshot_name" {
  type          = string
  description   = "Name of the snapshot to be created if create_snapshot is true."
  default       = "Created By Packer"
}

// OVF Export Settings

variable "common_ovf_export_enabled" {
  type          = bool
  description   = "Enable OVF artifact export."
  default       = false
}

variable "common_ovf_export_overwrite" {
  type          = bool
  description   = "Overwrite existing OVF artifact."
  default       = true
}

variable "common_ovf_export_path" {
  type          = string
  description   = "Folder path for the OVF export."
}

// Removable Media Settings

variable "cd_label" {
  type          = string
  description   = "CD Label"
  default       = "OEMDRV"
}

variable "iso_checksum_type" {
  type          = string
  description   = "The checksum algorithm used by the vendor. (e.g. 'sha256')"
}

variable "iso_checksum_value" {
  type          = string
  description   = "The checksum value provided by the vendor."
}

variable "iso_file" {
  type          = string
  description   = "The file name of the ISO image used by the vendor. (e.g. 'ubuntu-<version>-live-server-amd64.iso')"
}

variable "iso_url" {
  type          = string
  description   = "The URL source of the ISO image. (e.g. 'https://artifactory.rainpole.io/.../os.iso')"
}

// Boot Settings

variable "common_shutdown_timeout" {
  type          = string
  description   = "Time to wait for guest operating system shutdown."
}

variable "vm_boot_command" {
  type          = list(string)
  description   = "The virtual machine boot command."
  default       = []
}

variable "vm_boot_order" {
  type          = string
  description   = "The boot order for virtual machines devices. (e.g. 'disk,cdrom')"
  default       = "disk,cdrom"
}

variable "vm_boot_wait" {
  type          = string
  description   = "The time to wait before boot."
}

variable "vm_shutdown_command" {
  type          = string
  description   = "Command(s) for guest operating system shutdown."
  default       = null
}

variable "common_ip_wait_timeout" {
  type          = string
  description   = "Time to wait for guest operating system IP address response."
}

// Communicator Settings

variable "build_remove_keys" {
  type          = bool
  description   = "If true, Packer will attempt to remove its temporary key from ~/.ssh/authorized_keys and /root/.ssh/authorized_keys"
  default       = true
}

variable "communicator_insecure" {
  type          = bool
  description   = "If true, do not check server certificate chain and host name"
  default       = true
}

variable "communicator_port" {
  type          = string
  description   = "The port for the communicator protocol."
}

variable "communicator_ssl" {
  type          = bool
  description   = "If true, use SSL"
  default       = true
}

variable "communicator_timeout" {
  type          = string
  description   = "The timeout for the communicator protocol."
}

// Provisioner Settings

variable "kickstart_rpm_mirror" {
  type          = string
  description   = "Sets the default rpm mirror during the kickstart."
  default       = ""
}

variable "kickstart_rpm_packages" {
  type          = list(string)
  description   = "A list of rpm packages to install during the kickstart."
  default       = []
}

variable "post_install_scripts" {
  type          = list(string)
  description   = "A list of scripts and their relative paths to transfer and run after OS install."
  default       = []
}

variable "pre_final_scripts" {
  type          = list(string)
  description   = "A list of scripts and their relative paths to transfer and run before finalization."
  default       = []
}
