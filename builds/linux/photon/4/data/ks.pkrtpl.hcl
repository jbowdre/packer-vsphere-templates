{
    "hostname": "${ vm_guest_os_hostname }",
    "password":
        {
            "crypted": false,
            "text": "${ build_password }"
        },
    "disk": "/dev/sda",
    "partitions": [
        {
          "mountpoint": "/",
          "size": 0,
          "filesystem": "ext4",
          "lvm": {
            "vg_name": "sysvg",
            "lv_name": "lv_root"
          }
        },
        {
          "mountpoint": "/boot",
          "size": 128,
          "filesystem": "ext4"
        },
        {
          "mountpoint": "/tmp",
          "size": 512,
          "filesystem": "ext4",
          "lvm": {
            "vg_name": "sysvg",
            "lv_name": "lv_tmp"
          }
        },
        {
          "mountpoint": "/var",
          "size": 512,
          "filesystem": "ext4",
          "lvm": {
            "vg_name": "sysvg",
            "lv_name": "lv_var"
          }
        },
        {
          "mountpoint": "/var/log",
          "size": 512,
          "filesystem": "ext4",
          "lvm": {
            "vg_name": "sysvg",
            "lv_name": "lv_log"
          }
        },
        {
          "size": 512,
          "filesystem": "swap"
        }
    ],
    "bootmode": "efi",
    "packages": [
        "cloud-utils",
        "initramfs",
        "linux",
        "logrotate",
        "minimal",
        "nano",
        "openssl-c_rehash",
        "parted",
        "sudo",
        "vim"
    ],
    "postinstall": [
        "#!/bin/sh",
        "useradd -m -s /bin/bash ${ build_username }",
        "echo '${ build_username }:${ build_password }' | chpasswd",
        "usermod -aG sudo ${ build_username }",
        "echo \"${ build_username } ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers.d/${ build_username }",
        "chage -I -1 -m 0 -M 99999 -E -1 root",
        "chage -I -1 -m 0 -M 99999 -E -1 ${ build_username }",
        "sudo -u ${ build_username } mkdir -p /home/${ build_username }/.ssh",
%{ for ssh_key in ssh_keys ~}
        "echo \"${ ssh_key }\" | sudo -u ${ build_username } tee -a /home/${ build_username }/.ssh/authorized_keys",
%{ endfor }
        "systemctl restart iptables",
        "iptables -A INPUT -p icmp -j ACCEPT",
        "iptables-save > /etc/systemd/scripts/ip4save",
        "sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
        "sed -i 's/.*MaxAuthTries.*/MaxAuthTries 10/g' /etc/ssh/sshd_config",
        "systemctl restart sshd.service"
    ],
    "linux_flavor": "linux",
    "network": {
        "type": "dhcp"
    }
}
