#!/bin/bash -eu
if [[ $(awk -F= '/^ID/{print $2}' /etc/os-release | grep rhel) ]]; then
  if [[ $(which dnf) ]]; then
    echo '>> Checking for and installing updates...'
    sudo dnf -y update
  else
    echo '>> Checking for and installing updates...'
    sudo yum -y update
  fi
  echo '>> Rebooting!'
  sudo reboot
elif [[ $(awk -F= '/^ID/{print $2}' /etc/os-release | grep debian) ]]; then
  echo '>> Checking for and installing updates...'
  sudo apt-get update && sudo apt-get -y upgrade
  echo '>> Rebooting!'
  sudo reboot
elif [[ $(awk -F= '/^ID/{print}' /etc/os-release | grep photon) ]]; then
  echo '>> Checking for and installing updates...'
  sudo tdnf update -y
  echo '>> Rebooting!'
  sudo reboot
fi