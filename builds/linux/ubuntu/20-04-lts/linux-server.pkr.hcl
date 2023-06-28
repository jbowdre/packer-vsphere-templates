/*
  Ubuntu Server 20.04 LTS template using the Packer Builder for VMware vSphere (vsphere-iso).
*/

//  BLOCK: packer
//  The Packer configuration.

packer {
  required_version              = ">= 1.8.2"
  required_plugins {
    vsphere = {
      version                   = ">= 1.0.8"
      source                    = "github.com/hashicorp/vsphere"
    }
    sshkey = {
      version                   = "= 1.0.3"
      source                    = "github.com/ivoronin/sshkey"
    }
  }
}

//  BLOCK: locals
//  Defines the local variables.

// Dynamically-generated SSH key
data "sshkey" "install" {
  type                          = "ed25519"
  name                          = "packer_key"
}

////////////////// Vault Locals //////////////////
// To retrieve secrets from Vault, the following environment variables MUST be defined:
//  - VAULT_ADDR        : base URL of the Vault server ('https://vault.example.com/')
//  - VAULT_NAMESPACE   : namespace path to where the secrets live ('organization/sub-org')
//  - VAULT_TOKEN       : token ID with rights to read/list
//
// Syntax for the vault() call:
//    vault("SECRET_ENGINE/data/SECRET_NAME", "KEY")
//
// Standard configuration values:
locals {
  build_public_key              = vault("packer/data/linux",            "public_key")           // SSH public key for the default admin account
  build_username                = vault("packer/data/linux",            "username")             // Username for the default admin account
  vsphere_cluster               = vault("packer/data/vsphere",          "cluster")              // Name of the target vSphere cluster
  vsphere_datacenter            = vault("packer/data/vsphere",          "datacenter")           // Name of the target vSphere datacenter
  vsphere_datastore             = vault("packer/data/vsphere",          "datastore")            // Name of the target vSphere datastore
  vsphere_endpoint              = vault("packer/data/vsphere",          "endpoint")             // FQDN/IP of the target vCenter
  vsphere_folder                = vault("packer/data/vsphere",          "folder")               // Folder path where the VM will be created (relative to the datacenter)
  vsphere_insecure_connection   = vault("packer/data/vsphere",          "insecure_connection")  // Boolean for whether or not to skip verification of the endpoint certificate
  vsphere_iso_datastore         = vault("packer/data/vsphere",          "iso_datastore")        // vSphere datastore holding the installation ISO
  vsphere_iso_path              = vault("packer/data/vsphere",          "iso_path")             // Folder path to the installation ISO (relative to the datastore)
  vsphere_network               = vault("packer/data/vsphere",          "network")              // Name of the vSphere portgroup where the VM should be attached
  vsphere_username              = vault("packer/data/vsphere",          "username")             // Username for authenticating to vSphere
}
// Sensitive values:
local "bootloader_password"{
  expression                    = vault("packer/data/linux",            "bootloader_password")  // Password to set for the bootloader
  sensitive                     = true
}
local "build_password" {
  expression                    = vault("packer/data/linux",            "password")             // Password to set for the default admin account
  sensitive                     = true
}
local "vsphere_password" {
  expression                    = vault("packer/data/vsphere",          "password")             // Password for authenticating to vSphere
  sensitive                     = true
}

////////////////// End Vault Locals //////////////////

