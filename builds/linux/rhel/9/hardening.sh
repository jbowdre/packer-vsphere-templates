#!/bin/bash -euncce_name
# Performs steps to harden RHEL9 toward the CIS Level 2 benchmark

echo ">>> Beginning hardening tasks..."

function current_task() {
  #$1 = Rule Name
  echo "-> $1..."
}

rule_name="Install AIDE"
current_task "$rule_name"
sudo dnf -y install aide

rule_name="Ensure Only Users Logged In To Real tty Can Execute Sudo - sudo use_pty"
current_task "$rule_name"
if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
  sudo cp /etc/sudoers /etc/sudoers.bak
  echo "Defaults use_pty" | sudo tee -a /etc/sudoers
  if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
    sudo rm -f /etc/sudoers.bak
  else
    echo "Fail to validate remediated /etc/sudoers, reverting to original file."
    sudo mv /etc/sudoers.bak /etc/sudoers
    false
  fi
else
  echo "Skipping remediation, /etc/sudoers failed to validate"
  false
fi

rule_name="Ensure Sudo Logfile Exists - sudo logfile"
current_task "$rule_name"
sudo_logfile='/var/log/sudo.log'
if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
  sudo cp /etc/sudoers /etc/sudoers.bak
  echo "Defaults logfile=${sudo_logfile}" | sudo tee -a /etc/sudoers
  if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
    sudo rm -f /etc/sudoers.bak
  else
    echo "Fail to validate remediated /etc/sudoers, reverting to original file."
    sudo mv /etc/sudoers.bak /etc/sudoers
    false
  fi
else
  echo "Skipping remediation, /etc/sudoers failed to validate"
  false
fi

rule_name="The operating system must require Re-Authentication when using the sudo command. Ensure sudo timestamp_timeout is appropriate - sudo timestamp_timeout"
current_task "$rule_name"
sudo_timestamp_timeout='5'
if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
  sudo cp /etc/sudoers /etc/sudoers.bak
  echo "Defaults timestamp_timeout=${sudo_timestamp_timeout}" | sudo tee -a /etc/sudoers
  if sudo /usr/sbin/visudo -qcf /etc/sudoers; then
    sudo rm -f /etc/sudoers.bak
  else
    echo "Fail to validate remediated /etc/sudoers, reverting to original file."
    sudo mv /etc/sudoers.bak /etc/sudoers
    false
  fi
else
  echo "Skipping remediation, /etc/sudoers failed to validate"
  false
fi

rule_name="Modify the System Login Banner | Modify the System Login Banner for Remote Connections"
current_task "$rule_name"
login_banner_text="\
I've read & consent to terms in IS user agreem't."
cat << EOF | sudo tee /etc/issue
\S
Kernel \r on an \m

$login_banner_text

EOF
cat << EOF | sudo tee /etc/issue.net

$login_banner_text

EOF

