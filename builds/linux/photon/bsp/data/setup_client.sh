#!/bin/bash -eu
peer=
tls="n"

getInputs() {
  read -rp 'FQDN of the upstream BSP appliance to sync content from: ' peer
  read -rp 'Enable TLS? (y/N): ' tls
}

helpText() {
  echo -e "\nUsage: $0 -p UPSTREAM_PEER [-s] [-t]"
  echo -e "\nMandatory parameter:"
  echo -e "\t-p, --peer UPSTREAM_PEER \tFully-qualified domain name of the upstream BSP appliance to sync content from"
  echo -e "\nOptional flags:"
  echo -e "\t-t, --enable-tls \t\t\tEnable TLS (if not set, the BSP library will be served over HTTP)"
  exit 0
}

generateCsr() {
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
C = US
ST = Alabama
L = Huntsville
O = Example Org
OU = LAB
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
  openssl req -new -out "data/certs/$(hostname).csr" -key data/certs/key.pem -config data/certs/csr.conf
  echo ">> CSR generated: data/certs/$(hostname).csr"
  echo ">>> Place the CA-signed certificate in data/certs/cert.pem and re-run $0 to complete the setup. <<<"
  doConfig
  exit 0
}

enableTls() {
  echo '>> Found custom certificate; enabling TLS support...'
  sed -i "s/TLS_CUSTOM_CERT=.*$/TLS_CUSTOM_CERT=true/" docker-compose.yaml
  sed -i "s/TLS_NAME=.*$/TLS_NAME=$(hostname)/" docker-compose.yaml
  echo '>>> Setup complete! Review docker-compose.yaml and use "docker-compose up -d" to start the client. <<<'
  exit 0
}

doConfig() {
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  iptables-save > /etc/systemd/scripts/ip4save
  cat << EOF > docker-compose.yaml
version: "3"
services:
  bsp-client:
    container_name: bsp-client
    restart: unless-stopped
    image: harbor.lab.example.com/library/bsp-client:latest
    environment:
      - LIBRARY_BROWSE=true
      - LIBRARY_NAME=$(hostname)
      - SYNC_DELAY_MAX_SECONDS=21600
      - SYNC_DELAY=true
      - SYNC_MAX_KBPS=10m
      - SYNC_PEER=${peer}
      - SYNC_PORT=2222
      - SYNC_SCHEDULE=0 21 * * 5
      - TLS_CUSTOM_CERT=false
      - TLS_NAME=
      - TZ=$(timedatectl status | grep zone | awk '{print $3}')
    ports:
      - "80:80/tcp"
      - "443:443/tcp"
    volumes:
      - './data/ssh:/syncer/.ssh'
      - '/opt/bsp-library:/syncer/library'
      - './data/certs:/etc/caddycerts'
EOF
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -p|--peer)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        peer="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -t|--enable-tls)
      tls="y"
      shift
      ;;
    -\?|-h|--help)
      helpText
      shift
      ;;
    --*|-*)
      echo" Error: unsupported flag $1" >&2
      exit 1
      ;;
    *)
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

if [ -f data/certs/cert.pem ] && [ -f docker-compose.yaml ]; then
  enableTls
elif [ -z "${peer}" ]; then
  getInputs
fi

if [ "${tls,,}" == "y" ]; then
  tls="true"
else
  tls="false"
fi

if [ "${tls}" == "true" ] && [ ! -f data/certs/key.pem ]; then
  generateCsr
fi

doConfig

echo '>> Setup complete! Review docker-compose.yaml and use "docker-compose up -d" to start the client.'