locals {
  build_date                    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_description             = "Ubuntu Server 20.04 LTS template\nBuild date: ${local.build_date}\nBuild tool: ${local.build_tool}"
  build_tool                    = "HashiCorp Packer ${packer.version}"
  iso_checksum                  = "${var.iso_checksum_type}:${var.iso_checksum_value}"
  iso_paths                     = ["[${local.vsphere_iso_datastore}] ${local.vsphere_iso_path}/${var.iso_file}"]
  shutdown_command              = "sudo sh -c 'rm -f /etc/sudoers.d/*; /usr/sbin/shutdown -P now'"
  ssh_private_key_file          = data.sshkey.install.private_key_path
  ssh_public_key                = data.sshkey.install.public_key
  data_source_content = {
    "/meta-data"                = file("${abspath(path.root)}/data/meta-data")
    "/user-data"                = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      apt_mirror                = var.cloud_init_apt_mirror
      apt_packages              = var.cloud_init_apt_packages
      build_username            = local.build_username
      ssh_keys                  = concat([local.ssh_public_key], [local.build_public_key])
      vm_guest_os_hostname      = var.vm_name
      vm_guest_os_keyboard      = var.vm_guest_os_keyboard
      vm_guest_os_language      = var.vm_guest_os_language
      vm_guest_os_timezone      = var.vm_guest_os_timezone
      vm_guest_part_audit       = var.vm_guest_part_audit
      vm_guest_part_boot        = var.vm_guest_part_boot
      vm_guest_part_efi         = var.vm_guest_part_efi
      vm_guest_part_home        = var.vm_guest_part_home
      vm_guest_part_log         = var.vm_guest_part_log
      vm_guest_part_root        = var.vm_guest_part_root
      vm_guest_part_swap        = var.vm_guest_part_swap
      vm_guest_part_tmp         = var.vm_guest_part_tmp
      vm_guest_part_var         = var.vm_guest_part_var
      vm_guest_part_vartmp      = var.vm_guest_part_vartmp
    })
  }
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "vsphere-iso" "linux-server" {

  // vCenter Server Endpoint Settings and Credentials
  insecure_connection           = local.vsphere_insecure_connection
  password                      = local.vsphere_password
  username                      = local.vsphere_username
  vcenter_server                = local.vsphere_endpoint

  // vSphere Settings
  cluster                       = local.vsphere_cluster
  datacenter                    = local.vsphere_datacenter
  datastore                     = local.vsphere_datastore
  folder                        = local.vsphere_folder

  // Virtual Machine Settings
  cdrom_type                    = var.vm_cdrom_type
  cpu_cores                     = var.vm_cpu_cores
  CPU_hot_plug                  = var.vm_cpu_hot_add
  CPUs                          = var.vm_cpu_count
  disk_controller_type          = var.vm_disk_controller_type
  firmware                      = var.vm_firmware
  guest_os_type                 = var.vm_guest_os_type
  notes                         = local.build_description
  RAM                           = var.vm_mem_size
  RAM_hot_plug                  = var.vm_mem_hot_add
  remove_cdrom                  = var.common_remove_cdrom
  tools_upgrade_policy          = var.common_tools_upgrade_policy
  vm_name                       = var.vm_name
  vm_version                    = var.common_vm_version
  configuration_parameters = {
    "devices.hotplug"           = "FALSE"
  }
  network_adapters {
    network                     = local.vsphere_network
    network_card                = var.vm_network_card
  }
  storage {
    disk_size                   = var.vm_disk_size
    disk_thin_provisioned       = var.vm_disk_thin_provisioned
  }

  // Removable Media Settings
  cd_content                    = local.data_source_content
  cd_label                      = var.cd_label
  iso_checksum                  = local.iso_checksum
  iso_paths                     = local.iso_paths
  iso_url                       = var.iso_url

  // Boot and Provisioning Settings
  boot_command                  = var.vm_boot_command
  boot_order                    = var.vm_boot_order
  boot_wait                     = var.vm_boot_wait
  ip_wait_timeout               = var.common_ip_wait_timeout
  shutdown_command              = local.shutdown_command
  shutdown_timeout              = var.common_shutdown_timeout

  // Communicator Settings and Credentials
  communicator                  = "ssh"
  ssh_clear_authorized_keys     = var.build_remove_keys
  ssh_port                      = var.communicator_port
  ssh_private_key_file          = local.ssh_private_key_file
  ssh_timeout                   = var.communicator_timeout
  ssh_username                  = local.build_username

  // Snapshot Settings
  create_snapshot               = var.common_snapshot_creation
  snapshot_name                 = var.common_snapshot_name

  // Template and Content Library Settings
  convert_to_template           = var.common_template_conversion
  dynamic "content_library_destination" {
    for_each                    = var.common_content_library_name != null ? [1] : []
    content {
      description               = local.build_description
      destroy                   = var.common_content_library_destroy
      library                   = var.common_content_library_name
      ovf                       = var.common_content_library_ovf
      skip_import               = var.common_content_library_skip_export
    }
  }

  // OVF Export Settings
  dynamic "export" {
    for_each                    = var.common_ovf_export_enabled == true ? [1] : []
    content {
      force                     = var.common_ovf_export_overwrite
      name                      = var.vm_name
      options                   = ["extraconfig"]
      output_directory          = "${var.common_ovf_export_path}/${var.vm_name}"
    }
  }
}

//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.vsphere-iso.linux-server"
  ]

  provisioner "file" {
    source                      = "certs"
    destination                 = "/tmp"
  }

  provisioner "file" {
    source                      = "scripts/linux/join-domain.sh"
    destination                 = "/home/${local.build_username}/join-domain.sh"
  }

  provisioner "shell" {
    execute_command             = "bash {{ .Path }}"
    expect_disconnect           = true
    scripts                     = formatlist("${path.cwd}/%s", var.post_install_scripts)
  }

  provisioner "shell" {
    env                         = {
      "ADMIN_USERNAME"          = local.build_username
      "ADMIN_PASSWORD"          = local.build_password
      "BOOTLOADER_PASSWORD"     = local.bootloader_password
    }
    execute_command             = "{{ .Vars }} bash {{ .Path }}"
    expect_disconnect           = true
    pause_before                = "30s"
    scripts                     = formatlist("${path.cwd}/%s", var.pre_final_scripts)
  }
}