rule_name="Limit Password Reuse: password-auth | Limit Password Reuse: system-auth"
current_task "$rule_name"
password_pam_remember='5'
password_pam_remember_control_flag='requisite'
password_pam_remember_control_flag="$(echo $password_pam_remember_control_flag | cut -d \, -f 1)"
CURRENT_PROFILE=$(sudo authselect current -r | awk '{ print $1 }')
if [[ ! $CURRENT_PROFILE == custom/* ]]; then
  ENABLED_FEATURES=$(sudo authselect current | tail -n+3 | awk '{ print $2 }')
  sudo authselect create-profile hardening -b "$CURRENT_PROFILE"
  CURRENT_PROFILE="custom/hardening"
  sudo authselect apply-changes -b --backup=before-hardening-custom-profile
  sudo authselect select "$CURRENT_PROFILE"
  for feature in $ENABLED_FEATURES; do
    sudo authselect enable-feature "$feature";
  done
  sudo authselect apply-changes -b --backup=after-hardening-custom-profile
fi
pam_files=(
  "password-auth"
  "system-auth"
)
for pam_file in "${pam_files[@]}"; do
  pam_file_path="/etc/authselect/$CURRENT_PROFILE/$pam_file"
  sudo authselect apply-changes -b
  LAST_MATCH_LINE=$(grep -nP "^password.*requisite.*pam_pwquality\.so" "$pam_file_path" | tail -n 1 | cut -d: -f 1)
  sudo sed -i --follow-symlinks "$LAST_MATCH_LINE"' a password    '"$password_pam_remember_control_flag"'                                    pam_pwhistory.so remember='"$password_pam_remember" "$pam_file_path"
  sudo authselect apply-changes -b
done

rule_name="Lock Accounts After Failed Password Attempts | Set Lockout Time for Failed Password Attempts"
current_task "$rule_name"
passwords_pam_faillock_deny='3'
passwords_pam_faillock_time='900'
sudo authselect enable-feature with-faillock
sudo authselect apply-changes -b
FAILLOCK_CONF="/etc/security/faillock.conf"
regex_deny="^\s*deny\s*="
regex_time="^\s*unlock_time\s*="
line_deny="deny = $passwords_pam_faillock_deny"
line_time="unlock_time = $passwords_pam_faillock_time"
if ! grep -q "$regex_deny" $FAILLOCK_CONF; then
  echo "$line_deny" | sudo tee -a $FAILLOCK_CONF
else
  sudo sed -i --follow-symlinks 's|^\s*\(deny\s*=\s*\)\(\S\+\)|\1'"$passwords_pam_faillock_deny"'|g' $FAILLOCK_CONF
fi
if ! grep -q "$regex_time" $FAILLOCK_CONF; then
  echo "$line_time" | sudo tee -a $FAILLOCK_CONF
else
  sudo sed -i --follow-symlinks 's|^\s*\(unlock_time\s*=\s*\)\(\S\+\)|\1'"$passwords_pam_faillock_time"'|g' $FAILLOCK_CONF
fi
pam_files=(
  "password-auth"
  "system-auth"
)
for pam_file in "${pam_files[@]}"; do
  CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }' )
  if [[ ! $CURRENT_PROFILE == custom/* ]]; then
    ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
    sudo authselect create-profile hardening -b "$CURRENT_PROFILE"
    CURRENT_PROFILE="custom/hardening"
    sudo authselect apply-changes -b --backup=before-hardening-custom-profile
    sudo authselect select "$CURRENT_PROFILE"
    for feature in $ENABLED_FEATURES; do
      sudo authselect enable-feature "$feature";
    done
    sudo authselect apply-changes -b --backup=after-hardening-custom-profile
  fi
  pam_file_path="/etc/authselect/$CURRENT_PROFILE/$pam_file"
  sudo authselect apply-changes -b
  if grep -qP '^\s*auth\s.*\bpam_faillock.so\s.*\bdeny\b' "$pam_file_path"; then
    sudo sed -i -E --follow-symlinks 's/(.*auth.*pam_faillock.so.*)\bdeny\b=?[[:alnum:]]*(.*)/\1\2/g' "$pam_file_path"
  fi
  if grep -qP '^\s*auth\s.*\bpam_faillock.so\s.*\bunlock_time\b' "$pam_file_path"; then
    sudo sed -i -E --follow-symlinks 's/(.*auth.*pam_faillock.so.*)\bunlock_time\b=?[[:alnum:]]*(.*)/\1\2/g' "$pam_file_path"
  fi
  sudo authselect apply-changes -b
done

rule_name="Ensure PAM Enforces Password Requirements - Minimum Different Categories"
current_task "$rule_name"
password_pam_minclass='4'
sudo sed -i --follow-symlinks "s/^# minclass.*$/minclass = $password_pam_minclass/" /etc/security/pwquality.conf

rule_name="Ensure PAM Enforces Password Requirements - Minimum Length"
current_task "$rule_name"
password_pam_minlen='14'
sudo sed -i --follow-symlinks "s/^# minlen.*$/minlen = $password_pam_minlen/" /etc/security/pwquality.conf

rule_name="Ensure PAM Enforces Password Requirements - Authentication Retry Prompts Permitted Per-Session"
current_task "$rule_name"
password_pam_retry='3'
sudo sed -i --follow-symlinks "s/^# retry.*$/retry = $password_pam_retry/" /etc/security/pwquality.conf

rule_name="Set Account Expiration Following Inactivity"
current_task "$rule_name"
password_inactive_days='30'
sudo sed -i --follow-symlinks "s/^INACTIVE.*/INACTIVE=$password_inactive_days/" /etc/default/useradd

rule_name="Set Password Maximum Age"
current_task "$rule_name"
password_max_days='365'
sudo sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $password_max_days/g" /etc/login.defs

rule_name="Set Password Minimum Age"
current_task "$rule_name"
password_min_days='7'
sudo sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS     $password_min_days/g" /etc/login.defs

rule_name="Enforce usage of pam_wheel for su authentication"
current_task "$rule_name"
sudo sed '/^[[:space:]]*#[[:space:]]*auth[[:space:]]\+required[[:space:]]\+pam_wheel\.so[[:space:]]\+use_uid$/s/^[[:space:]]*#//' -i /etc/pam.d/su

rule_name="Ensure the Default Bash Umask is Set Correctly | Ensure the Default Umask is Set Correctly in login.defs | Ensure the Default Umask is Set Correctly in /etc/profile"
current_task "$rule_name"
account_user_umask='027'
sudo sed -i -E -e "s/^(\s*umask).*/\1 $account_user_umask/g" /etc/bashrc
sudo sed -i "s/^UMASK.*$/UMASK           $account_user_umask/g" /etc/login.defs
sudo sed -i "s/umask.*/umask $account_user_umask/g" /etc/profile
if ! grep -iq umask /etc/profile; then
  echo "umask $account_user_umask" | sudo tee -a /etc/profile
fi

rule_name="Set Interactive Session Timeout"
current_task "$rule_name"
account_tmout='900'
echo "declare -xr TMOUT=$account_tmout" | sudo tee -a /etc/profile.d/tmout.sh

rule_name="Record Events that Modify the System's Discretionary Access Controls: chmod, chown, fchmod, fchmodat, fchown, fchownat, fremovexattr, fsetxattr, lchown, lremovexattr, lsetxattr, removexattr, setxattr"
current_task "$rule_name"
audit_key="perm_mod"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "chmod"
  "chown"
  "fchmod"
  "fchmodat"
  "fchown"
  "fchownat"
  "fremovexattr"
  "fsetxattr"
  "lchown"
  "lremovexattr"
  "lsetxattr"
  "removexattr"
  "setxattr"
)
for audit_item in "${audit_list[@]}"; do
  if grep -q "xattr" <<< "$audit_item"; then
    audit_commands=(
      "-a always,exit -F arch=b32 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
      "-a always,exit -F arch=b32 -S $audit_item -F auid=0 -F key=$audit_key"
      "-a always,exit -F arch=b64 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
      "-a always,exit -F arch=b64 -S $audit_item -F audi=0 -F key=$audit_key"
    )
  else
    audit_commands=(
      "-a always,exit -F arch=b32 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
      "-a always,exit -F arch=b64 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
    )
  fi
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Record Any Attempts to Run Privileged Commands: chacl, setfacl, chcon, usermod"
current_task "$rule_name"
audit_key="privileged"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "/usr/bin/chacl"
  "/usr/bin/setfacl"
  "/usr/bin/chcon"
  "/usr/sbin/usermod"
)
for audit_item in "${audit_list[@]}"; do
  audit_command="-a always,exit -F path=$audit_item -F perm=x -F auid>=1000 -F auid!=unset -F key=$audit_key"
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Ensure auditd Collects File Deletion Events by User: rename, renameat, unlink, unlinkat"
current_task "$rule_name"
audit_key="delete"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "rename"
  "renameat"
  "rmdir"
  "unlink"
  "unlinkat"
)
for audit_item in "${audit_list[@]}"; do
  audit_commands=(
    "-a always,exit -F arch=b32 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
    "-a always,exit -F arch=b64 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
  )
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Record Unsuccessful Access Attempts to Files: creat, ftruncate, open, openat, truncate"
current_task "$rule_name"
audit_key="access"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "creat"
  "ftruncate"
  "open"
  "openat"
  "truncate"
)
for audit_item in "${audit_list[@]}"; do
  audit_commands=(
    "-a always,exit -F arch=b32 -S $audit_item -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=$audit_key"
    "-a always,exit -F arch=b32 -S $audit_item -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=$audit_key"
    "-a always,exit -F arch=b64 -S $audit_item -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=$audit_key"
    "-a always,exit -F arch=b64 -S $audit_item -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=$audit_key"
  )
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Ensure auditd Collects Information on Kernel Module Unloading: delete_module, init_module"
current_task "$rule_name"
audit_key="modules_unload"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "delete_module"
  "init_module"
)
for audit_item in "${audit_list[@]}"; do
  audit_commands=(
    "-a always,exit -F arch=b32 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
    "-a always,exit -F arch=b64 -S $audit_item -F auid>=1000 -F auid!=unset -F key=$audit_key"
  )
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Record Attempts to Alter Logon and Logout Events: faillock, lastlog"
current_task "$rule_name"
audit_key="logins"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "/var/log/lastlog"
  "/var/log/faillock"
)
for audit_item in "${audit_list[@]}"; do
  audit_commands=(
    "-w $audit_item -p wa -k $audit_key"
  )
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Record attempts to alter time: adjtimex, clock_settime, settimeofday, stime, localtime"
current_task "$rule_name"
audit_key="time"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-a always,exit -F arch=b32 -S adjtimex -F key=$audit_key"
  "-a always,exit -F arch=b64 -S adjtimex -F key=$audit_key"
  "-a always,exit -F arch=b32 -S clock_settime -F a0=0x0 -F key=$audit_key"
  "-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -F key=$audit_key"
  "-a always,exit -F arch=b32 -S settimeofday -F key=$audit_key"
  "-a always,exit -F arch=b64 -S settimeofday -F key=$audit_key"
  "-a always,exit -F arch=b32 -S stime -F key=$audit_key"
  "-w /etc/localtime -p wa -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Make the auditd Configuration Immutable"
