# Ansible — Automatisation de la configuration des VM

Ce dossier remplace l'exécution manuelle des scripts `infra/install_docker.sh`,
`infra/vm1-jenkins/install_jenkins.sh` et `infra/vm2-sonarqube/install_sonarqube.sh`
par des **playbooks Ansible idempotents** : on peut les relancer autant de fois
que nécessaire sans casser quoi que ce soit, contrairement à des scripts bash
classiques.

## Pré-requis

Sur ta machine de contrôle (ton PC, ou une VM dédiée) :
```bash
pip install ansible --break-system-packages
ansible-galaxy collection install community.docker ansible.posix
```

Sur les VM cibles : un accès SSH par clé fonctionnel (pas de mot de passe à
chaque connexion), et un utilisateur avec les droits `sudo`.

## Structure

```
ansible/
├── ansible.cfg          Configuration (chemin de l'inventaire, options SSH)
├── inventory.ini         Liste des VM cibles et leur groupe
├── site.yml              Playbook principal, orchestre tout
└── roles/
    ├── docker/            Installation Docker (VM1 + VM2)
    ├── jenkins/            Installation Jenkins (VM1 uniquement)
    │   └── handlers/       Redémarrage du service si nécessaire
    └── sonarqube/          Installation SonarQube + PostgreSQL (VM2)
        └── files/          docker-compose.yml copié sur la VM
```

## Utilisation

Adapte d'abord `inventory.ini` avec les vraies IP et le bon utilisateur SSH.

Tout installer d'un coup :
```bash
cd ansible/
ansible-playbook site.yml
```

Cibler une seule VM ou un seul rôle si besoin (utile en phase de test) :
```bash
ansible-playbook site.yml --limit vm1_jenkins
ansible-playbook site.yml --tags docker
```

Vérifier ce qui *serait* fait sans rien appliquer réellement (mode simulation) :
```bash
ansible-playbook site.yml --check
```

## Incidents corrigés directement dans les rôles

Deux rôles intègrent des corrections issues d'incidents réels rencontrés
pendant la construction manuelle du projet, pour ne pas les reproduire :

- **`roles/jenkins`** : utilise la clé GPG `jenkins.io-2026.key` (rotation de
  clé de décembre 2025 — l'ancienne `jenkins.io-2023.key`, encore présente
  dans la plupart des tutoriels en ligne, provoque une erreur `NO_PUBKEY`).
- **`roles/jenkins`** : ajoute explicitement l'utilisateur système `jenkins`
  au groupe `docker`, pour éviter l'erreur `permission denied` lors du build
  d'image dans le pipeline.
