# POC — Pipeline CI/CD automatisé avec Jenkins

Mise en place d'un environnement de preuve de concept (POC) pour le déploiement
automatisé d'une application Java, via une pipeline CI/CD orchestrée par Jenkins.

## Objectif du projet

Démontrer une chaîne DevOps complète, de bout en bout :

1. Un développeur pousse du code sur **GitHub**
2. **Jenkins** détecte le changement (webhook), compile et teste l'application
3. **SonarQube** analyse la qualité du code et bloque le pipeline si le code ne
   respecte pas les critères définis (quality gate)
4. Si tout est vert, Jenkins construit une **image Docker** de l'application
5. L'image est poussée vers un registre (Docker Hub)
6. Le conteneur est déployé automatiquement

Ce projet illustre à la fois le volet **infrastructure** (virtualisation,
serveurs Linux, réseau) et le volet **développement** (code Java, tests,
containerisation) — d'où le terme **DevOps**.

## Architecture

```
 GitHub (repo app + repo pipeline)
        │  push / webhook
        ▼
 ┌─────────────────────────────┐        ┌──────────────────────────┐
 │   VM1 — Linux               │        │   VM2 — Linux             │
 │   Docker + Jenkins          │◄──────►│   Docker + SonarQube      │
 │                              │ analyse │   + PostgreSQL            │
 │  Build → Test → Docker      │  qualité│                            │
 │  build/push → Deploy        │        │                            │
 └─────────────────────────────┘        └──────────────────────────┘
```

- **VM1** : héberge Jenkins (orchestrateur) et Docker (build + exécution des
  conteneurs). C'est elle qui exécute concrètement toutes les étapes du
  pipeline.
- **VM2** : héberge SonarQube (analyse statique de code) et sa base
  PostgreSQL. Isolée pour ne pas consommer les ressources de Jenkins et pour
  se rapprocher d'une architecture réaliste (chaque service sur son propre
  serveur).

## Arborescence du dépôt

```
devops-cicd-poc/
├── app/                        Application Java (Spring Boot)
│   ├── pom.xml                 Build Maven + plugins Sonar/Jacoco
│   ├── src/                    Code source + tests JUnit
│   └── Dockerfile              Build multi-stage de l'image
├── jenkins/
│   └── Jenkinsfile             Pipeline déclaratif complet
├── infra/
│   ├── install_docker.sh       A lancer sur VM1 ET VM2
│   ├── vm1-jenkins/
│   │   └── install_jenkins.sh  Installation Jenkins (VM1)
│   └── vm2-sonarqube/
│       ├── docker-compose.yml  SonarQube + PostgreSQL
│       └── install_sonarqube.sh
└── README.md                   Ce fichier
```

> Sur GitHub, tu peux garder cette structure en mono-repo (plus simple pour
> la soutenance) ou l'éclater en 3 dépôts (`app`, `jenkins-pipeline`,
> `infra`) si tu veux illustrer une organisation plus proche d'une vraie
> équipe. Les deux approches sont valables pour un POC.

## Mise en place — étape par étape

### 1. Créer les deux VM (VMware Workstation)

- 2 VM sous Ubuntu Server 22.04 ou 24.04 LTS
- Config mini conseillée : 2 vCPU / 4 Go RAM pour VM1 (Jenkins), 2 vCPU / 4 Go
  RAM pour VM2 (SonarQube — attention, SonarQube est gourmand en RAM)
- Mode réseau **Bridged** (ou NAT avec redirection de ports) pour que les deux
  VM puissent se voir et que tu puisses y accéder depuis ton PC hôte
- Note les IP des deux VM (`ip a`), tu en auras besoin partout ensuite

### 2. Installer Docker sur les deux VM

```bash
sudo bash infra/install_docker.sh
```

### 3. Installer Jenkins sur VM1

```bash
sudo bash infra/vm1-jenkins/install_jenkins.sh
```

Puis ouvre `http://<IP_VM1>:8080`, termine l'assistant d'installation avec le
mot de passe affiché par le script, et installe les plugins suggérés **+**
ces plugins spécifiques :

- Docker Pipeline
- SonarQube Scanner for Jenkins
- Git (normalement déjà présent)

### 4. Lancer SonarQube sur VM2

```bash
cd infra/vm2-sonarqube
sudo bash install_sonarqube.sh
```

Ouvre `http://<IP_VM2>:9000`, connecte-toi (`admin` / `admin`), change le mot
de passe, puis :
- Crée un projet (clé : `demo-cicd-jenkins`, à faire correspondre avec le
  `pom.xml`)
- Génère un **token** utilisateur (My Account > Security) — tu en auras
  besoin dans Jenkins

### 5. Connecter Jenkins et SonarQube

Dans Jenkins (`Manage Jenkins`) :
- **Credentials** : ajoute le token SonarQube en "Secret text", ID
  `sonar-token`
- **System** : dans la section SonarQube servers, ajoute un serveur nommé
  `SonarQubeServer` avec l'URL `http://<IP_VM2>:9000` et le token créé
- **Tools** : configure un outil Maven nommé `Maven3` (installation
  automatique ou binaire local)
- Ajoute aussi tes identifiants Docker Hub en credentials (Username/Password),
  ID `dockerhub-credentials`

### 6. Créer le job Jenkins

- Nouveau item > **Pipeline** (ou **Multibranch Pipeline** si tu veux profiter
  du webhook automatique)
- Source SCM : ton repo GitHub, chemin vers le `Jenkinsfile`
- Configure le **webhook GitHub** (`Settings > Webhooks` sur le repo) pointant
  vers `http://<IP_VM1>:8080/github-webhook/`

### 7. Adapter le pipeline à ton contexte

Dans `jenkins/Jenkinsfile`, remplace :
- `TON_USER_DOCKERHUB` par ton identifiant Docker Hub
- Vérifie que `sonar.host.url` dans `app/pom.xml` pointe bien vers l'IP de ta
  VM2

### 8. Démonstration

1. Modifie le code de `app/` (par exemple le message de `/api/hello`)
2. `git push`
3. Regarde le pipeline Jenkins se déclencher automatiquement, exécuter tous
   les stages, et le dashboard SonarQube se mettre à jour
4. Vérifie que le conteneur tourne : `curl http://<IP_VM1>:8080/api/hello`

## Pour la soutenance

Points forts à mettre en avant :
- **Bout en bout** : un commit déclenche tout, sans intervention manuelle
- **Qualité intégrée** : le pipeline peut bloquer un déploiement si le code
  est de mauvaise qualité (quality gate SonarQube)
- **Infra réaliste à 2 VM** : sépare les responsabilités (CI/CD vs qualité),
  comme dans une vraie organisation
- **Portabilité** : grâce à Docker, l'application tourne identiquement partout

Idées de démo live : casser volontairement un test unitaire ou introduire une
faille de sécurité simple (ex. mot de passe en clair) pour montrer que le
pipeline s'arrête bien à l'étape Quality Gate.