current_task "$rule_name"
audit_key="immutable"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-e 2"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Record Events that Modify the System's Mandatory Access Controls"
current_task "$rule_name"
audit_key="MAC-policy"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-w /etc/selinux/ -p wa -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Ensure auditd Collects Information on Exporting to Media (successful)"
current_task "$rule_name"
audit_key="export"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -F key=$audit_key"
  "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -F key=$audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Record Events that Modify the System's Network Environment"
current_task "$rule_name"
audit_key="netconfig_mod"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-a always,exit -F arch=b32 -S sethostname,setdomainname -F key=$audit_key"
  "-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=$audit_key"
  "-w /etc/issue -p wa -k $audit_key"
  "-w /etc/issue.net -p wa -k $audit_key"
  "-w /etc/hosts -p wa -k $audit_key"
  "-w /etc/sysconfig/network -p wa -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Record Attempts to Alter Process and Session Initiation Information"
current_task "$rule_name"
audit_key="session"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-w /var/run/utmp -p wa -k $audit_key"
  "-w /var/log/btmp -p wa -k $audit_key"
  "-w /var/log/wtmp -p wa -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Record Events When Privileged Executables Are Run"
current_task "$rule_name"
audit_key="privileged"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k $audit_key"
  "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k $audit_key"
  "-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k $audit_key"
  "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Ensure auditd Collects System Administrator Actions"
