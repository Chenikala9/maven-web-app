#!/bin/bash

set -euo pipefail

#############################################
# Nexus Repository Manager Installation
# OS : Amazon Linux 2023
# Java : Corretto 21
# Nexus : 3.94.0-12
#############################################

NEXUS_VERSION="3.94.0-12"
NEXUS_FILE="nexus-${NEXUS_VERSION}-linux-x86_64.tar.gz"
NEXUS_URL="https://download.sonatype.com/nexus/3/${NEXUS_FILE}"

echo "========================================="
echo " Nexus Repository Installation Started"
echo "========================================="

echo "Updating packages..."
sudo dnf update -y

echo "Installing Java and utilities..."
sudo dnf install -y java-21-amazon-corretto wget tar

echo
echo "Java Version:"
java -version

echo
echo "Creating nexus user..."
if ! id nexus &>/dev/null; then
    sudo useradd -r -M -d /opt/nexus -s /bin/bash nexus
fi

cd /opt

echo
echo "Cleaning previous installation..."
sudo systemctl stop nexus 2>/dev/null || true
sudo systemctl disable nexus 2>/dev/null || true

sudo rm -rf /opt/nexus
sudo rm -rf /opt/nexus-*
sudo rm -rf /opt/sonatype-work
sudo rm -f nexus.tar.gz

echo
echo "Downloading Nexus ${NEXUS_VERSION}..."

sudo wget -O nexus.tar.gz "${NEXUS_URL}"

echo
echo "Extracting Nexus..."

sudo tar -xzf nexus.tar.gz

NEXUS_DIR=$(find /opt -maxdepth 1 -type d -name "nexus-*" | head -1)

if [ -z "${NEXUS_DIR}" ]; then
    echo "ERROR: Nexus directory not found."
    exit 1
fi

echo "Detected: ${NEXUS_DIR}"

sudo mv "${NEXUS_DIR}" /opt/nexus

sudo mkdir -p /opt/sonatype-work

sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc >/dev/null

echo
echo "Creating systemd service..."

sudo tee /etc/systemd/system/nexus.service >/dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536

User=nexus
Group=nexus

ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop

Restart=on-failure
RestartSec=10
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo
echo "Waiting for Nexus initialization..."

COUNT=0

while [ ! -f /opt/sonatype-work/nexus3/admin.password ]
do
    sleep 5
    COUNT=$((COUNT+5))

    if [ $COUNT -ge 600 ]; then
        echo "ERROR: Nexus initialization timed out."
        sudo journalctl -u nexus --no-pager | tail -30
        exit 1
    fi
done

echo
echo "========================================="
echo " Nexus Installed Successfully"
echo "========================================="

echo
echo "Service Status:"
sudo systemctl --no-pager --full status nexus

echo
echo "Listening Port:"
sudo ss -lntp | grep 8081

echo
echo "Admin Username : admin"

echo
echo "Admin Password:"
sudo cat /opt/sonatype-work/nexus3/admin.password

echo
echo "Open Browser:"
echo "http://<EC2-PUBLIC-IP>:8081"

echo
echo "========================================="
echo " Installation Completed Successfully"
echo "========================================="
