#!/bin/bash
# Installation de Jenkins LTS sur Ubuntu (VM1)
# Pre-requis : avoir lance ../install_docker.sh avant (Jenkins doit pouvoir piloter Docker)
# Usage : sudo bash install_jenkins.sh

set -e

echo ">>> Installation d'OpenJDK 21 (requis par les versions recentes de Jenkins LTS)..."
apt-get update -y
apt-get install -y fontconfig openjdk-21-jre

echo ">>> Ajout de la cle GPG et du depot Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y

echo ">>> Installation de Jenkins..."
apt-get install -y jenkins

echo ">>> Autoriser l'utilisateur jenkins a utiliser Docker..."
usermod -aG docker jenkins

echo ">>> Redemarrage de Jenkins pour appliquer le nouveau groupe..."
systemctl restart jenkins
systemctl enable jenkins

echo ">>> Installation terminee."
echo ">>> Jenkins est accessible sur http://<IP_DE_LA_VM1>:8080"
echo ">>> Mot de passe administrateur initial :"
sleep 5
cat /var/lib/jenkins/secrets/initialAdminPassword || echo "(pas encore genere, attends quelques secondes et relance : sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
