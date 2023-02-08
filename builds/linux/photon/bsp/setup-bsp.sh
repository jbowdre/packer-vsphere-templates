#!/bin/bash -eu

# Install docker-compose
echo '>> Installing docker-compose script...'
sudo curl -sL "https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Enable/start docker
echo '>> Enabling and starting Docker...'
sudo systemctl enable docker
sudo systemctl start docker

# Install bsp-server
echo '>> Preparing bsp-server directory...'
sudo chmod 755 /opt
sudo mkdir -p /opt/bsp-library
sudo mkdir -p /opt/bsp-server/data/ssh
echo -e "${BSP_PUBLIC_KEY}" | sudo tee /opt/bsp-server/data/ssh/id_syncer.pub >/dev/null
sudo install -m 554 /tmp/data/setup_server.sh /opt/bsp-server/setup.sh

# Install bsp-client
echo '>> Preparing bsp-client directory...'
sudo mkdir -p /opt/bsp-client/data/{certs,ssh}
echo -e "${BSP_PRIVATE_KEY}" | sudo tee /opt/bsp-client/data/ssh/id_syncer >/dev/null
sudo install -m 554 /tmp/data/setup_client.sh /opt/bsp-client/setup.sh