current_task "$rule_name"
audit_key="admin_actions"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_commands=(
  "-w /etc/sudoers -p wa -k $audit_key"
  "-w /etc/sudoers.d/ -p wa -k $audit_key"
)
for audit_command in "${audit_commands[@]}"; do
  echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
done

rule_name="Record Events that Modify User/Group Information: /etc/group, /etc/gshadow, /etc/security/opasswd, /etc/passwd, /etc/shadow"
current_task "$rule_name"
audit_key="usergroup_mod"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_list=(
  "/etc/group"
  "/etc/gshadow"
  "/etc/passwd"
  "/etc/security/opasswd"
  "/etc/shadow"
)
for audit_item in "${audit_list[@]}"; do
  audit_commands=(
    "-w $audit_item -p wa -k $audit_key"
  )
  for audit_command in "${audit_commands[@]}"; do
    echo "${audit_command}" | sudo tee -a "${audit_rule_file}"
  done
done

rule_name="Record Attempts to perform maintenance activities"
current_task "$rule_name"
audit_key="maintenance"
audit_rule_file="/etc/audit/rules.d/${audit_key}.rules"
sudo touch "${audit_rule_file}"
sudo chmod 0640 "${audit_rule_file}"
audit_command="-w /var/log/sudo.log -p wa -k $audit_key"
echo "${audit_command}" | sudo tee -a "${audit_rule_file}"

