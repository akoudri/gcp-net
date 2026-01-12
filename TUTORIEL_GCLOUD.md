# 🛠️ Tutoriel : La commande gcloud
## Guide de référence pour GCP Networking

---

## 📋 Table des matières

1. [Introduction à gcloud](#1-introduction-à-gcloud)
2. [Installation et configuration](#2-installation-et-configuration)
3. [Structure des commandes](#3-structure-des-commandes)
4. [Configuration et authentification](#4-configuration-et-authentification)
5. [Compute Engine (VMs)](#5-compute-engine-vms)
6. [VPC et réseaux](#6-vpc-et-réseaux)
7. [Sous-réseaux](#7-sous-réseaux)
8. [Règles de pare-feu](#8-règles-de-pare-feu)
9. [Routes](#9-routes)
10. [Cloud Router et Cloud NAT](#10-cloud-router-et-cloud-nat)
11. [VPN](#11-vpn)
12. [Load Balancing](#12-load-balancing)
13. [Cloud DNS](#13-cloud-dns)
14. [Cloud Armor](#14-cloud-armor)
15. [Monitoring et Logging](#15-monitoring-et-logging)
16. [Network Intelligence Center](#16-network-intelligence-center)
17. [IAM et projets](#17-iam-et-projets)
18. [Astuces et bonnes pratiques](#18-astuces-et-bonnes-pratiques)

---

## 1. Introduction à gcloud

### Qu'est-ce que gcloud ?

**gcloud** est l'outil en ligne de commande officiel de Google Cloud Platform. Il permet de gérer toutes les ressources GCP depuis un terminal.

### Avantages

| Avantage | Description |
|----------|-------------|
| **Automatisation** | Scripts reproductibles |
| **Rapidité** | Plus rapide que la console pour les tâches répétitives |
| **Précision** | Contrôle exact des paramètres |
| **Documentation** | Aide intégrée (`--help`) |
| **Certifications** | Utilisé dans les examens GCP |

### Où utiliser gcloud ?

- **Cloud Shell** : Terminal intégré à la console GCP (aucune installation)
- **Terminal local** : Après installation du SDK
- **Scripts CI/CD** : Pipelines d'automatisation

---

## 2. Installation et configuration

### Installation

#### Linux (Debian/Ubuntu)
```bash
# Ajouter le dépôt Google Cloud
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Installer
sudo apt-get update && sudo apt-get install google-cloud-cli
```

#### macOS
```bash
brew install google-cloud-sdk
```

#### Windows
Télécharger l'installeur : https://cloud.google.com/sdk/docs/install

### Vérifier l'installation
```bash
gcloud version
```

---

## 3. Structure des commandes

### Syntaxe générale

```
gcloud [GROUPE] [SOUS-GROUPE] [COMMANDE] [ARGUMENTS] [FLAGS]
```

### Exemples

```bash
# Structure détaillée
gcloud compute instances create ma-vm --zone=europe-west1-b --machine-type=e2-micro
#      ├─────┘ ├───────┘ ├────┘ ├───┘ ├────────────────────┘ ├──────────────────┘
#      │       │         │      │     │                      │
#      │       │         │      │     │                      └── Flag optionnel
#      │       │         │      │     └── Flag obligatoire (zone)
#      │       │         │      └── Argument (nom de la VM)
#      │       │         └── Commande (create)
#      │       └── Sous-groupe (instances)
#      └── Groupe (compute)
```

### Groupes principaux pour le networking

| Groupe | Description |
|--------|-------------|
| `gcloud compute` | VMs, réseaux, pare-feu, load balancers |
| `gcloud dns` | Cloud DNS |
| `gcloud network-management` | Network Intelligence Center |
| `gcloud logging` | Cloud Logging |
| `gcloud monitoring` | Cloud Monitoring |

### Obtenir de l'aide

```bash
# Aide générale
gcloud help

# Aide sur un groupe
gcloud compute --help

# Aide sur une commande spécifique
gcloud compute instances create --help

# Rechercher une commande
gcloud help -- search "firewall"
```

---

## 4. Configuration et authentification

### Authentification

```bash
# Connexion interactive (navigateur)
gcloud auth login

# Connexion avec un compte de service
gcloud auth activate-service-account --key-file=credentials.json

# Voir le compte actif
gcloud auth list

# Révoquer l'accès
gcloud auth revoke
```

### Configuration du projet

```bash
# Définir le projet par défaut
gcloud config set project MON_PROJET

# Voir le projet actuel
gcloud config get-value project

# Lister les projets accessibles
gcloud projects list
```

### Configuration par défaut

```bash
# Définir la région par défaut
gcloud config set compute/region europe-west1

# Définir la zone par défaut
gcloud config set compute/zone europe-west1-b

# Voir toute la configuration
gcloud config list

# Voir une valeur spécifique
gcloud config get-value compute/zone
```

### Profils de configuration

```bash
# Créer un nouveau profil
gcloud config configurations create mon-profil

# Lister les profils
gcloud config configurations list

# Activer un profil
gcloud config configurations activate mon-profil

# Supprimer un profil
gcloud config configurations delete mon-profil
```

---

## 5. Compute Engine (VMs)

### Créer une VM

```bash
# VM basique
gcloud compute instances create ma-vm \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud

# VM avec options avancées
gcloud compute instances create ma-vm \
    --zone=europe-west1-b \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --network=mon-vpc \
    --subnet=mon-subnet \
    --private-network-ip=10.0.1.10 \
    --no-address \
    --tags=web-server,allow-ssh \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y nginx'
```

### Gérer les VMs

```bash
# Lister les VMs
gcloud compute instances list

# Lister avec filtres
gcloud compute instances list --filter="zone:europe-west1-b"
gcloud compute instances list --filter="status=RUNNING"
gcloud compute instances list --filter="name~^web-"

# Détails d'une VM
gcloud compute instances describe ma-vm --zone=europe-west1-b

# Démarrer/Arrêter
gcloud compute instances start ma-vm --zone=europe-west1-b
gcloud compute instances stop ma-vm --zone=europe-west1-b

# Supprimer
gcloud compute instances delete ma-vm --zone=europe-west1-b

# Supprimer sans confirmation
gcloud compute instances delete ma-vm --zone=europe-west1-b --quiet
```

### Connexion SSH

```bash
# SSH direct
gcloud compute ssh ma-vm --zone=europe-west1-b

# SSH via IAP (sans IP publique)
gcloud compute ssh ma-vm --zone=europe-west1-b --tunnel-through-iap

# Exécuter une commande
gcloud compute ssh ma-vm --zone=europe-west1-b --command="hostname"

# Copier des fichiers
gcloud compute scp fichier.txt ma-vm:~/fichier.txt --zone=europe-west1-b
gcloud compute scp ma-vm:~/resultat.txt ./resultat.txt --zone=europe-west1-b
```

### Instance Templates et Groups

```bash
# Créer un template
gcloud compute instance-templates create mon-template \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=web-server

# Créer un Managed Instance Group
gcloud compute instance-groups managed create mon-mig \
    --zone=europe-west1-b \
    --template=mon-template \
    --size=3

# Redimensionner
gcloud compute instance-groups managed resize mon-mig \
    --zone=europe-west1-b \
    --size=5

# Configurer l'autoscaling
gcloud compute instance-groups managed set-autoscaling mon-mig \
    --zone=europe-west1-b \
    --min-num-replicas=2 \
    --max-num-replicas=10 \
    --target-cpu-utilization=0.7
```

---

## 6. VPC et réseaux

### Créer un VPC

```bash
# VPC en mode custom (recommandé)
gcloud compute networks create mon-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# VPC en mode auto
gcloud compute networks create mon-vpc-auto \
    --subnet-mode=auto

# VPC avec routage global
gcloud compute networks create mon-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=global
```

### Gérer les VPCs

```bash
# Lister les VPCs
gcloud compute networks list

# Détails d'un VPC
gcloud compute networks describe mon-vpc

# Modifier le mode de routage
gcloud compute networks update mon-vpc \
    --bgp-routing-mode=global

# Supprimer un VPC
gcloud compute networks delete mon-vpc
```

### VPC Peering

```bash
# Créer un peering (à faire des deux côtés)
gcloud compute networks peerings create peering-vpc1-vers-vpc2 \
    --network=vpc1 \
    --peer-network=vpc2 \
    --peer-project=autre-projet

# Lister les peerings
gcloud compute networks peerings list --network=mon-vpc

# Supprimer un peering
gcloud compute networks peerings delete peering-vpc1-vers-vpc2 \
    --network=vpc1
```

---

## 7. Sous-réseaux

### Créer un sous-réseau

```bash
# Sous-réseau basique
gcloud compute networks subnets create mon-subnet \
    --network=mon-vpc \
    --region=europe-west1 \
    --range=10.0.1.0/24

# Sous-réseau avec options avancées
gcloud compute networks subnets create mon-subnet \
    --network=mon-vpc \
    --region=europe-west1 \
    --range=10.0.1.0/24 \
    --secondary-range=pods=10.1.0.0/16,services=10.2.0.0/20 \
    --enable-private-ip-google-access \
    --enable-flow-logs \
    --logging-flow-sampling=0.5 \
    --logging-aggregation-interval=INTERVAL_5_SEC \
    --logging-metadata=INCLUDE_ALL_METADATA
```

### Gérer les sous-réseaux

```bash
# Lister les sous-réseaux
gcloud compute networks subnets list

# Lister par réseau
gcloud compute networks subnets list --filter="network:mon-vpc"

# Détails d'un sous-réseau
gcloud compute networks subnets describe mon-subnet --region=europe-west1

# Étendre la plage (uniquement agrandir, jamais réduire)
gcloud compute networks subnets expand-ip-range mon-subnet \
    --region=europe-west1 \
    --prefix-length=20

# Activer Private Google Access
gcloud compute networks subnets update mon-subnet \
    --region=europe-west1 \
    --enable-private-ip-google-access

# Activer/modifier les Flow Logs
gcloud compute networks subnets update mon-subnet \
    --region=europe-west1 \
    --enable-flow-logs \
    --logging-flow-sampling=0.5

# Supprimer
gcloud compute networks subnets delete mon-subnet --region=europe-west1
```

---

## 8. Règles de pare-feu

### Créer des règles

```bash
# Règle ALLOW entrante (INGRESS)
gcloud compute firewall-rules create allow-ssh \
    --network=mon-vpc \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=allow-ssh \
    --priority=1000

# Règle ALLOW pour HTTP/HTTPS
gcloud compute firewall-rules create allow-web \
    --network=mon-vpc \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# Règle ALLOW interne
gcloud compute firewall-rules create allow-internal \
    --network=mon-vpc \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:0-65535,udp:0-65535,icmp \
    --source-ranges=10.0.0.0/8

# Règle DENY
gcloud compute firewall-rules create deny-all-ingress \
    --network=mon-vpc \
    --direction=INGRESS \
    --action=DENY \
    --rules=all \
    --source-ranges=0.0.0.0/0 \
    --priority=65534

# Règle EGRESS
gcloud compute firewall-rules create deny-egress-internet \
    --network=mon-vpc \
    --direction=EGRESS \
    --action=DENY \
    --rules=all \
    --destination-ranges=0.0.0.0/0 \
    --priority=1000

# Règle avec Service Account
gcloud compute firewall-rules create allow-from-sa \
    --network=mon-vpc \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=mon-sa@projet.iam.gserviceaccount.com
```

### Gérer les règles

```bash
# Lister les règles
gcloud compute firewall-rules list

# Lister par réseau
gcloud compute firewall-rules list --filter="network:mon-vpc"

# Détails d'une règle
gcloud compute firewall-rules describe allow-ssh

# Modifier une règle
gcloud compute firewall-rules update allow-ssh \
    --source-ranges=10.0.0.0/8

# Activer le logging
gcloud compute firewall-rules update allow-ssh \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA

# Désactiver une règle
gcloud compute firewall-rules update allow-ssh --disabled

# Réactiver
gcloud compute firewall-rules update allow-ssh --no-disabled

# Supprimer
gcloud compute firewall-rules delete allow-ssh
```

---

## 9. Routes

### Créer des routes

```bash
# Route statique vers une VM (next-hop instance)
gcloud compute routes create route-vers-appliance \
    --network=mon-vpc \
    --destination-range=192.168.0.0/16 \
    --next-hop-instance=appliance-vm \
    --next-hop-instance-zone=europe-west1-b \
    --priority=1000

# Route vers une IP (next-hop address)
gcloud compute routes create route-vers-ip \
    --network=mon-vpc \
    --destination-range=192.168.0.0/16 \
    --next-hop-address=10.0.1.10 \
    --priority=1000

# Route vers Internet Gateway
gcloud compute routes create route-internet \
    --network=mon-vpc \
    --destination-range=0.0.0.0/0 \
    --next-hop-gateway=default-internet-gateway \
    --priority=1000

# Route vers un VPN tunnel
gcloud compute routes create route-vers-onprem \
    --network=mon-vpc \
    --destination-range=172.16.0.0/12 \
    --next-hop-vpn-tunnel=mon-tunnel \
    --next-hop-vpn-tunnel-region=europe-west1 \
    --priority=1000

# Route avec tags (appliquée uniquement aux VMs avec ces tags)
gcloud compute routes create route-specifique \
    --network=mon-vpc \
    --destination-range=10.10.0.0/16 \
    --next-hop-address=10.0.1.10 \
    --tags=route-speciale
```

### Gérer les routes

```bash
# Lister les routes
gcloud compute routes list

# Lister par réseau
gcloud compute routes list --filter="network:mon-vpc"

# Détails d'une route
gcloud compute routes describe route-vers-appliance

# Supprimer une route
gcloud compute routes delete route-vers-appliance
```

---

## 10. Cloud Router et Cloud NAT

### Cloud Router

```bash
# Créer un Cloud Router
gcloud compute routers create mon-router \
    --network=mon-vpc \
    --region=europe-west1 \
    --asn=65001

# Lister les routers
gcloud compute routers list

# Détails d'un router
gcloud compute routers describe mon-router --region=europe-west1

# Voir le status BGP
gcloud compute routers get-status mon-router --region=europe-west1

# Ajouter une interface
gcloud compute routers add-interface mon-router \
    --region=europe-west1 \
    --interface-name=interface-0 \
    --vpn-tunnel=mon-tunnel

# Ajouter un peer BGP
gcloud compute routers add-bgp-peer mon-router \
    --region=europe-west1 \
    --peer-name=peer-onprem \
    --interface=interface-0 \
    --peer-asn=65002 \
    --peer-ip-address=169.254.0.2

# Supprimer
gcloud compute routers delete mon-router --region=europe-west1
```

### Cloud NAT

```bash
# Créer Cloud NAT (IPs automatiques)
gcloud compute routers nats create mon-nat \
    --router=mon-router \
    --region=europe-west1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Cloud NAT avec IPs manuelles
gcloud compute addresses create nat-ip-1 --region=europe-west1
gcloud compute routers nats create mon-nat \
    --router=mon-router \
    --region=europe-west1 \
    --nat-all-subnet-ip-ranges \
    --nat-external-ip-pool=nat-ip-1

# Cloud NAT pour des sous-réseaux spécifiques
gcloud compute routers nats create mon-nat \
    --router=mon-router \
    --region=europe-west1 \
    --nat-custom-subnet-ip-ranges=mon-subnet \
    --auto-allocate-nat-external-ips

# Activer le logging
gcloud compute routers nats update mon-nat \
    --router=mon-router \
    --region=europe-west1 \
    --enable-logging \
    --log-filter=ALL

# Lister les NAT
gcloud compute routers nats list --router=mon-router --region=europe-west1

# Détails
gcloud compute routers nats describe mon-nat \
    --router=mon-router \
    --region=europe-west1

# Supprimer
gcloud compute routers nats delete mon-nat \
    --router=mon-router \
    --region=europe-west1
```

---

## 11. VPN

### VPN HA (High Availability)

```bash
# Créer un VPN Gateway HA
gcloud compute vpn-gateways create mon-vpn-gw \
    --network=mon-vpc \
    --region=europe-west1

# Créer un External VPN Gateway (peer on-premises)
gcloud compute external-vpn-gateways create peer-onprem \
    --interfaces=0=203.0.113.1,1=203.0.113.2

# Créer les tunnels VPN
gcloud compute vpn-tunnels create tunnel-0 \
    --vpn-gateway=mon-vpn-gw \
    --vpn-gateway-region=europe-west1 \
    --peer-external-gateway=peer-onprem \
    --peer-external-gateway-interface=0 \
    --ike-version=2 \
    --shared-secret=MonSecretPartage123 \
    --router=mon-router \
    --interface=0

gcloud compute vpn-tunnels create tunnel-1 \
    --vpn-gateway=mon-vpn-gw \
    --vpn-gateway-region=europe-west1 \
    --peer-external-gateway=peer-onprem \
    --peer-external-gateway-interface=1 \
    --ike-version=2 \
    --shared-secret=MonSecretPartage123 \
    --router=mon-router \
    --interface=1

# Configurer BGP sur le router
gcloud compute routers add-interface mon-router \
    --region=europe-west1 \
    --interface-name=if-tunnel-0 \
    --vpn-tunnel=tunnel-0 \
    --ip-address=169.254.0.1 \
    --mask-length=30

gcloud compute routers add-bgp-peer mon-router \
    --region=europe-west1 \
    --peer-name=bgp-peer-0 \
    --interface=if-tunnel-0 \
    --peer-asn=65002 \
    --peer-ip-address=169.254.0.2
```

### Gérer les VPN

```bash
# Lister les VPN gateways
gcloud compute vpn-gateways list

# Lister les tunnels
gcloud compute vpn-tunnels list

# Détails d'un tunnel
gcloud compute vpn-tunnels describe tunnel-0 --region=europe-west1

# Supprimer (dans l'ordre : tunnels, gateways)
gcloud compute vpn-tunnels delete tunnel-0 --region=europe-west1
gcloud compute vpn-gateways delete mon-vpn-gw --region=europe-west1
```

---

## 12. Load Balancing

### Health Checks

```bash
# Health check HTTP
gcloud compute health-checks create http hc-http \
    --port=80 \
    --request-path=/health \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

# Health check HTTPS
gcloud compute health-checks create https hc-https \
    --port=443 \
    --request-path=/health

# Health check TCP
gcloud compute health-checks create tcp hc-tcp \
    --port=8080

# Lister
gcloud compute health-checks list

# Supprimer
gcloud compute health-checks delete hc-http
```

### Backend Services

```bash
# Backend service global (pour HTTP/HTTPS LB)
gcloud compute backend-services create mon-backend \
    --global \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-http \
    --load-balancing-scheme=EXTERNAL

# Ajouter un backend (instance group)
gcloud compute backend-services add-backend mon-backend \
    --global \
    --instance-group=mon-mig \
    --instance-group-zone=europe-west1-b \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8

# Backend service régional (pour Internal LB)
gcloud compute backend-services create mon-backend-internal \
    --region=europe-west1 \
    --protocol=TCP \
    --health-checks=hc-tcp \
    --health-checks-region=europe-west1 \
    --load-balancing-scheme=INTERNAL
```

### URL Maps

```bash
# URL Map simple
gcloud compute url-maps create mon-url-map \
    --default-service=mon-backend

# URL Map avec règles de routage
gcloud compute url-maps create mon-url-map \
    --default-service=backend-default

gcloud compute url-maps add-path-matcher mon-url-map \
    --path-matcher-name=chemin-api \
    --default-service=backend-api \
    --path-rules="/api/*=backend-api,/images/*=backend-images"

gcloud compute url-maps add-host-rule mon-url-map \
    --hosts=api.example.com \
    --path-matcher-name=chemin-api
```

### Target Proxies et Forwarding Rules

```bash
# HTTP Load Balancer
gcloud compute target-http-proxies create http-proxy \
    --url-map=mon-url-map

gcloud compute forwarding-rules create http-forwarding-rule \
    --global \
    --target-http-proxy=http-proxy \
    --ports=80

# HTTPS Load Balancer
gcloud compute ssl-certificates create mon-cert \
    --certificate=cert.pem \
    --private-key=key.pem

gcloud compute target-https-proxies create https-proxy \
    --url-map=mon-url-map \
    --ssl-certificates=mon-cert

gcloud compute forwarding-rules create https-forwarding-rule \
    --global \
    --target-https-proxy=https-proxy \
    --ports=443

# Internal TCP Load Balancer
gcloud compute forwarding-rules create internal-lb \
    --region=europe-west1 \
    --load-balancing-scheme=INTERNAL \
    --network=mon-vpc \
    --subnet=mon-subnet \
    --backend-service=mon-backend-internal \
    --ports=80
```

### Network Load Balancer (TCP/UDP)

```bash
# Target pool
gcloud compute target-pools create mon-pool \
    --region=europe-west1 \
    --health-check=hc-tcp

# Ajouter des instances
gcloud compute target-pools add-instances mon-pool \
    --instances=vm-1,vm-2 \
    --instances-zone=europe-west1-b \
    --region=europe-west1

# Forwarding rule
gcloud compute forwarding-rules create network-lb \
    --region=europe-west1 \
    --ports=80 \
    --target-pool=mon-pool
```

---

## 13. Cloud DNS

### Zones DNS

```bash
# Zone publique
gcloud dns managed-zones create ma-zone \
    --dns-name=example.com. \
    --description="Zone publique example.com" \
    --visibility=public

# Zone privée
gcloud dns managed-zones create ma-zone-privee \
    --dns-name=internal.example.com. \
    --description="Zone privée interne" \
    --visibility=private \
    --networks=mon-vpc

# Zone de forwarding
gcloud dns managed-zones create zone-forward \
    --dns-name=onprem.local. \
    --description="Forward vers on-premises" \
    --visibility=private \
    --networks=mon-vpc \
    --forwarding-targets=192.168.1.53,192.168.1.54

# Zone de peering
gcloud dns managed-zones create zone-peering \
    --dns-name=autre-vpc.local. \
    --description="Peering DNS vers autre VPC" \
    --visibility=private \
    --networks=mon-vpc \
    --target-network=autre-vpc \
    --target-project=autre-projet

# Lister les zones
gcloud dns managed-zones list

# Supprimer une zone
gcloud dns managed-zones delete ma-zone
```

### Enregistrements DNS

```bash
# Démarrer une transaction
gcloud dns record-sets transaction start --zone=ma-zone

# Ajouter un enregistrement A
gcloud dns record-sets transaction add \
    --zone=ma-zone \
    --name=www.example.com. \
    --type=A \
    --ttl=300 \
    "203.0.113.10"

# Ajouter un enregistrement CNAME
gcloud dns record-sets transaction add \
    --zone=ma-zone \
    --name=app.example.com. \
    --type=CNAME \
    --ttl=300 \
    "www.example.com."

# Ajouter un enregistrement MX
gcloud dns record-sets transaction add \
    --zone=ma-zone \
    --name=example.com. \
    --type=MX \
    --ttl=300 \
    "10 mail.example.com."

# Exécuter la transaction
gcloud dns record-sets transaction execute --zone=ma-zone

# Annuler une transaction
gcloud dns record-sets transaction abort --zone=ma-zone

# Lister les enregistrements
gcloud dns record-sets list --zone=ma-zone

# Supprimer un enregistrement
gcloud dns record-sets transaction start --zone=ma-zone
gcloud dns record-sets transaction remove \
    --zone=ma-zone \
    --name=www.example.com. \
    --type=A \
    --ttl=300 \
    "203.0.113.10"
gcloud dns record-sets transaction execute --zone=ma-zone
```

### Politiques DNS

```bash
# Créer une politique (activer le logging)
gcloud dns policies create ma-politique \
    --networks=mon-vpc \
    --enable-logging

# Politique avec serveurs alternatifs
gcloud dns policies create politique-alt-dns \
    --networks=mon-vpc \
    --alternative-name-servers=8.8.8.8,8.8.4.4

# Activer l'Inbound Forwarding
gcloud dns policies create politique-inbound \
    --networks=mon-vpc \
    --enable-inbound-forwarding
```

---

## 14. Cloud Armor

### Security Policies

```bash
# Créer une politique
gcloud compute security-policies create ma-politique

# Ajouter une règle - bloquer une IP
gcloud compute security-policies rules create 1000 \
    --security-policy=ma-politique \
    --action=deny-403 \
    --src-ip-ranges=192.0.2.0/24 \
    --description="Bloquer IP malveillante"

# Ajouter une règle - rate limiting
gcloud compute security-policies rules create 2000 \
    --security-policy=ma-politique \
    --action=rate-based-ban \
    --rate-limit-threshold-count=100 \
    --rate-limit-threshold-interval-sec=60 \
    --ban-duration-sec=600 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --src-ip-ranges="*"

# Ajouter une règle - bloquer par géolocalisation
gcloud compute security-policies rules create 3000 \
    --security-policy=ma-politique \
    --action=deny-403 \
    --expression="origin.region_code == 'CN'" \
    --description="Bloquer trafic depuis la Chine"

# Ajouter une règle - protection XSS/SQLi
gcloud compute security-policies rules create 4000 \
    --security-policy=ma-politique \
    --action=deny-403 \
    --expression="evaluatePreconfiguredExpr('xss-stable')" \
    --description="Protection XSS"

# Règle par défaut (dernière)
gcloud compute security-policies rules update 2147483647 \
    --security-policy=ma-politique \
    --action=allow

# Appliquer à un backend service
gcloud compute backend-services update mon-backend \
    --global \
    --security-policy=ma-politique
```

### Gérer les politiques

```bash
# Lister les politiques
gcloud compute security-policies list

# Détails d'une politique
gcloud compute security-policies describe ma-politique

# Lister les règles
gcloud compute security-policies rules list --security-policy=ma-politique

# Supprimer une règle
gcloud compute security-policies rules delete 1000 \
    --security-policy=ma-politique

# Supprimer une politique
gcloud compute security-policies delete ma-politique
```

---

## 15. Monitoring et Logging

### Cloud Logging

```bash
# Lire les logs récents
gcloud logging read "resource.type=gce_instance" --limit=10

# Logs avec filtre
gcloud logging read 'resource.type="gce_subnetwork" AND 
    jsonPayload.connection.dest_port="22"' \
    --limit=50

# Logs de pare-feu
gcloud logging read 'resource.type="gce_subnetwork" AND 
    jsonPayload.rule_details.action="DENY"' \
    --limit=20

# Exporter vers un fichier
gcloud logging read "severity>=ERROR" --format=json > errors.json

# Créer un sink vers BigQuery
gcloud logging sinks create mon-sink \
    bigquery.googleapis.com/projects/MON_PROJET/datasets/logs_dataset \
    --log-filter='resource.type="gce_subnetwork"'

# Lister les sinks
gcloud logging sinks list

# Supprimer un sink
gcloud logging sinks delete mon-sink
```

### Cloud Monitoring

```bash
# Lister les métriques disponibles
gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com"

# Lire une métrique
gcloud monitoring metrics list \
    --filter='metric.type="compute.googleapis.com/instance/cpu/utilization"'

# Créer un canal de notification
gcloud alpha monitoring channels create \
    --display-name="Email Admin" \
    --type=email \
    --channel-labels=email_address=admin@example.com

# Lister les canaux
gcloud alpha monitoring channels list

# Créer une politique d'alerte (via fichier YAML recommandé)
gcloud alpha monitoring policies create --policy-from-file=alerte.yaml

# Lister les dashboards
gcloud monitoring dashboards list

# Créer un dashboard depuis un fichier JSON
gcloud monitoring dashboards create --config-from-file=dashboard.json
```

---

## 16. Network Intelligence Center

### Connectivity Tests

```bash
# Créer un test de connectivité
gcloud network-management connectivity-tests create test-vm-to-vm \
    --source-instance=projects/MON_PROJET/zones/europe-west1-b/instances/vm-source \
    --destination-instance=projects/MON_PROJET/zones/europe-west1-b/instances/vm-dest \
    --protocol=TCP \
    --destination-port=80

# Test vers une IP externe
gcloud network-management connectivity-tests create test-to-internet \
    --source-instance=projects/MON_PROJET/zones/europe-west1-b/instances/ma-vm \
    --destination-ip-address=8.8.8.8 \
    --protocol=TCP \
    --destination-port=443

# Lister les tests
gcloud network-management connectivity-tests list

# Détails d'un test
gcloud network-management connectivity-tests describe test-vm-to-vm

# Relancer un test
gcloud network-management connectivity-tests rerun test-vm-to-vm

# Supprimer un test
gcloud network-management connectivity-tests delete test-vm-to-vm
```

### Firewall Insights

```bash
# Lister les insights
gcloud recommender insights list \
    --insight-type=google.compute.firewall.Insight \
    --location=global \
    --project=MON_PROJET

# Lister les recommandations
gcloud recommender recommendations list \
    --recommender=google.compute.firewall.Recommender \
    --location=global \
    --project=MON_PROJET
```

---

## 17. IAM et projets

### Gestion des projets

```bash
# Créer un projet
gcloud projects create mon-nouveau-projet \
    --name="Mon Nouveau Projet" \
    --labels=env=dev

# Lier à un compte de facturation
gcloud billing projects link mon-nouveau-projet \
    --billing-account=XXXXXX-XXXXXX-XXXXXX

# Lister les projets
gcloud projects list

# Supprimer un projet
gcloud projects delete mon-projet
```

### Gestion des APIs

```bash
# Activer une API
gcloud services enable compute.googleapis.com

# Activer plusieurs APIs
gcloud services enable \
    compute.googleapis.com \
    dns.googleapis.com \
    monitoring.googleapis.com

# Lister les APIs activées
gcloud services list --enabled

# Désactiver une API
gcloud services disable compute.googleapis.com
```

### Gestion IAM

```bash
# Voir les permissions d'un projet
gcloud projects get-iam-policy MON_PROJET

# Ajouter un membre
gcloud projects add-iam-policy-binding MON_PROJET \
    --member="user:utilisateur@example.com" \
    --role="roles/compute.networkAdmin"

# Supprimer un membre
gcloud projects remove-iam-policy-binding MON_PROJET \
    --member="user:utilisateur@example.com" \
    --role="roles/compute.networkAdmin"

# Créer un rôle personnalisé
gcloud iam roles create monRole \
    --project=MON_PROJET \
    --title="Mon Rôle Personnalisé" \
    --permissions=compute.networks.get,compute.networks.list

# Lister les rôles personnalisés
gcloud iam roles list --project=MON_PROJET
```

### Service Accounts

```bash
# Créer un service account
gcloud iam service-accounts create mon-sa \
    --display-name="Mon Service Account"

# Lister les service accounts
gcloud iam service-accounts list

# Créer une clé
gcloud iam service-accounts keys create cle.json \
    --iam-account=mon-sa@MON_PROJET.iam.gserviceaccount.com

# Donner un rôle à un service account
gcloud projects add-iam-policy-binding MON_PROJET \
    --member="serviceAccount:mon-sa@MON_PROJET.iam.gserviceaccount.com" \
    --role="roles/compute.networkAdmin"
```

---

## 18. Astuces et bonnes pratiques

### Formatage de sortie

```bash
# Format tableau (par défaut)
gcloud compute instances list

# Format JSON
gcloud compute instances list --format=json

# Format YAML
gcloud compute instances list --format=yaml

# Format personnalisé
gcloud compute instances list \
    --format="table(name,zone,status,networkInterfaces[0].networkIP)"

# Extraire une valeur spécifique
gcloud compute instances describe ma-vm \
    --zone=europe-west1-b \
    --format="value(networkInterfaces[0].networkIP)"
```

### Filtres

```bash
# Filtre simple
gcloud compute instances list --filter="zone:europe-west1-b"

# Filtre avec expressions
gcloud compute instances list --filter="status=RUNNING"
gcloud compute instances list --filter="name~^web-"
gcloud compute instances list --filter="labels.env=prod"

# Filtres combinés
gcloud compute instances list \
    --filter="zone:europe-west1-b AND status=RUNNING"
```

### Suppressions en masse

```bash
# Supprimer plusieurs VMs
gcloud compute instances list --filter="name~^test-" \
    --format="value(name,zone)" | \
    while read name zone; do
        gcloud compute instances delete $name --zone=$zone --quiet
    done

# Supprimer toutes les règles de pare-feu d'un VPC
gcloud compute firewall-rules list \
    --filter="network:mon-vpc" \
    --format="value(name)" | \
    xargs -I {} gcloud compute firewall-rules delete {} --quiet
```

### Mode silencieux et scripts

```bash
# Supprimer sans confirmation
gcloud compute instances delete ma-vm --zone=europe-west1-b --quiet

# Ignorer les erreurs dans un script
gcloud compute instances delete ma-vm --zone=europe-west1-b --quiet 2>/dev/null || true

# Vérifier si une ressource existe
if gcloud compute networks describe mon-vpc &>/dev/null; then
    echo "Le VPC existe"
else
    echo "Le VPC n'existe pas"
fi
```

### Variables d'environnement

```bash
# Définir le projet via variable d'environnement
export CLOUDSDK_CORE_PROJECT=mon-projet
export CLOUDSDK_COMPUTE_REGION=europe-west1
export CLOUDSDK_COMPUTE_ZONE=europe-west1-b

# Utilisation dans les scripts
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region)
```

### Alias utiles

Ajoutez à votre `~/.bashrc` ou `~/.zshrc` :

```bash
# Alias gcloud
alias gcl='gcloud'
alias gce='gcloud compute'
alias gci='gcloud compute instances'
alias gcn='gcloud compute networks'
alias gcf='gcloud compute firewall-rules'

# Commandes fréquentes
alias vms='gcloud compute instances list'
alias vpcs='gcloud compute networks list'
alias subnets='gcloud compute networks subnets list'
alias fws='gcloud compute firewall-rules list'
alias routes='gcloud compute routes list'

# SSH rapide
gssh() {
    gcloud compute ssh "$1" --zone="${2:-europe-west1-b}"
}
```

---

## 📚 Résumé des commandes par thème

| Thème | Groupe principal | Commandes clés |
|-------|------------------|----------------|
| **Configuration** | `gcloud config` | `set`, `get-value`, `list` |
| **VMs** | `gcloud compute instances` | `create`, `delete`, `list`, `ssh` |
| **VPCs** | `gcloud compute networks` | `create`, `delete`, `list`, `peerings` |
| **Subnets** | `gcloud compute networks subnets` | `create`, `update`, `expand-ip-range` |
| **Firewall** | `gcloud compute firewall-rules` | `create`, `update`, `delete` |
| **Routes** | `gcloud compute routes` | `create`, `delete`, `list` |
| **Router/NAT** | `gcloud compute routers` | `create`, `nats create`, `add-bgp-peer` |
| **VPN** | `gcloud compute vpn-gateways/tunnels` | `create`, `delete` |
| **Load Balancing** | `gcloud compute backend-services` | `create`, `add-backend` |
| **DNS** | `gcloud dns managed-zones` | `create`, `record-sets` |
| **Cloud Armor** | `gcloud compute security-policies` | `create`, `rules create` |
| **Logging** | `gcloud logging` | `read`, `sinks create` |
| **Monitoring** | `gcloud monitoring` | `metrics list`, `dashboards` |
| **Connectivity Tests** | `gcloud network-management` | `connectivity-tests create` |
| **IAM** | `gcloud projects` | `add-iam-policy-binding` |

---

## 📖 Ressources complémentaires

- **Documentation officielle** : https://cloud.google.com/sdk/gcloud/reference
- **Cheat Sheet Google** : https://cloud.google.com/sdk/docs/cheatsheet
- **Cloud Shell** : https://shell.cloud.google.com

---

**Bonne pratique avec gcloud ! 🚀**

*Dernière mise à jour : Janvier 2026*
