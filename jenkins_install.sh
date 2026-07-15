#!/bin/bash

set -e

echo "=============================="
echo "Updating Amazon Linux 2023"
echo "=============================="
sudo dnf update -y

echo "=============================="
echo "Installing Java 21"
echo "=============================="
sudo dnf install -y java-21-amazon-corretto-devel wget git

echo "=============================="
echo "Verifying Java"
echo "=============================="
java -version

echo "=============================="
echo "Adding Jenkins Repository"
echo "=============================="
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "=============================="
echo "Installing Jenkins"
echo "=============================="
sudo dnf install -y fontconfig jenkins

echo "=============================="
echo "Starting Jenkins"
echo "=============================="
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=============================="
echo "Opening Port 8080"
echo "=============================="
sudo firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || true

echo "=============================="
echo "Jenkins Status"
echo "=============================="
sudo systemctl status jenkins --no-pager

echo "=============================="
echo "Initial Admin Password"
echo "=============================="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "=============================="
echo "Versions"
echo "=============================="
java -version
jenkins --version