rule_name="Configure auditd admin_space_left Action on Low Disk Space"
current_task "$rule_name"
auditd_option_name="admin_space_left_action"
auditd_option_value="halt"
auditd_config_file="/etc/audit/auditd.conf"
sudo sed -i "s/^${auditd_option_name}.*$/${auditd_option_name} = ${auditd_option_value}/" "${auditd_config_file}"

rule_name="Configure auditd max_log_file_action Upon Reaching Maximum Log Size"
current_task "$rule_name"
auditd_option_name="max_log_file_action"
auditd_option_value="keep_logs"
auditd_config_file="/etc/audit/auditd.conf"
sudo sed -i "s/^${auditd_option_name}.*$/${auditd_option_name} = ${auditd_option_value}/" "${auditd_config_file}"

rule_name="Configure auditd space_left Action on Low Disk Space"
current_task "$rule_name"
auditd_option_name="space_left_action"
auditd_option_value="email"
auditd_config_file="/etc/audit/auditd.conf"
sudo sed -i "s/^${auditd_option_name}.*$/${auditd_option_name} = ${auditd_option_value}/" "${auditd_config_file}"

rule_name="Enable Auditing for Processes Which Start Prior to the Audit Daemon"
current_task "$rule_name"
sudo sed -i "s/\(^GRUB_CMDLINE_LINUX=\".*\)\"/\1 audit=1\"/"  '/etc/default/grub'
sudo grubby --update-kernel=ALL --args=audit=1

rule_name="Extend Audit Backlog Limit for the Audit Daemon"
current_task "$rule_name"
sudo sed -i "s/\(^GRUB_CMDLINE_LINUX=\".*\)\"/\1 audit_backlog_limit=8192\"/"  '/etc/default/grub'
sudo grubby --update-kernel=ALL --args=audit_backlog_limit=8192

rule_name="Set Boot Loader Password in grub2"
current_task "$rule_name"
encrypted_grub_password=$(echo -e "$BOOTLOADER_PASSWORD\n$BOOTLOADER_PASSWORD" | grub2-mkpasswd-pbkdf2 | awk '/grub.pbkdf2/ { print $NF }')
echo "GRUB2_PASSWORD=${encrypted_grub_password}" | sudo tee /boot/grub2/user.cfg
sudo chmod 600 /boot/grub2/user.cfg
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

rule_name="Ensure journald is configured to compress large log files"
current_task "$rule_name"
journald_option_name="Compress"
journald_option_value="yes"
journald_config_file="/etc/systemd/journald.conf"
sudo sed -i "s/#${journald_option_name}.*$/${journald_option_name}=${journald_option_value}/" "${journald_config_file}"

rule_name="Ensure journald is configured to send logs to rsyslog"
current_task "$rule_name"
journald_option_name="ForwardToSyslog"
journald_option_value="yes"
journald_config_file="/etc/systemd/journald.conf"
sudo sed -i "s/#${journald_option_name}.*$/${journald_option_name}=${journald_option_value}/" "${journald_config_file}"

rule_name="Ensure journald is configured to write log files to persistent disk"
current_task "$rule_name"
journald_option_name="Storage"
journald_option_value="persistent"
journald_config_file="/etc/systemd/journald.conf"
sudo sed -i "s/#${journald_option_name}.*$/${journald_option_name}=${journald_option_value}/" "${journald_config_file}"

rule_name="Set Default firewalld Zone for Incoming Packets"
current_task "$rule_name"
# We can't set this to "drop" since VMware customization deletes/recreates the interface config file
sudo firewall-cmd --set-default-zone=public

