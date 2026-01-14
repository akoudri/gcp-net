# Scripts GCP Networking Training

Ce dossier contient les scripts bash exécutables extraits des labs de formation GCP Networking.

## Organisation

Les scripts sont organisés par module dans des sous-dossiers :

```
scripts/
├── module1/          # TCP/IP Fundamentals
├── module2/          # VPC Fundamentals (COMPLET - 35 scripts)
├── module3/          # Routing and Addressing
├── module4/          # VPC Sharing
├── module5/          # Private Connectivity
├── module6/          # Cloud DNS
├── module7/          # Hybrid Connectivity
├── module8/          # Network Security
├── module9/          # DDoS Protection and Cloud Armor
├── module10/         # Load Balancing
└── module11/         # Monitoring and Logging
```

## Convention de nommage

Les scripts suivent la convention : `labX.Y_exN_description-courte.sh`

### Format

- `labX.Y` : Numéro du lab (ex: lab2.1, lab2.2)
- `exN` : Numéro de l'exercice (ex: ex1, ex2, ex3)
- `description-courte` : Description succincte en kebab-case
- `.sh` : Extension bash

### Exemples

```bash
lab2.1_ex1_explore-default-vpc.sh
lab2.2_ex3_create-firewall-rules.sh
lab2.4_ex2_create-multi-nic-vm.sh
lab2.7_deploy-full-architecture.sh
```

### Cas spéciaux

- **Scripts de déploiement complets** : `labX.Y_deploy-full-architecture.sh`
- **Scripts de nettoyage** : `cleanup-moduleX.sh`
- **Scripts utilitaires** : Nom descriptif clair (ex: `check_overlaps.sh`)

## Utilisation

### Rendre un script exécutable

```bash
chmod +x scripts/module2/lab2.1_ex1_explore-default-vpc.sh
```

### Exécuter un script

```bash
# Depuis la racine du projet
./scripts/module2/lab2.1_ex1_explore-default-vpc.sh

# Ou depuis le dossier du module
cd scripts/module2
./lab2.1_ex1_explore-default-vpc.sh
```

### Exécuter une séquence de labs

```bash
# Lab 2.1 complet (tous les exercices)
cd scripts/module2
./lab2.1_ex1_explore-default-vpc.sh
./lab2.1_ex2_audit-firewall-rules.sh
./lab2.1_ex3_create-test-vm.sh
./lab2.1_ex4_cleanup-default-vpc.sh
```

## Scripts de nettoyage

Chaque module dispose d'un script de nettoyage pour supprimer toutes les ressources créées :

```bash
# Nettoyage interactif (avec confirmation)
./scripts/module2/cleanup-module2.sh

# Le script demande confirmation avant suppression
```

### Ordre de suppression des ressources

Les scripts de nettoyage respectent l'ordre de dépendances GCP :

1. Load Balancers (forwarding rules → proxies → url-maps → backend services)
2. VPN (tunnels → gateways)
3. VMs
4. Firewall rules
5. Routes
6. Cloud NAT et Cloud Routers
7. Subnets
8. VPCs

## Bonnes pratiques

### Avant d'exécuter un script

1. **Vérifier le projet GCP actif** :
   ```bash
   gcloud config get-value project
   ```

2. **Définir le projet si nécessaire** :
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Vérifier les permissions** :
   - roles/compute.networkAdmin
   - roles/compute.instanceAdmin
   - roles/dns.admin (pour les modules DNS)

### Pendant l'exécution

- Les scripts affichent leur progression avec des messages clairs
- Les variables d'environnement sont souvent définies au début
- Les erreurs causent l'arrêt immédiat du script (grâce à `set -e`)

### Après l'exécution

- Vérifier les ressources créées dans la Console GCP
- Lire les questions pédagogiques affichées en fin de script
- Tester manuellement les fonctionnalités déployées
- **Important** : Nettoyer les ressources avec le script `cleanup-moduleX.sh`

## Structure d'un script type

```bash
#!/bin/bash
# Lab X.Y - Exercice X.Y.Z : Titre de l'exercice
# Objectif : Description de l'objectif pédagogique

set -e

echo "=== Lab X.Y - Exercice Z : Titre ==="
echo ""

# Variables d'environnement
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="example-vpc"

# Commandes gcloud
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom

echo ""
echo "Questions à considérer :"
echo "1. Question pédagogique 1 ?"
echo "2. Question pédagogique 2 ?"
```

## Module 2 - VPC Fundamentals (Complet)

Le Module 2 contient 35 scripts couvrant tous les labs :

### Lab 2.1 - VPC Default (4 scripts)
- Exploration, audit, test, nettoyage du VPC par défaut

### Lab 2.2 - VPC Custom Multi-régions (7 scripts)
- Création VPC custom, sous-réseaux, pare-feu, Cloud NAT, VMs, tests

### Lab 2.3 - Planification IP (4 scripts)
- Plan d'adressage, plages secondaires GKE, extension de sous-réseaux

### Lab 2.4 - VMs Multi-NIC (6 scripts)
- Configuration d'appliances réseau avec plusieurs interfaces

### Lab 2.5 - Network Tiers (5 scripts)
- Comparaison Premium vs Standard Tier

### Lab 2.6 - Routage Dynamique (4 scripts)
- Modes de routage régional et global

### Lab 2.7 - Architecture Entreprise (1 script)
- Déploiement complet multi-tiers

### Lab 2.8 - Troubleshooting (2 scripts)
- Connectivity Tests et diagnostic

### Nettoyage (1 script)
- `cleanup-module2.sh` : Suppression de toutes les ressources

## Développement des autres modules

Les modules 3 à 11 suivront la même structure et convention de nommage.

Pour extraire et créer les scripts des autres modules :

```bash
# Méthode manuelle recommandée
# 1. Lire le fichier moduleX_labs.md
# 2. Identifier les blocs ```bash
# 3. Créer les scripts selon la convention
# 4. Rendre exécutables avec chmod +x
```

## Contribuer

### Ajouter un nouveau script

1. Respecter la convention de nommage
2. Inclure un header avec objectif pédagogique
3. Utiliser `set -e` pour arrêter en cas d'erreur
4. Ajouter des messages `echo` pour guider l'utilisateur
5. Inclure les questions pédagogiques en fin de script
6. Rendre le script exécutable : `chmod +x script.sh`

### Tester un script

```bash
# Test en mode dry-run (si supporté)
./script.sh --dry-run

# Test réel
./script.sh

# Nettoyage après test
./cleanup-moduleX.sh
```

## Ressources

- [Documentation gcloud](https://cloud.google.com/sdk/gcloud/reference)
- [Documentation GCP Networking](https://cloud.google.com/vpc/docs)
- [CLAUDE.md](../CLAUDE.md) : Instructions pour l'assistant IA

## Support

En cas de problème avec un script :

1. Vérifier les prérequis (projet, permissions, APIs activées)
2. Consulter les logs d'erreur gcloud
3. Vérifier la Console GCP pour l'état des ressources
4. Consulter la documentation dans les fichiers `moduleX_labs.md`
