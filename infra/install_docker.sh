#!/bin/bash
# Installation de Docker Engine sur Ubuntu 22.04 / 24.04
# A executer sur VM1 (Jenkins) ET VM2 (SonarQube)
# Usage : sudo bash install_docker.sh

set -e

echo ">>> Mise a jour des paquets..."
apt-get update -y

echo ">>> Installation des prerequis..."
apt-get install -y ca-certificates curl gnupg

echo ">>> Ajout de la cle GPG officielle Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo ">>> Ajout du depot Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

echo ">>> Installation de Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Ajout de l'utilisateur courant au groupe docker (pour eviter sudo a chaque commande)..."
usermod -aG docker "${SUDO_USER:-$USER}"

echo ">>> Verification de l'installation..."
docker --version
docker compose version

echo ">>> Termine. Deconnecte-toi / reconnecte-toi (ou redemarre la VM) pour que le groupe docker prenne effet."