rule_name="Configure Kernel Parameters"
# current_task "$rule_name"
sysctl_config_file="/etc/sysctl.d/99-hardening.conf"
sysctl_params=(
  "CCE-84120-5,Configure Accepting Routing Advertisements on All IPv6 Interfaces,net.ipv6.conf.all.accept_ra,0"
  "CCE-84125-4,Disable Accepting ICMP Redirects for All IPv6 Interfaces,net.ipv6.conf.all.accept_redirects,0"
  "CCE-84131-2,Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces,net.ipv6.conf.all.accept_source_route,0"
  "CCE-84114-8,Disable Kernel Parameter for IPv6 Forwarding,net.ipv6.conf.all.forwarding,0"
  "CCE-84124-7,Disable Accepting Router Advertisements on all IPv6 Interfaces by Default,net.ipv6.conf.default.accept_ra,0"
  "CCE-84113-0,Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces,net.ipv6.conf.default.accept_redirects,0"
  "CCE-84130-4,Disable Kernel Parameter for Accepting Source-Routed Packets on IPv6 Interfaces by Default,net.ipv6.conf.default.accept_source_route,0"
  "CCE-84011-6,Disable Accepting ICMP Redirects for All IPv4 Interfaces,net.ipv4.conf.all.accept_redirects,0"
  "CCE-84001-7,Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces,net.ipv4.conf.all.accept_source_route,0"
  "CCE-84000-9,Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces,net.ipv4.conf.all.log_martians,1"
  "CCE-84008-2,Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces,net.ipv4.conf.all.rp_filter,1"
  "CCE-84016-5,Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces,net.ipv4.conf.all.secure_redirects,0"
  "CCE-84003-3,Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces,net.ipv4.conf.default.accept_redirects,0"
  "CCE-84007-4,Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default,net.ipv4.conf.default.accept_source_route,0"
  "CCE-84014-0,Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default,net.ipv4.conf.default.log_martians,1"
  "CCE-84009-0,Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default,net.ipv4.conf.default.rp_filter,1"
  "CCE-84019-9,Configure Kernel Parameter for Accepting Secure Redirects By Default,net.ipv4.conf.default.secure_redirects,0"
  "CCE-84004-1,Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces,net.ipv4.icmp_echo_ignore_broadcasts,1"
  "CCE-84015-7,Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces,net.ipv4.icmp_ignore_bogus_error_responses,1"
  "CCE-84006-6,Enable Kernel Parameter to Use TCP Syncookies on Network Interfaces,net.ipv4.tcp_syncookies,1"
  "CCE-83997-7,Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces,net.ipv4.conf.all.send_redirects,0"
  "CCE-83999-3,Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default,net.ipv4.conf.default.send_redirects,0"
  "CCE-83998-5,Disable Kernel Parameter for IP Forwarding on IPv4 Interfaces,net.ipv4.ip_forward,0"
  "CCE-83971-2,Enable Randomized Layout of Virtual Address Space,kernel.randomize_va_space,2"
)
for sysctl_string in "${sysctl_params[@]}"; do
  IFS="," read -ra sysctl_array <<< "${sysctl_string}"
  printf '#[%s] %s\n%s = %s\n\n' "${sysctl_array[0]}" "${sysctl_array[1]}" "${sysctl_array[2]}" "${sysctl_array[3]}" | \
    sudo tee -a "${sysctl_config_file}"
done

rule_name="Disable modules: DCCP, SCTP, cramfs, squashfs, TIPC, udf, usb-storage"
current_task "$rule_name"
modules=(
  "cramfs"
  "dccp"
  "sctp"
  "squashfs"
  "tipc"
  "udf"
  "usb-storage"
)
for module in "${modules[@]}"; do
  module_file="/etc/modprobe.d/${module}-blacklist.conf"
  if LC_ALL=C grep -q -m 1 "^install ${module}" "${module_file}" 2>/dev/null; then
    sudo sed -i "s#^install ${module}.*#install ${module} /bin/true#g" "${module_file}"
  else
    echo "install ${module} /bin/true" | sudo tee -a "${module_file}"
  fi
  if ! LC_ALL=C grep -q -m 1 "^blacklist ${module}$" "${module_file}" 2>/dev/null; then
    echo "blacklist ${module}" | sudo tee -a "${module_file}"
  fi
done

