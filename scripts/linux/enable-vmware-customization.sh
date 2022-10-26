#!/bin/bash -eu
echo '>> Enabling VMware Guest Customization...'
echo 'disable_vmware_customization: false' | sudo tee -a /etc/cloud/cloud.cfg
sudo vmware-toolbox-cmd config set deployPkg enable-custom-scripts true
