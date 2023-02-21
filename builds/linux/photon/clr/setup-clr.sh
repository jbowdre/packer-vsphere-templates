#!/bin/bash -eu

# Install docker-compose
echo '>> Installing docker-compose script...'
sudo curl -sL "https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Enable/start docker
echo '>> Enabling and starting Docker...'
sudo systemctl enable docker
sudo systemctl start docker

# Install clr-server
echo '>> Preparing clr-server directory...'
sudo chmod 755 /opt
sudo mkdir -p /opt/clr-library
sudo mkdir -p /opt/clr-server/data/ssh
echo -e "${CLR_PUBLIC_KEY}" | sudo tee /opt/clr-server/data/ssh/id_syncer.pub >/dev/null
sudo install -m 554 /tmp/data/setup_server.sh /opt/clr-server/setup.sh

# Install clr-client
echo '>> Preparing clr-client directory...'
sudo mkdir -p /opt/clr-client/data/{certs,ssh}
echo -e "${CLR_PRIVATE_KEY}" | sudo tee /opt/clr-client/data/ssh/id_syncer >/dev/null
sudo install -m 554 /tmp/data/setup_client.sh /opt/clr-client/setup.sh


