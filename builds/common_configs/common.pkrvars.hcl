/*
  Common variables used for all builds.
  - Variables are use by the source blocks.
*/

// Virtual Machine Settings
common_remove_cdrom                   = true
common_tools_upgrade_policy           = true
common_vm_version                     = 19

// Template and Content Library Settings
common_content_library_destroy        = true
common_content_library_name           = null
common_content_library_ovf            = false
common_content_library_skip_export    = true
common_template_conversion            = false

// OVF Export Settings
common_ovf_export_enabled             = false
common_ovf_export_overwrite           = true
common_ovf_export_path                = ""

// Boot and Provisioning Settings
common_ip_wait_timeout                = "20m"
common_shutdown_timeout               = "15m"