rule_name="Add noexec Option to /dev/shm"
current_task "$rule_name"
mount_point_match_regexp="$(printf "[[:space:]]%s[[:space:]]" /dev/shm)"
if [ "$(grep -c "$mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
  previous_mount_opts=$(grep "$mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
    | sed -E "s/(rw|defaults|seclabel|noexec)(,|$)//g;s/,$//")
  [ "$previous_mount_opts" ] && previous_mount_opts+=","
  echo "tmpfs /dev/shm tmpfs defaults,${previous_mount_opts}noexec 0 0" | sudo tee -a /etc/fstab
elif [ "$(grep "$mount_point_match_regexp" /etc/fstab | grep -c "noexec")" -eq 0 ]; then
  previous_mount_opts=$(grep "$mount_point_match_regexp" /etc/fstab | awk '{print $4}')
  sudo sed -i "s|\(${mount_point_match_regexp}.*${previous_mount_opts}\)|\1,noexec|" /etc/fstab
fi
if sudo mkdir -p "/dev/shm"; then
  if mountpoint -q "/dev/shm"; then
    sudo mount -o remount --target "/dev/shm"
  else
    sudo mount --target "/dev/shm"
  fi
fi

rule_name="Disable core dump backtraces"
current_task "$rule_name"
sudo sed -i "s/^#ProcessSizeMax.*/ProcessSizeMax=0/" /etc/systemd/coredump.conf

rule_name="Disable storing core dump"
current_task "$rule_name"
sudo sed -i "s/^#Storage.*/Storage=none/" /etc/systemd/coredump.conf

rule_name="Ensure that /etc/cron.deny does not exist"
current_task "$rule_name"
sudo rm -f /etc/cron.deny

rule_name="Verify cron permissions (0700): cron.d, cron.daily, cron.hourly, cron.monthly, cron.weekly"
current_task "$rule_name"
var_paths=(
  "/etc/cron.d/"
  "/etc/cron.daily/"
  "/etc/cron.hourly/"
  "/etc/cron.monthly/"
  "/etc/cron.weekly/"
)
for path in "${var_paths[@]}"; do
  sudo find -H "${path}" -maxdepth 1 -perm /u+s,g+xwrs,o+xwrt -type d -exec chmod u-s,g-xwrs,o-xwrt {} \;
done

rule_name="Verify Permiissions on crontab (0600)"
current_task "$rule_name"
sudo chmod u-xs,g-xwrs,o-xwrt /etc/crontab

rule_name="Configure SSH Server"
current_task "$rule_name"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
SSH_CONFIG_FILE_BACKUP="/etc/ssh/sshd_config.bak"
sshd_options=(
  "AllowTcpForwarding no"
  "Banner /etc/issue.net"
  "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc"
  "ClientAliveCountMax 3"
  "ClientAliveInterval 300"
  "HostbasedAuthentication no"
  "IgnoreRhosts yes"
  "LoginGraceTime 60"
  "LogLevel VERBOSE"
  "MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1"
  "MaxAuthTries 4"
  "MaxSessions 10"
  "MaxStartups 10:30:60"
  "PasswordAuthentication yes"
  "PermitEmptyPasswords no"
  "PermitRootLogin no"
  "PermitUserEnvironment no"
  "PubkeyAuthentication yes"
  "X11Forwarding no"
)
for sshd_option in "${sshd_options[@]}"; do
  sshd_option_base=$(echo "${sshd_option}" | cut -d ' ' -f 1)
  sudo LC_ALL=C sed -i "/^\s*${sshd_option_base}\s\+/Id" "${SSH_CONFIG_FILE}"
  sudo cp "${SSH_CONFIG_FILE}" "${SSH_CONFIG_FILE_BACKUP}"
  line_number="$(sudo LC_ALL=C grep -n "^${sshd_option_base}" "${SSH_CONFIG_FILE_BACKUP}" | LC_ALL=C sed 's/:.*//g')"
  if [ -z "${line_number}" ]; then
    printf '%s\n' "${sshd_option}" | sudo tee -a "${SSH_CONFIG_FILE}"
  else
    head -n "$(( line_number - 1 ))" "${SSH_CONFIG_FILE_BACKUP}" | sudo tee "${SSH_CONFIG_FILE}"
    printf '%s\n' "${sshd_option}" | sudo tee -a "${SSH_CONFIG_FILE}"
    tail -n "$(( line_number ))" "${SSH_CONFIG_FILE_BACKUP}" | sudo tee -a "${SSH_CONFIG_FILE}}"
  fi
  sudo rm "${SSH_CONFIG_FILE_BACKUP}"
done

rule_name="Build and Test AIDE Database"
current_task "$rule_name"
sudo /usr/sbin/aide --init
sudo cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo ">>> Hardening script complete!"
