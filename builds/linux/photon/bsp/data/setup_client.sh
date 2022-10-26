#!/bin/sh -eu
# Creates the bsp-client configuration
if [ ! -f data/certs/key.pem ]; then
  echo '>> Allowing HTTP/HTTPS...'
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  iptables-save > /etc/systemd/scripts/ip4save

  echo '>> Generating SSL private key...'
  openssl genrsa -out data/certs/key.pem 4096

  echo '>> Generating SSL certificate signing request...'
  cat << EOF > data/certs/csr.conf
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[ req_distinguished_name ]
C = Country Code
ST = State Name
L = City Name
O = Organization Name
OU = Organization Unit
CN = $(hostname)

[ v3_req ]
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $(hostname)
DNS.2 = $(hostname -s)
DNS.3 = $(hostname -i)
EOF
  openssl req -new -out data/certs/$(hostname).csr -key data/certs/key.pem -config data/certs/csr.conf
  echo -e "\n>>> CSR generated: data/certs/$(hostname).csr"
  echo ">>> Place the CA-signed certificate in data/certs/cert.pem and re-run this script to complete the setup."
else
  echo '>> Creating docker-compose file...'
  cat << EOF > docker-compose.yaml
version: "3"
services:
  bsp-client:
    container_name: bsp-client
    restart: unless-stopped
    image: ghcr.io/jbowdre/library-syncer-client:latest
    environment:
      - LIBRARY_BROWSE=true
      - LIBRARY_NAME=$(hostname)
      - SYNC_DELAY_MAX_SECONDS=21600
      - SYNC_DELAY=true
      - SYNC_MAX_KBPS=10m
      - SYNC_PEER=
      - SYNC_PORT=2222
      - SYNC_SCHEDULE=0 21 * * 5
      - SYNC_SKIP_INITIAL=true
      - TLS_CUSTOM_CERT=true
      - TLS_NAME=$(hostname)
      - TZ=$(timedatectl status | grep zone | awk '{print $3}')
    ports:
      - "80:80/tcp"
      - "443:443/tcp"
    volumes:
      - './data/ssh:/syncer/.ssh'
      - '/opt/bsp-library:/syncer/library'
      - './data/certs:/etc/caddycerts'
EOF
  if [ ! -f data/certs/cert.pem ]; then
    echo '>> No cert found; removing TLS support...'
    sed -i 's/TLS_CUSTOM_CERT=.*$/TLS_CUSTOM_CERT=false/' docker-compose.yaml
    sed -i 's/TLS_NAME=.*$/TLS_NAME=/' docker-compose.yaml
  fi
  echo -e '\n>>> Setup complete! Edit docker-compose.yaml as appropriate and use "docker-compose up -d" to start the client.'
fi
