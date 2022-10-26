#!/bin/sh -eu
# Creates the bsp-server configuration

echo '>> Allowing rsync SSH on port 2222...'
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

echo '>> Creating docker-compose file...'
cat << EOF > docker-compose.yaml
version: "3"
services:
  bsp-server:
    container_name: bsp-server
    restart: unless-stopped
    image: ghcr.io/jbowdre/library-syncer-server:latest
    environment:
      - TZ=$(timedatectl status | grep zone | awk '{print $3}')
      - SYNCER_UID=31337
    ports:
      - "2222:22"
    volumes:
      - './data/ssh:/home/syncer/.ssh'
      - '/opt/bsp-library:/syncer/library'
EOF

echo '>> Setup complete! Edit docker-compose.yaml as appropriate and use "docker-compose up -d" to start the server.'
