/*
    DESCRIPTION:
    Microsoft Windows Server 2019 template using the Packer Builder for VMware vSphere (vsphere-iso).
*/

//  BLOCK: packer
//  The Packer configuration.

packer {
  required_version = ">= 1.8.2"
  required_plugins {
    vsphere     = {
      version   = ">= 1.0.8"
      source    = "github.com/hashicorp/vsphere"
    }
  }
}

//  BLOCK: locals
//  Defines the local variables.

locals {
  build_tool            = "HashiCorp Packer ${packer.version}"
  build_date            = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_description     = "Windows Server 2019 template\nBuild date: ${local.build_date}\nBuild tool: ${local.build_tool}"
  iso_paths           = ["[${var.common_iso_datastore}] ${var.iso_path}/${var.iso_file}", "[] /vmimages/tools-isoimages/${var.vm_guest_os_family}.iso"]
  iso_checksum        = "${var.iso_checksum_type}:${var.iso_checksum_value}"
  data_source_content = {
    "autounattend.xml"          = templatefile("${abspath(path.root)}/data/autounattend.pkrtpl.hcl", {
      build_username            = var.build_username
      build_password            = var.build_password
      vm_inst_os_language       = var.vm_inst_os_language
      vm_inst_os_keyboard       = var.vm_inst_os_keyboard
      vm_inst_os_image          = var.vm_inst_os_image
      vm_inst_os_kms_key        = var.vm_inst_os_kms_key
      vm_inst_os_org            = var.vm_inst_os_org
      vm_inst_os_support_phone  = var.vm_inst_os_support_phone
      vm_inst_os_support_url    = var.vm_inst_os_support_url
      vm_guest_os_language      = var.vm_guest_os_language
      vm_guest_os_keyboard      = var.vm_guest_os_keyboard
      vm_guest_os_timezone      = var.vm_guest_os_timezone
      vm_guest_os_hostname      = var.vm_name
    })
  }
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "vsphere-iso" "windows-server" {

  // vCenter Server Endpoint Settings and Credentials
  vcenter_server        = var.vsphere_endpoint
  username              = var.vsphere_username
  password              = var.vsphere_password
  insecure_connection   = var.vsphere_insecure_connection

  // vSphere Settings
  datacenter    = var.vsphere_datacenter
  cluster       = var.vsphere_cluster
  datastore     = var.vsphere_datastore
  folder        = var.vsphere_folder

  // Virtual Machine Settings
  vm_name                   = var.vm_name
  vm_version                = var.common_vm_version
  guest_os_type             = var.vm_guest_os_type
  firmware                  = var.vm_firmware
  CPUs                      = var.vm_cpu_count
  cpu_cores                 = var.vm_cpu_cores
  CPU_hot_plug              = var.vm_cpu_hot_add
  RAM                       = var.vm_mem_size
  RAM_hot_plug              = var.vm_mem_hot_add
  video_ram                 = var.vm_video_mem_size
  cdrom_type                = var.vm_cdrom_type
  remove_cdrom              = var.common_remove_cdrom
  disk_controller_type      = var.vm_disk_controller_type
  storage {
    disk_size               = var.vm_disk_size
    disk_thin_provisioned   = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network                 = var.vsphere_network
    network_card            = var.vm_network_card
  }
  tools_upgrade_policy      = var.common_tools_upgrade_policy
  notes                     = local.build_description
  configuration_parameters  = {
    "devices.hotplug"       = "FALSE"
  }

  // Removable Media Settings
  iso_url                   = var.iso_url
  iso_paths                 = local.iso_paths
  iso_checksum              = local.iso_checksum
  floppy_content            = local.data_source_content
  floppy_files              = [
    "${path.cwd}/scripts/${var.vm_guest_os_family}/",
    "${path.cwd}/certs/*"
  ]

  // Boot and Provisioning Settings
  boot_order          = var.vm_boot_order
  boot_wait           = var.vm_boot_wait
  boot_command        = var.vm_boot_command
  ip_wait_timeout     = var.common_ip_wait_timeout
  shutdown_command    = var.vm_shutdown_command
  shutdown_timeout    = var.common_shutdown_timeout

  // Communicator Settings and Credentials
  communicator    = "winrm"
  winrm_username  = var.build_username
  winrm_password  = var.build_password
  winrm_port      = var.communicator_port
  winrm_timeout   = var.communicator_timeout
  winrm_insecure  = var.communicator_insecure
  winrm_use_ssl   = var.communicator_ssl

  // Snapshot Settings
  create_snapshot   = var.common_snapshot_creation
  snapshot_name     = var.common_snapshot_name

  // Template and Content Library Settings
  convert_to_template   = var.common_template_conversion
  dynamic "content_library_destination" {
    for_each            = var.common_content_library_name != null ? [1] : []
    content {
      library           = var.common_content_library_name
      description       = local.build_description
      ovf               = var.common_content_library_ovf
      destroy           = var.common_content_library_destroy
      skip_import       = var.common_content_library_skip_export
    }
  }

  // OVF Export Settings
  dynamic "export" {
    for_each            = var.common_ovf_export_enabled == true ? [1] : []
    content {     
      name              = var.vm_name
      force             = var.common_ovf_export_overwrite
      options           = [
        "extraconfig"
      ]
      output_directory  = "${var.common_ovf_export_path}/${var.vm_name}"
    }
  }
}

//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.vsphere-iso.windows-server"
  ]

  provisioner "powershell" {
    elevated_user       = var.build_username
    elevated_password   = var.build_password
    scripts             = formatlist("${path.cwd}/%s", var.post_install_scripts)
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user       = var.build_username
    elevated_password   = var.build_password
    scripts             = formatlist("${path.cwd}/%s", var.pre_final_scripts)
  }
}