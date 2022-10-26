/*
    DESCRIPTION:
    Common variables used for all builds.
    - Variables are use by the source blocks.
*/

// Virtual Machine Settings
common_vm_version           = 19
common_tools_upgrade_policy = true
common_remove_cdrom         = true

// Template and Content Library Settings
common_template_conversion         = false
common_content_library_name        = null
common_content_library_ovf         = false
common_content_library_destroy     = true
common_content_library_skip_export = true

// OVF Export Settings
common_ovf_export_enabled   = false
common_ovf_export_overwrite = true
common_ovf_export_path      = ""

// Removable Media Settings
common_iso_datastore    = ""

// Boot and Provisioning Settings
common_ip_wait_timeout  = "20m"
common_shutdown_timeout = "15m"
