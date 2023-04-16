#!/bin/bash -eu
# Run a single packer build for testing
#
# Specify the build as an argument to the script. Ex:
# ./build.sh ubuntu2204

if [ ! "${VAULT_TOKEN+x}" ]; then
  #shellcheck disable=SC1091
  source vault-env.sh
fi

if [ $# -ne 1 ]; then
  echo """
Syntax: $0 [BUILD]

Where [BUILD] is one of the supported OS builds:

cent7 rhel7 rhel8 rhel9 rocky9
photon4 clr
ubuntu2004 ubuntu2204
ws2019 ws2022
"""
  exit 1
fi

build_name="${1,,}"
build_path=

case $build_name in
  cent7)
    build_path="builds/linux/cent/7/"
    ;;
  clr)
    build_path="builds/linux/photon/clr/"
    ;;
  photon4)
    build_path="builds/linux/photon/4/"
    ;;
  rhel7)
    build_path="builds/linux/rhel/7/"
    ;;
  rhel8)
    build_path="builds/linux/rhel/8/"
    ;;
  rhel9)
    build_path="builds/linux/rhel/9/"
    ;;
  rocky9)
    build_path="builds/linux/rocky/9/"
    ;;
  ubuntu2004)
    build_path="builds/linux/ubuntu/20-04-lts/"
    ;;
  ubuntu2204)
    build_path="builds/linux/ubuntu/22-04-lts/"
    ;;
  ws2019)
    build_path="builds/windows/server/2019/"
    ;;
  ws2022)
    build_path="builds/windows/server/2022/"
    ;;
  *)
    echo "Unknown build; exiting..."
    exit 1
    ;;
esac

packer init "${build_path}"
packer build -on-error=abort -force -var-file="builds/common_configs/common.pkrvars.hcl" "${build_path}"

