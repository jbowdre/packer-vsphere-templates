/*
    DESCRIPTION:
    Microsoft Windows Server 2022 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Installation Operating System Metadata
vm_inst_os_language                 = "en-US"
vm_inst_os_keyboard                 = "en-US"
vm_inst_os_image                    = "Windows Server 2022 Standard (Desktop Experience)"
vm_inst_os_kms_key                  = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
vm_inst_os_org                      = "Company Name"
vm_inst_os_support_phone            = "867-5309"
vm_inst_os_support_url              = "https://google.com"

// Guest Operating System Metadata
vm_guest_os_language            = "en-US"
vm_guest_os_keyboard            = "en-US"
vm_guest_os_timezone            = "Central Standard Time"
vm_guest_os_family              = "windows"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type = "windows2019srvNext_64Guest"

// Virtual Machine Hardware Settings
vm_name                   = "WS2022"
vm_firmware               = "efi-secure"
vm_cdrom_type             = "sata"
vm_cpu_count              = 2
vm_cpu_cores              = 1
vm_cpu_hot_add            = true
vm_mem_size               = 4096
vm_mem_hot_add            = true
vm_disk_size              = 61440
vm_disk_controller_type   = ["pvscsi"]
vm_disk_thin_provisioned  = true
vm_network_card           = "vmxnet3"

// Removable Media Settings
iso_url             = null
iso_path            = "_ISO"
iso_file            = "SERVER_2022.iso"
iso_checksum_type   = "sha256"
iso_checksum_value  = "5F3A9413397FB1EB2406012B601625F2FD6B35B51E51A0F52CFB73BDCDA7B88C"

// Boot Settings
vm_boot_order       = "disk,cdrom"
vm_boot_wait        = "2s"
vm_boot_command     = ["<spacebar>"]
vm_shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Shutdown by Packer\""

// Communicator Settings
communicator_port    = 5986
communicator_timeout = "70m"

// Provisioner Settings
post_install_scripts = [
  "scripts/windows/Create-PayloadFolder.ps1",
  "scripts/windows/Disable-WinServices.ps1",
  "scripts/windows/Disable-IPv6.ps1",
  "scripts/windows/Enable-LUA.ps1",
]

pre_final_scripts = [
  "scripts/windows/Clear-ActionCenterNotifications.ps1",
  "scripts/windows/Clear-EventLogs.ps1"
]
