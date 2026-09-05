#!/bin/bash
# Prepare le systeme et lance SonarQube + PostgreSQL via Docker Compose (VM2)
# Pre-requis : avoir lance ../install_docker.sh avant
# Usage : sudo bash install_sonarqube.sh

set -e

echo ">>> Application des reglages systeme requis par Elasticsearch (utilise en interne par SonarQube)..."
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072

# Rendre les reglages persistants apres redemarrage
grep -q "vm.max_map_count" /etc/sysctl.conf || echo "vm.max_map_count=524288" >> /etc/sysctl.conf
grep -q "fs.file-max"      /etc/sysctl.conf || echo "fs.file-max=131072"      >> /etc/sysctl.conf

echo ">>> Lancement de SonarQube et PostgreSQL avec Docker Compose..."
cd "$(dirname "$0")"
docker compose up -d

echo ">>> Termine. SonarQube demarre (cela peut prendre 1 a 2 minutes)."
echo ">>> Accessible sur http://<IP_DE_LA_VM2>:9000"
echo ">>> Identifiants par defaut : admin / admin (a changer au premier login)"
