#!/bin/sh -eu
# Creates the bsp-server configuration

iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

cat << EOF > docker-compose.yaml
version: "3"
services:
  bsp-server:
    container_name: bsp-server
    restart: unless-stopped
    image: harbor.lab.example.com/library/bsp-server:latest
    environment:
      - TZ=$(timedatectl status | grep zone | awk '{print $3}')
      - SYNCER_UID=31337
    ports:
      - "2222:22"
    volumes:
      - './data/ssh:/home/syncer/.ssh'
      - '/opt/bsp-library:/syncer/library'
EOF

echo '>>> Setup complete! Review docker-compose.yaml and use "docker-compose up -d" to start the server. <<<'
