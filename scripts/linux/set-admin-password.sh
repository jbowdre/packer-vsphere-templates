#!/bin/bash -eu

echo ">> Setting admin password..."
echo "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" | sudo chpasswd
