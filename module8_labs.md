# Module 8 - Contrôle d'Accès et Sécurité Réseau
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Configurer les rôles IAM réseau avec le principe du moindre privilège
- Maîtriser les différents types de règles de pare-feu (VPC, Hierarchical, Network Policies)
- Utiliser les Service Accounts pour les règles de pare-feu
- Configurer et analyser les logs de pare-feu
- Déployer IAP pour l'accès sécurisé aux VMs
- Mettre en place Cloud IDS pour la détection d'intrusion
- Comprendre Cloud NGFW et Secure Web Proxy
- Appliquer les bonnes pratiques de sécurité réseau

### Prérequis
- Modules 1 à 7 complétés
- Projet GCP avec facturation activée
- Droits : roles/compute.networkAdmin, roles/compute.securityAdmin
- (Optionnel) Organisation GCP pour les politiques hiérarchiques

### Note importante
⚠️ Certains labs nécessitent des droits au niveau organisation pour les politiques hiérarchiques. Des alternatives au niveau projet sont proposées.

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 8.1 | IAM Réseau - Rôles et permissions | ⭐ |
| 8.2 | Règles de pare-feu VPC - Fondamentaux | ⭐⭐ |
| 8.3 | Tags réseau vs Service Accounts | ⭐⭐ |
| 8.4 | Network Firewall Policies - Global et Regional | ⭐⭐ |
| 8.5 | Hierarchical Firewall Policies | ⭐⭐⭐ |
| 8.6 | Logging et analyse des règles de pare-feu | ⭐⭐ |
| 8.7 | IAP (Identity-Aware Proxy) pour TCP | ⭐⭐ |
| 8.8 | Cloud IDS - Détection d'intrusion | ⭐⭐⭐ |
| 8.9 | Secure Web Proxy - Filtrage egress | ⭐⭐⭐ |
| 8.10 | Bonnes pratiques et hardening | ⭐⭐ |
| 8.11 | Scénario intégrateur - Architecture sécurisée | ⭐⭐⭐ |

---

## Lab 8.1 : IAM Réseau - Rôles et permissions
**Difficulté : ⭐**

### Objectifs
- Comprendre les rôles IAM réseau
- Appliquer le principe du moindre privilège
- Configurer les permissions au niveau ressource

### Exercices

#### Exercice 8.1.1 : Découvrir les rôles réseau

```bash
# Lister les rôles réseau disponibles
gcloud iam roles list --filter="name:compute.network" --format="table(name,title)"

# Détail d'un rôle spécifique
gcloud iam roles describe roles/compute.networkAdmin

# Permissions du rôle networkAdmin
gcloud iam roles describe roles/compute.networkAdmin \
    --format="yaml(includedPermissions)"
```

#### Exercice 8.1.2 : Tableau des rôles réseau

=== Rôles IAM Réseau Principaux ===

| Rôle | Permissions | Cas d'usage |
|------|-------------|-------------|
| roles/compute.networkAdmin | Gérer VPC, sous-réseaux, routes, pare-feu | Admin réseau |
| roles/compute.networkUser | Utiliser les sous-réseaux | Développeurs |
| roles/compute.securityAdmin | Gérer règles de pare-feu, SSL | Admin sécurité |
| roles/compute.networkViewer | Lecture seule sur config réseau | Auditeurs |
| roles/compute.xpnAdmin | Gérer Shared VPC | Admin Shared VPC |

Granularité des permissions:
```
┌─────────────────────────────────────────────────────────────────────┐
│ Organisation (policies globales - équipe sécurité centrale)         │
│   ├── Dossier (par département - délégation par BU)                 │
│   │     ├── Projet (par environnement - équipes projet)             │
│   │     │     └── Ressource (par sous-réseau - accès fin)           │
└─────────────────────────────────────────────────────────────────────┘
```

#### Exercice 8.1.3 : Configuration trop permissive vs correcte

```bash
# ❌ MAUVAIS : Donner networkAdmin sur tout le projet
# Ceci permet de modifier TOUS les VPC, sous-réseaux, pare-feu
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:dev@example.com" \
    --role="roles/compute.networkAdmin"
# NE PAS EXÉCUTER - exemple uniquement

# ✅ CORRECT : Donner networkUser sur un sous-réseau spécifique
# Permet seulement d'utiliser ce sous-réseau pour créer des VMs
gcloud compute networks subnets add-iam-policy-binding subnet-dev \
    --region=europe-west1 \
    --member="user:dev@example.com" \
    --role="roles/compute.networkUser"
```

#### Exercice 8.1.4 : Créer un rôle personnalisé

```bash
# Créer un rôle personnalisé avec permissions limitées
cat > network-viewer-custom.yaml << 'EOF'
title: "Network Viewer Custom"
description: "Lecture réseau sans accès aux règles de pare-feu"
stage: "GA"
includedPermissions:
- compute.networks.get
- compute.networks.list
- compute.subnetworks.get
- compute.subnetworks.list
- compute.routes.get
- compute.routes.list
# Note: Pas de compute.firewalls.* 
EOF

gcloud iam roles create NetworkViewerCustom \
    --project=$PROJECT_ID \
    --file=network-viewer-custom.yaml

# Attribuer le rôle
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:auditor@example.com" \
    --role="projects/$PROJECT_ID/roles/NetworkViewerCustom"
```

---

## Lab 8.2 : Règles de pare-feu VPC - Fondamentaux
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre les règles de pare-feu VPC
- Configurer les règles ingress et egress
- Utiliser les priorités efficacement

### Architecture cible

```
                        VPC Security Lab
    ┌────────────────────────────────────────────────────────────┐
    │                                                            │
    │   ┌─────────────────┐         ┌─────────────────┐          │
    │   │ subnet-frontend │         │ subnet-backend  │          │
    │   │  10.0.1.0/24    │         │  10.0.2.0/24    │          │
    │   │                 │         │                 │          │
    │   │ ┌─────────────┐ │         │ ┌─────────────┐ │          │
    │   │ │   vm-web    │ │ ──────► │ │   vm-api    │ │          │
    │   │ │ tag: web    │ │  :8080  │ │ tag: api    │ │          │
    │   │ └─────────────┘ │         │ └─────────────┘ │          │
    │   │                 │         │       │         │          │
    │   └─────────────────┘         │       ▼ :5432   │          │
    │                               │ ┌─────────────┐ │          │
    │                               │ │   vm-db     │ │          │
    │                               │ │ tag: db     │ │          │
    │                               │ └─────────────┘ │          │
    │                               └─────────────────┘          │
    │                                                            │
    │   Règles de pare-feu:                                      │
    │   - Internet → web: 80, 443                                │
    │   - web → api: 8080                                        │
    │   - api → db: 5432                                         │
    │   - Deny all other                                         │
    └────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 8.2.1 : Créer l'infrastructure

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom

# Sous-réseaux
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24

gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.2.0/24

# VMs avec tags
gcloud compute instances create vm-web \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --tags=web \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y nginx dnsutils netcat-openbsd'

gcloud compute instances create vm-api \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --tags=api \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils netcat-openbsd'

gcloud compute instances create vm-db \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --tags=db \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils netcat-openbsd'
```

#### Exercice 8.2.2 : Comprendre les règles par défaut

```bash
# Lister les règles de pare-feu par défaut du VPC
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME" \
    --format="table(name,direction,priority,sourceRanges,allowed)"
```

=== Règles implicites (non visibles dans la liste) ===

| Règle | Priorité | Comportement |
|-------|----------|--------------|
| Deny all ingress | 65535 | Bloque tout trafic entrant |
| Allow all egress | 65535 | Autorise tout trafic sortant |

Ces règles ne peuvent pas être supprimées mais peuvent être "overridées"
par des règles avec une priorité plus haute (nombre plus bas).

#### Exercice 8.2.3 : Créer les règles de pare-feu

```bash
# 1. Autoriser SSH via IAP (pour administration)
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap-ssh \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --priority=1000 \
    --description="SSH via IAP"

# 2. Autoriser HTTP/HTTPS vers les serveurs web
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-web \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web \
    --priority=1000 \
    --description="HTTP/HTTPS vers serveurs web"

# 3. Autoriser web → api sur port 8080
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-tags=web \
    --target-tags=api \
    --priority=1000 \
    --description="Web vers API"

# 4. Autoriser api → db sur port 5432
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:5432 \
    --source-tags=api \
    --target-tags=db \
    --priority=1000 \
    --description="API vers Database"

# 5. Autoriser ICMP interne (pour debug)
gcloud compute firewall-rules create ${VPC_NAME}-allow-icmp-internal \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="ICMP interne"

# Lister les règles créées
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME" \
    --format="table(name,direction,priority,sourceRanges,sourceTags,targetTags,allowed)"
```

#### Exercice 8.2.4 : Ajouter des règles de blocage explicites

```bash
# Bloquer les ports dangereux (priorité haute)
gcloud compute firewall-rules create ${VPC_NAME}-deny-dangerous-ports \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:23,tcp:3389,tcp:445,tcp:135-139 \
    --source-ranges=0.0.0.0/0 \
    --priority=500 \
    --description="Bloquer Telnet, RDP, SMB"

# Bloquer tout trafic sortant sauf nécessaire (optionnel, mode strict)
gcloud compute firewall-rules create ${VPC_NAME}-deny-all-egress \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=DENY \
    --rules=all \
    --destination-ranges=0.0.0.0/0 \
    --priority=65000 \
    --description="Deny all egress par défaut"

# Autoriser egress vers APIs Google
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=tcp:443 \
    --destination-ranges=199.36.153.8/30,199.36.153.4/30 \
    --priority=1000 \
    --description="Egress vers APIs Google"

# Autoriser egress interne
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-internal \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=all \
    --destination-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Egress interne"
```

#### Exercice 8.2.5 : Tester les règles

```bash
# Test depuis vm-web
gcloud compute ssh vm-web --zone=$ZONE << 'EOF'
echo "=== Test depuis vm-web ==="

# Test vers vm-api (devrait fonctionner)
echo "Test connexion vers vm-api:8080..."
nc -zv 10.0.2.3 8080 -w 3 2>&1 || echo "Port 8080 non accessible (attendu si pas de service)"

# Test vers vm-db (devrait échouer - pas autorisé directement)
echo "Test connexion vers vm-db:5432..."
nc -zv 10.0.2.4 5432 -w 3 2>&1 || echo "Port 5432 non accessible (attendu)"

# Test ICMP
echo "Test ping vers vm-api..."
ping -c 2 10.0.2.3
EOF
```

**Questions :**
1. Pourquoi utiliser des priorités différentes (500 vs 1000) ?
2. Que se passe-t-il si deux règles ont la même priorité mais des actions différentes ?

---

## Lab 8.3 : Tags réseau vs Service Accounts
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre les différences entre tags et service accounts
- Migrer des règles basées sur tags vers service accounts
- Appliquer les bonnes pratiques

### Exercices

#### Exercice 8.3.1 : Comprendre les différences

```
=== Tags Réseau vs Service Accounts ===

┌─────────────────────────────────────────────────────────────────────────────┐
│                           TAGS RÉSEAU                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ Avantages:                                                               │
│    - Simple à utiliser                                                      │
│    - Visible dans la console                                                │
│    - Flexible (plusieurs tags par VM)                                       │
│                                                                             │
│ ❌ Inconvénients:                                                           │
│    - Modifiable par quiconque peut éditer la VM                             │
│    - Pas de contrôle IAM fin                                                │
│    - Risque d'erreur humaine                                                │
│    - Pas d'audit des modifications                                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         SERVICE ACCOUNTS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ Avantages:                                                               │
│    - Contrôlé par IAM                                                       │
│    - Non modifiable par les développeurs                                    │
│    - Identité forte                                                         │
│    - Audit trail complet                                                    │
│                                                                             │
│ ❌ Inconvénients:                                                           │
│    - Configuration plus complexe                                            │
│    - Nécessite une stratégie de Service Accounts                            │
│    - Un seul SA par VM                                                      │
└─────────────────────────────────────────────────────────────────────────────┘

Recommandation: En production, préférez les Service Accounts
```

#### Exercice 8.3.2 : Créer les Service Accounts

```bash
# Créer des Service Accounts pour chaque tier
gcloud iam service-accounts create sa-web \
    --display-name="Service Account - Web Tier"

gcloud iam service-accounts create sa-api \
    --display-name="Service Account - API Tier"

gcloud iam service-accounts create sa-db \
    --display-name="Service Account - Database Tier"

# Lister les SA créés
gcloud iam service-accounts list \
    --format="table(email,displayName)"
```

#### Exercice 8.3.3 : Créer de nouvelles VMs avec Service Accounts

```bash
# Supprimer les anciennes VMs
for VM in vm-web vm-api vm-db; do
    gcloud compute instances delete $VM --zone=$ZONE --quiet
done

# Recréer avec Service Accounts
gcloud compute instances create vm-web-sa \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --service-account=sa-web@${PROJECT_ID}.iam.gserviceaccount.com \
    --scopes=cloud-platform \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y nginx'

gcloud compute instances create vm-api-sa \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --service-account=sa-api@${PROJECT_ID}.iam.gserviceaccount.com \
    --scopes=cloud-platform \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

gcloud compute instances create vm-db-sa \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --service-account=sa-db@${PROJECT_ID}.iam.gserviceaccount.com \
    --scopes=cloud-platform \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 8.3.4 : Créer des règles basées sur Service Accounts

```bash
# Règle: web → api (basée sur Service Accounts)
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=sa-web@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-api@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="Web vers API (Service Accounts)"

# Règle: api → db (basée sur Service Accounts)
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:5432 \
    --source-service-accounts=sa-api@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-db@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="API vers Database (Service Accounts)"

# Règle: HTTP vers web (basée sur Service Account cible)
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-web-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-service-accounts=sa-web@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="HTTP/HTTPS vers web (Service Account)"
```

#### Exercice 8.3.5 : Comparer la sécurité

=== Comparaison de sécurité ===

Scénario: Un développeur malveillant veut accéder à la base de données

Avec TAGS:
1. Le dev a accès à la VM vm-web
2. Il peut modifier les tags via: gcloud compute instances add-tags vm-web --tags=db
3. La VM vm-web a maintenant le tag "db"
4. Les règles de pare-feu l'autorisent à recevoir du trafic destiné aux DB
❌ VIOLATION DE SÉCURITÉ

Avec SERVICE ACCOUNTS:
1. Le dev a accès à la VM vm-web
2. Il ne peut PAS changer le Service Account (nécessite roles/iam.serviceAccountUser)
3. La VM garde son SA "sa-web"
4. Les règles de pare-feu basées sur SA restent correctes
✅ SÉCURITÉ MAINTENUE

Conclusion: Les Service Accounts offrent une sécurité renforcée car:
- Les SA sont contrôlés par IAM
- Les modifications sont auditées
- La séparation des privilèges est respectée

---

## Lab 8.4 : Network Firewall Policies - Global et Regional
**Difficulté : ⭐⭐**

### Objectifs
- Créer des Network Firewall Policies
- Comprendre les différences Global vs Regional
- Attacher des politiques aux VPCs

### Exercices

#### Exercice 8.4.1 : Comprendre les Network Firewall Policies

=== Network Firewall Policies vs VPC Firewall Rules ===

| Critère | VPC Firewall Rules | Network Firewall Policies |
|---------|-------------------|--------------------------|
| Portée | VPC unique | VPC ou global |
| Réutilisabilité | Non | Oui (attachable à plusieurs VPC) |
| Actions | ALLOW, DENY | ALLOW, DENY, GOTO_NEXT, IPS |
| Fonctionnalités | Basiques | Avancées (FQDN, géoloc, Threat Intel) |
| Gestion | Par projet | Centralisable |

Ordre d'évaluation:
1. Hierarchical Firewall Policies (organisation/dossier)
2. Global Network Firewall Policies
3. Regional Network Firewall Policies
4. VPC Firewall Rules

#### Exercice 8.4.2 : Créer une Global Network Firewall Policy

```bash
# Créer la politique globale
gcloud compute network-firewall-policies create global-security-policy \
    --global \
    --description="Politique de sécurité globale"

# Ajouter une règle pour bloquer les ports dangereux
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=deny \
    --layer4-configs=tcp:23,tcp:3389,tcp:445 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Bloquer Telnet, RDP, SMB globalement"

# Ajouter une règle pour autoriser les health checks Google
gcloud compute network-firewall-policies rules create 200 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:80,tcp:443 \
    --src-ip-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Autoriser Health Checks Google"

# Ajouter une règle pour autoriser IAP
gcloud compute network-firewall-policies rules create 300 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:22,tcp:3389 \
    --src-ip-ranges=35.235.240.0/20 \
    --description="Autoriser SSH/RDP via IAP"

# Lister les règles
gcloud compute network-firewall-policies rules list \
    --firewall-policy=global-security-policy \
    --global-firewall-policy
```

#### Exercice 8.4.3 : Associer la politique au VPC

```bash
# Associer au VPC
gcloud compute network-firewall-policies associations create \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --network=$VPC_NAME \
    --name=assoc-${VPC_NAME}

# Vérifier l'association
gcloud compute network-firewall-policies describe global-security-policy \
    --global \
    --format="yaml(associations)"
```

#### Exercice 8.4.4 : Créer une Regional Network Firewall Policy

```bash
# Créer une politique régionale pour l'Europe
gcloud compute network-firewall-policies create europe-policy \
    --region=$REGION \
    --description="Politique régionale Europe West 1"

# Règle spécifique à la région
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=europe-policy \
    --firewall-policy-region=$REGION \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:22 \
    --src-ip-ranges=10.0.0.0/8 \
    --description="SSH interne Europe uniquement"

# Associer au VPC pour cette région
gcloud compute network-firewall-policies associations create \
    --firewall-policy=europe-policy \
    --firewall-policy-region=$REGION \
    --network=$VPC_NAME \
    --name=assoc-europe-${VPC_NAME}
```

#### Exercice 8.4.5 : Tester l'ordre d'évaluation

```bash
# Créer une règle conflictuelle pour observer l'ordre
# La politique globale va primer sur les VPC Rules

# Test: La règle "deny Telnet" de la politique globale 
# devrait bloquer même si une VPC rule l'autorise

# Créer une VPC rule qui autorise Telnet (pour test)
gcloud compute firewall-rules create ${VPC_NAME}-test-allow-telnet \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:23 \
    --source-ranges=10.0.0.0/8 \
    --priority=1000

# Test: Le trafic Telnet devrait toujours être bloqué
# car la Network Firewall Policy (priorité 100) prime
# sur la VPC Rule (même si elle autorise)

# Nettoyer la règle de test
gcloud compute firewall-rules delete ${VPC_NAME}-test-allow-telnet --quiet
```

---

## Lab 8.5 : Hierarchical Firewall Policies
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer des politiques hiérarchiques
- Comprendre l'action GOTO_NEXT
- Implémenter une délégation de sécurité

### Note préalable
⚠️ Ce lab nécessite des droits au niveau organisation ou dossier. Si vous n'avez pas ces droits, lisez les exercices pour comprendre les concepts.

### Architecture des politiques hiérarchiques

```
                    ┌─────────────────────────────┐
                    │      Organisation           │
                    │   Politique: org-policy     │
                    │   - Deny Telnet (23)        │
                    │   - Deny RDP externe        │
                    │   - GOTO_NEXT pour HTTP     │
                    └──────────────┬──────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
    ┌─────────▼─────────┐ ┌───────▼────────┐ ┌────────▼────────┐
    │   Dossier Prod    │ │  Dossier Dev   │ │  Dossier Test   │
    │   Politique:      │ │  Politique:    │ │  (pas de policy)│
    │   - Deny SSH ext  │ │  - Allow all   │ │                 │
    │   - Allow HTTP    │ │    internal    │ │                 │
    └─────────┬─────────┘ └───────┬────────┘ └────────┬────────┘
              │                   │                   │
    ┌─────────▼─────────┐ ┌───────▼────────┐ ┌────────▼────────┐
    │   Projet Prod-1   │ │  Projet Dev-1  │ │  Projet Test-1  │
    │   VPC Firewall    │ │  VPC Firewall  │ │  VPC Firewall   │
    │   Rules           │ │  Rules         │ │  Rules          │
    └───────────────────┘ └────────────────┘ └─────────────────┘
```

### Exercices

#### Exercice 8.5.1 : Créer une politique hiérarchique (simulation)

```bash
# Note: Ces commandes nécessitent des droits organisation
# Remplacez ORGANIZATION_ID par votre ID d'organisation

ORGANIZATION_ID="123456789"  # Remplacer par votre org ID

# Créer la politique
gcloud compute firewall-policies create \
    --organization=$ORGANIZATION_ID \
    --short-name=org-security-policy \
    --description="Politique de sécurité organisation"

# Ajouter des règles

# 1. Bloquer Telnet partout (deny)
gcloud compute firewall-policies rules create 100 \
    --firewall-policy=org-security-policy \
    --organization=$ORGANIZATION_ID \
    --direction=INGRESS \
    --action=deny \
    --layer4-configs=tcp:23 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Bloquer Telnet dans toute l'organisation"

# 2. Bloquer RDP depuis Internet (deny)
gcloud compute firewall-policies rules create 200 \
    --firewall-policy=org-security-policy \
    --organization=$ORGANIZATION_ID \
    --direction=INGRESS \
    --action=deny \
    --layer4-configs=tcp:3389 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Bloquer RDP externe"

# 3. Déléguer la décision HTTP/HTTPS aux dossiers (goto_next)
gcloud compute firewall-policies rules create 300 \
    --firewall-policy=org-security-policy \
    --organization=$ORGANIZATION_ID \
    --direction=INGRESS \
    --action=goto_next \
    --layer4-configs=tcp:80,tcp:443 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Déléguer HTTP/HTTPS aux niveaux inférieurs"

# Associer à l'organisation
gcloud compute firewall-policies associations create \
    --firewall-policy=org-security-policy \
    --organization=$ORGANIZATION_ID
```

#### Exercice 8.5.2 : Comprendre les actions

=== Actions des règles hiérarchiques ===

| Action | Comportement |
|--------|-------------|
| allow | Autorise le trafic, ARRÊTE l'évaluation |
| deny | Bloque le trafic, ARRÊTE l'évaluation |
| goto_next | CONTINUE l'évaluation au niveau suivant |
| apply_security_profile_group | Applique inspection IDS/IPS |

Flux d'évaluation avec GOTO_NEXT:
```
Requête HTTP arrive
       │
       ▼
┌──────────────────────────┐
│ Hierarchical Policy (Org)│
│ Règle HTTP: GOTO_NEXT    │──► Continue vers le niveau suivant
└──────────────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Hierarchical Policy      │
│ (Dossier)                │
│ Règle HTTP: ALLOW        │──► Autorise et ARRÊTE
└──────────────────────────┘
```

Utilisations de GOTO_NEXT:
- Déléguer des décisions aux équipes projet
- Permettre des exceptions par dossier
- Implémenter une politique "deny by default" avec exceptions

#### Exercice 8.5.3 : Simulation au niveau projet

```bash
# Si vous n'avez pas accès à l'organisation, simulez avec des VPC rules

# Simuler une politique "organisation" avec priorité très haute
gcloud compute firewall-rules create ${VPC_NAME}-org-deny-telnet \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --description="Simule politique org: deny Telnet"

gcloud compute firewall-rules create ${VPC_NAME}-org-deny-rdp-external \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:3389 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --description="Simule politique org: deny RDP externe"

# Autoriser RDP interne (priorité plus basse = évalué après)
gcloud compute firewall-rules create ${VPC_NAME}-allow-rdp-internal \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:3389 \
    --source-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Autoriser RDP interne"

# Test: RDP depuis Internet sera bloqué (règle priorité 100)
# Test: RDP depuis interne sera autorisé (la règle deny ne matche pas 10.0.0.0/8)
```

---

## Lab 8.6 : Logging et analyse des règles de pare-feu
**Difficulté : ⭐⭐**

### Objectifs
- Activer le logging sur les règles de pare-feu
- Analyser les logs de pare-feu
- Créer des alertes sur les événements

### Exercices

#### Exercice 8.6.1 : Activer le logging

```bash
# Activer le logging sur une règle existante
gcloud compute firewall-rules update ${VPC_NAME}-allow-http-web-sa \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA

# Activer le logging sur une règle de deny
gcloud compute firewall-rules update ${VPC_NAME}-deny-dangerous-ports \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA

# Vérifier le statut du logging
gcloud compute firewall-rules describe ${VPC_NAME}-allow-http-web-sa \
    --format="yaml(logConfig)"
```

#### Exercice 8.6.2 : Générer du trafic pour les logs

```bash
# Générer du trafic HTTP (sera loggé comme ALLOWED)
curl http://$(gcloud compute instances describe vm-web-sa --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)") 2>/dev/null || true

# Tenter une connexion Telnet (sera loggé comme DENIED)
gcloud compute ssh vm-web-sa --zone=$ZONE << 'EOF'
nc -zv localhost 23 -w 2 2>&1 || true
EOF
```

#### Exercice 8.6.3 : Consulter les logs de pare-feu

```bash
# Logs de trafic autorisé
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="ALLOWED"
' --limit=10 --format="table(
    timestamp,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.rule_details.reference
)"

# Logs de trafic refusé
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=10 --format="table(
    timestamp,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.rule_details.reference
)"

# Logs pour un VPC spécifique
gcloud logging read "
    resource.type=\"gce_subnetwork\" AND
    resource.labels.subnetwork_name=\"subnet-frontend\"
" --limit=10
```

#### Exercice 8.6.4 : Structure des logs de pare-feu

```json
{
  "jsonPayload": {
    "connection": {
      "src_ip": "203.0.113.50",        // IP source
      "src_port": 54321,                // Port source
      "dest_ip": "10.0.1.10",          // IP destination
      "dest_port": 80,                  // Port destination
      "protocol": 6                     // 6=TCP, 17=UDP, 1=ICMP
    },
    "disposition": "ALLOWED",           // ALLOWED ou DENIED
    "rule_details": {
      "reference": "network:vpc-security-lab/firewall:allow-http-web",
      "priority": 1000,
      "action": "ALLOW",
      "direction": "INGRESS"
    },
    "instance": {
      "vm_name": "vm-web-sa",
      "zone": "europe-west1-b",
      "project_id": "mon-projet"
    },
    "vpc": {
      "vpc_name": "vpc-security-lab",
      "subnetwork_name": "subnet-frontend"
    }
  }
}
```

Champs utiles pour l'analyse:
- disposition: ALLOWED/DENIED (le plus important)
- rule_details.reference: Quelle règle a pris la décision
- connection.*: Détails de la connexion

#### Exercice 8.6.5 : Créer des requêtes d'analyse avancées

```bash
# Top 10 des IPs sources bloquées
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=1000 --format="value(jsonPayload.connection.src_ip)" | \
    sort | uniq -c | sort -rn | head -10

# Ports les plus sollicités (bloqués)
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=1000 --format="value(jsonPayload.connection.dest_port)" | \
    sort | uniq -c | sort -rn | head -10

# Créer une métrique basée sur les logs
gcloud logging metrics create firewall-denied-count \
    --description="Nombre de connexions bloquées par le pare-feu" \
    --log-filter='resource.type="gce_subnetwork" AND jsonPayload.disposition="DENIED"'
```

---

## Lab 8.7 : IAP (Identity-Aware Proxy) pour TCP
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre IAP pour TCP (accès "bastionless")
- Configurer l'accès SSH via IAP
- Sécuriser l'accès aux VMs sans IP publique

### Architecture IAP

```
    Administrateur                          VPC GCP
    ┌───────────────┐                    ┌─────────────────────────────────┐
    │               │                    │                                 │
    │   Terminal    │                    │   ┌───────────────────────┐     │
    │   gcloud ssh  │                    │   │  VM sans IP publique  │     │
    │               │                    │   │  10.0.1.10            │     │
    └───────┬───────┘                    │   └───────────▲───────────┘     │
            │                            │               │                 │
            │ 1. Authentification        │               │                 │
            │    Google                  │               │ 3. SSH          │
            ▼                            │               │    tunnel       │
    ┌───────────────┐                    │   ┌───────────┴───────────┐     │
    │  IAP Service  │───────────────────────►│   IAP TCP Forwarder   │     │
    │  (Google)     │  2. Tunnel HTTPS   │   │   35.235.240.0/20     │     │
    └───────────────┘                    │   └───────────────────────┘     │
                                         │                                 │
                                         │   Règle pare-feu:               │
                                         │   ALLOW tcp:22                  │
                                         │   FROM 35.235.240.0/20          │
                                         └─────────────────────────────────┘

Avantages:
- Pas de bastion à gérer
- Pas d'IP publique sur les VMs
- Authentification forte (IAM)
- Audit trail complet
```

### Exercices

#### Exercice 8.7.1 : Vérifier la configuration IAP

```bash
# Vérifier que la règle pare-feu pour IAP existe
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND sourceRanges:35.235.240.0/20" \
    --format="table(name,direction,allowed)"

# Si elle n'existe pas, la créer
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22,tcp:3389 \
    --source-ranges=35.235.240.0/20 \
    --description="Autoriser SSH/RDP via IAP"
```

#### Exercice 8.7.2 : Configurer les permissions IAM

```bash
# Donner le rôle IAP Tunnel User à un utilisateur
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:admin@example.com" \
    --role="roles/iap.tunnelResourceAccessor"

# Ou de manière plus granulaire, sur une VM spécifique
gcloud compute instances add-iam-policy-binding vm-api-sa \
    --zone=$ZONE \
    --member="user:admin@example.com" \
    --role="roles/iap.tunnelResourceAccessor"

# Vérifier les permissions
gcloud compute instances get-iam-policy vm-api-sa --zone=$ZONE
```

#### Exercice 8.7.3 : Tester la connexion SSH via IAP

```bash
# Connexion SSH via IAP (--tunnel-through-iap)
gcloud compute ssh vm-api-sa --zone=$ZONE --tunnel-through-iap

# Une fois connecté, vérifier que la VM n'a pas d'IP publique
curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/ \
    -H "Metadata-Flavor: Google" || echo "Pas d'IP publique"

exit
```

#### Exercice 8.7.4 : Tunnel TCP pour d'autres ports

```bash
# Créer un tunnel pour accéder à un service sur un port spécifique
# Exemple: Accéder à un service web interne sur le port 8080

gcloud compute start-iap-tunnel vm-api-sa 8080 \
    --zone=$ZONE \
    --local-host-port=localhost:8080 &

# Le service est maintenant accessible sur localhost:8080
# curl http://localhost:8080

# Tuer le tunnel
kill %1
```

#### Exercice 8.7.5 : Auditer les connexions IAP

```bash
# Consulter les logs d'accès IAP
gcloud logging read '
    protoPayload.serviceName="iap.googleapis.com" AND
    protoPayload.methodName="AuthorizeUser"
' --limit=10 --format="table(
    timestamp,
    protoPayload.authenticationInfo.principalEmail,
    protoPayload.resourceName,
    protoPayload.response.allowed
)"
```

---

## Lab 8.8 : Cloud IDS - Détection d'intrusion
**Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer un endpoint Cloud IDS
- Configurer le packet mirroring
- Analyser les alertes de sécurité

### Note importante
⚠️ Cloud IDS a un coût significatif (~$1.50/heure par endpoint). Pensez à le supprimer après le lab.

### Architecture Cloud IDS

```
                                    VPC
    ┌──────────────────────────────────────────────────────────────────┐
    │                                                                  │
    │   ┌─────────────────────────────────────────────────────────┐    │
    │   │              Subnet surveillé                           │    │
    │   │                                                         │    │
    │   │   ┌──────────┐     ┌──────────┐     ┌──────────┐        │    │
    │   │   │  VM-1    │     │  VM-2    │     │  VM-3    │        │    │
    │   │   └────┬─────┘     └────┬─────┘     └────┬─────┘        │    │
    │   │        │                │                │              │    │
    │   └────────┼────────────────┼────────────────┼──────────────┘    │
    │            │                │                │                   │
    │            └────────────────┼────────────────┘                   │
    │                             │                                    │
    │                    Packet Mirroring                              │
    │                    (copie du trafic)                             │
    │                             │                                    │
    │                             ▼                                    │
    │                    ┌────────────────┐                            │
    │                    │  Cloud IDS     │                            │
    │                    │  Endpoint      │                            │
    │                    │  (Palo Alto)   │                            │
    │                    └───────┬────────┘                            │
    │                            │                                     │
    └────────────────────────────┼─────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │    Cloud Logging       │
                    │    Security Command    │
                    │    Center              │
                    └────────────────────────┘
```

### Exercices

#### Exercice 8.8.1 : Activer l'API et créer l'endpoint IDS

```bash
# Activer l'API
gcloud services enable ids.googleapis.com

# Créer l'endpoint Cloud IDS
# Note: Cela peut prendre plusieurs minutes
gcloud ids endpoints create ids-endpoint-lab \
    --zone=$ZONE \
    --network=$VPC_NAME \
    --severity=INFORMATIONAL \
    --description="Endpoint IDS pour le lab" \
    --async

# Vérifier le statut
gcloud ids endpoints describe ids-endpoint-lab --zone=$ZONE

# Attendre que l'endpoint soit prêt (STATE: READY)
watch -n 30 "gcloud ids endpoints describe ids-endpoint-lab --zone=$ZONE --format='get(state)'"
```

#### Exercice 8.8.2 : Configurer le Packet Mirroring

```bash
# Récupérer l'URL du forwarding rule de l'endpoint
IDS_FORWARDING_RULE=$(gcloud ids endpoints describe ids-endpoint-lab \
    --zone=$ZONE \
    --format="get(endpointForwardingRule)")

# Créer la politique de packet mirroring
gcloud compute packet-mirrorings create mirror-to-ids \
    --region=$REGION \
    --network=$VPC_NAME \
    --collector-ilb=$IDS_FORWARDING_RULE \
    --mirrored-subnets=subnet-frontend,subnet-backend \
    --filter-cidr-ranges=0.0.0.0/0 \
    --filter-protocols=tcp,udp,icmp

# Vérifier la configuration
gcloud compute packet-mirrorings describe mirror-to-ids --region=$REGION
```

#### Exercice 8.8.3 : Générer du trafic de test

```bash
# Se connecter à une VM et générer du trafic
gcloud compute ssh vm-web-sa --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Génération de trafic de test ==="

# Trafic HTTP normal
curl -s http://example.com > /dev/null

# Scan de ports (devrait déclencher une alerte)
for port in 22 80 443 3306 5432; do
    nc -zv localhost $port -w 1 2>&1 || true
done

# Requête suspecte (pattern SQL injection dans URL)
curl -s "http://example.com/?id=1%20OR%201=1" > /dev/null 2>&1 || true

# Requête avec User-Agent suspect
curl -s -A "sqlmap/1.0" http://example.com > /dev/null 2>&1 || true

echo "Trafic de test généré"
EOF
```

#### Exercice 8.8.4 : Consulter les alertes Cloud IDS

```bash
# Consulter les alertes dans Cloud Logging
gcloud logging read 'resource.type="ids.googleapis.com/Endpoint"' \
    --limit=20 \
    --format=json

# Format plus lisible
gcloud logging read 'resource.type="ids.googleapis.com/Endpoint"' \
    --limit=10 \
    --format="table(
        timestamp,
        jsonPayload.threat_id,
        jsonPayload.name,
        jsonPayload.severity,
        jsonPayload.category,
        jsonPayload.source_ip_address,
        jsonPayload.destination_ip_address
    )"

# Filtrer par sévérité
gcloud logging read '
    resource.type="ids.googleapis.com/Endpoint" AND
    jsonPayload.severity="HIGH"
' --limit=10
```

#### Exercice 8.8.5 : Nettoyage (IMPORTANT)

```bash
# Supprimer le packet mirroring
gcloud compute packet-mirrorings delete mirror-to-ids \
    --region=$REGION --quiet

# Supprimer l'endpoint IDS
gcloud ids endpoints delete ids-endpoint-lab \
    --zone=$ZONE --quiet

echo "Cloud IDS nettoyé pour éviter les frais"
```

---

## Lab 8.9 : Secure Web Proxy - Filtrage egress
**Difficulté : ⭐⭐⭐**

### Objectifs
- Comprendre Secure Web Proxy
- Filtrer le trafic HTTP/HTTPS sortant
- Implémenter des politiques basées sur les domaines

### Note
⚠️ Secure Web Proxy est un service payant. Ce lab présente les concepts et commandes.

### Exercices

#### Exercice 8.9.1 : Comprendre Secure Web Proxy

Secure Web Proxy est un proxy cloud-native pour filtrer le trafic 
HTTP/HTTPS sortant des VMs.

Cas d'usage:
- Contrôler l'accès Internet des VMs
- Appliquer des politiques de sécurité sur le trafic sortant
- Visibilité sur les destinations web
- Conformité et audit
- Bloquer l'exfiltration de données

```
Architecture:
┌──────────────────────────────────────────────────────────────┐
│                           VPC                                │
│                                                              │
│   ┌──────────┐                    ┌──────────────────────┐   │
│   │   VM     │───── HTTP/S ──────►│  Secure Web Proxy    │   │
│   │          │     (via proxy)    │  10.0.10.100:443     │   │
│   └──────────┘                    └──────────┬───────────┘   │
│                                              │               │
└──────────────────────────────────────────────┼───────────────┘
                                               │
                                               ▼
                            ┌──────────────────────────────┐
                            │        Internet              │
                            │  (domaines autorisés only)   │
                            └──────────────────────────────┘

```
Fonctionnalités:
- Filtrage par URL et domaine
- Inspection TLS (décryptage/re-cryptage)
- Intégration avec Cloud Logging
- Politiques basées sur l'identité

#### Exercice 8.9.2 : Configuration conceptuelle

```bash
# Note: Ces commandes sont pour référence
# Le déploiement réel nécessite plus de configuration

# === Configuration Secure Web Proxy ===

# 1. Créer un sous-réseau dédié pour le proxy
gcloud compute networks subnets create subnet-proxy \
    --network=mon-vpc \
    --region=europe-west1 \
    --range=10.0.10.0/24 \
    --purpose=PRIVATE

# 2. Créer la politique de sécurité
gcloud network-security gateway-security-policies create swp-policy \
    --location=europe-west1

# 3. Ajouter des règles à la politique
# Autoriser Google
gcloud network-security gateway-security-policy-rules create allow-google \
    --gateway-security-policy=swp-policy \
    --location=europe-west1 \
    --priority=1000 \
    --basic-profile=ALLOW \
    --session-matcher='host().endsWith(".google.com") || host().endsWith(".googleapis.com")' \
    --description="Autoriser Google"

# Autoriser les mises à jour OS
gcloud network-security gateway-security-policy-rules create allow-updates \
    --gateway-security-policy=swp-policy \
    --location=europe-west1 \
    --priority=1100 \
    --basic-profile=ALLOW \
    --session-matcher='host().endsWith(".debian.org") || host().endsWith(".ubuntu.com")' \
    --description="Autoriser mises à jour OS"

# Bloquer tout le reste
gcloud network-security gateway-security-policy-rules create deny-all \
    --gateway-security-policy=swp-policy \
    --location=europe-west1 \
    --priority=65000 \
    --basic-profile=DENY \
    --session-matcher='true' \
    --description="Bloquer tout le reste"

# 4. Créer le gateway
gcloud network-services gateways create swp-gateway \
    --location=europe-west1 \
    --type=SECURE_WEB_GATEWAY \
    --network=mon-vpc \
    --subnetwork=subnet-proxy \
    --addresses=10.0.10.100 \
    --gateway-security-policy=swp-policy
```

#### Exercice 8.9.3 : Expressions de filtrage

=== Expressions de filtrage Secure Web Proxy ===

| Expression | Signification |
|------------|---------------|
| host() == "example.com" | Domaine exact |
| host().endsWith(".google.com") | Sous-domaines de google.com |
| host().startsWith("api.") | Domaines commençant par api. |
| request.path().startsWith("/api") | Chemin commençant par /api |
| request.method() == "POST" | Méthode POST uniquement |

Exemples de règles:

- Autoriser uniquement les APIs Google
--session-matcher='host().endsWith(".googleapis.com")'

- Bloquer les réseaux sociaux
--session-matcher='host().endsWith(".facebook.com") || host().endsWith(".twitter.com")'

- Autoriser uniquement certains chemins
--session-matcher='host() == "api.example.com" && request.path().startsWith("/v1/")'

#### Exercice 8.9.4 : Configuration des VMs pour utiliser le proxy

```bash
# === Configuration des VMs ===

# Sur chaque VM qui doit utiliser le proxy:

# Variables d'environnement (temporaire)
export HTTP_PROXY=http://10.0.10.100:443
export HTTPS_PROXY=http://10.0.10.100:443
export NO_PROXY=metadata.google.internal,169.254.169.254,10.0.0.0/8

# Configuration permanente (/etc/environment)
echo 'HTTP_PROXY=http://10.0.10.100:443' >> /etc/environment
echo 'HTTPS_PROXY=http://10.0.10.100:443' >> /etc/environment
echo 'NO_PROXY=metadata.google.internal,169.254.169.254,10.0.0.0/8' >> /etc/environment

# Pour apt (Debian/Ubuntu)
cat > /etc/apt/apt.conf.d/proxy.conf << PROXY
Acquire::http::Proxy "http://10.0.10.100:443";
Acquire::https::Proxy "http://10.0.10.100:443";
PROXY
```

Note: NO_PROXY est important pour ne pas proxifier:
- Le serveur de métadonnées GCP (169.254.169.254)
- Le trafic interne (10.0.0.0/8)

---

## Lab 8.10 : Bonnes pratiques et hardening
**Difficulté : ⭐⭐**

### Objectifs
- Appliquer les bonnes pratiques de sécurité réseau
- Auditer la configuration existante
- Créer une checklist de sécurité

### Exercices

#### Exercice 8.10.1 : Checklist de sécurité pare-feu

- ☐ Supprimer les règles default-allow-* du VPC default
- ☐ Utiliser des priorités cohérentes:
   - deny: 100-500 (priorité haute)
   - allow: 1000+ (priorité normale)
- ☐ Préférer Service Accounts aux tags en production
- ☐ Activer le logging sur les règles critiques
- ☐ Documenter chaque règle avec une description claire
- ☐ Réviser régulièrement les règles (trimestriel)
- ☐ Utiliser des Network Firewall Policies pour les règles globales
- ☐ Implémenter deny-all par défaut, puis autoriser explicitement

```bash
# Audit des règles sans description
echo "=== Règles sans description ==="
gcloud compute firewall-rules list \
    --format="table(name,description)" \
    --filter="description=''"

# Audit des règles autorisant tout depuis Internet
echo "=== Règles autorisant 0.0.0.0/0 ==="
gcloud compute firewall-rules list \
    --filter="sourceRanges:0.0.0.0/0 AND allowed:*" \
    --format="table(name,sourceRanges,allowed)"
```

#### Exercice 8.10.2 : Checklist architecture

- ☐ Segmenter par environnement (prod/dev/staging)
- ☐ Segmenter par fonction (frontend/backend/db)
- ☐ Utiliser des sous-réseaux privés (pas d'IP publiques)
- ☐ Implémenter Private Google Access pour les APIs
- ☐ Utiliser Cloud NAT pour l'accès Internet sortant
- ☐ Configurer IAP pour l'accès administrateur
- ☐ Implémenter VPC Service Controls pour les données sensibles
- ☐ Utiliser Shared VPC pour centraliser la gestion

# Audit des VMs avec IP publique
```bash
echo "=== VMs avec IP publique ==="
gcloud compute instances list \
    --format="table(name,zone,networkInterfaces[0].accessConfigs[0].natIP)" \
    --filter="networkInterfaces[0].accessConfigs[0].natIP:*"
```

#### Exercice 8.10.3 : Checklist surveillance

- ☐ Activer VPC Flow Logs sur les sous-réseaux sensibles
- ☐ Déployer Cloud IDS pour la détection des menaces
- ☐ Configurer des alertes sur les événements critiques
- ☐ Exporter les logs vers un SIEM (Chronicle, Splunk...)
- ☐ Auditer les accès IAM réseau périodiquement
- ☐ Monitorer les changements de configuration (Cloud Audit Logs)

# Vérifier si VPC Flow Logs est activé
```bash
echo "=== Statut VPC Flow Logs ==="
gcloud compute networks subnets list \
    --format="table(name,region,enableFlowLogs)"
```

#### Exercice 8.10.4 : Script d'audit de sécurité

```bash
#!/bin/bash
# Script d'audit de sécurité réseau

echo "=========================================="
echo "  AUDIT DE SÉCURITÉ RÉSEAU GCP"
echo "=========================================="

echo ""
echo "=== 1. Règles de pare-feu ouvertes à Internet ==="
gcloud compute firewall-rules list \
    --filter="sourceRanges:0.0.0.0/0 AND direction:INGRESS" \
    --format="table(name,network,allowed,priority)"

echo ""
echo "=== 2. VMs avec IP publique ==="
gcloud compute instances list \
    --filter="networkInterfaces[0].accessConfigs[0].natIP:*" \
    --format="table(name,zone,networkInterfaces[0].accessConfigs[0].natIP)"

echo ""
echo "=== 3. Sous-réseaux sans VPC Flow Logs ==="
gcloud compute networks subnets list \
    --filter="enableFlowLogs:false OR enableFlowLogs:null" \
    --format="table(name,region,enableFlowLogs)"

echo ""
echo "=== 4. Règles de pare-feu utilisant des tags ==="
gcloud compute firewall-rules list \
    --filter="targetTags:* OR sourceTags:*" \
    --format="table(name,targetTags,sourceTags)"

echo ""
echo "=== 5. Règles sans logging ==="
gcloud compute firewall-rules list \
    --filter="logConfig.enable:false OR -logConfig.enable:*" \
    --format="table(name,network,logConfig.enable)"

echo ""
echo "=========================================="
echo "  FIN DE L'AUDIT"
echo "=========================================="
```

---

## Lab 8.11 : Scénario intégrateur - Architecture sécurisée
**Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer une architecture sécurisée complète
- Combiner toutes les fonctionnalités de sécurité
- Documenter l'architecture

### Architecture cible

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                                ARCHITECTURE SÉCURISÉE                              │
│                                                                                    │
│  ┌──────────────────────────────────────────────────────────────────────────────┐  │
│  │                        Global Network Firewall Policy                        │  │
│  │   - Deny dangerous ports (23, 445, 3389 externe)                             │  │
│  │   - Allow Health Checks                                                      │  │
│  │   - Allow IAP                                                                │  │
│  └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                    │
│  ┌──────────────────────────────────────────────────────────────────────────────┐  │
│  │                               VPC Sécurisé                                   │  │
│  │                                                                              │  │
│  │   DMZ (subnet-dmz)              Backend (subnet-backend)                     │  │
│  │   10.0.1.0/24                   10.0.2.0/24                                  │  │
│  │   ┌─────────────────┐           ┌─────────────────────────────────┐          │  │
│  │   │                 │           │                                 │          │  │
│  │   │  ┌───────────┐  │   HTTP    │  ┌───────────┐  ┌───────────┐  │           │  │
│  │   │  │  Web (SA) │  │──────────►│  │  API (SA) │  │  DB (SA)  │  │           │  │
│  │   │  │  :80/:443 │  │  :8080    │  │  :8080    │──│  :5432    │  │           │  │
│  │   │  └───────────┘  │           │  └───────────┘  └───────────┘  │           │  │
│  │   │       ▲         │           │                                 │          │  │
│  │   └───────┼─────────┘           └─────────────────────────────────┘          │  │
│  │           │                                                                  │  │
│  │   Internet (via Load Balancer)                                               │  │
│  │                                                                              │  │
│  │   Règles de pare-feu:                                                        │  │
│  │   - LB → Web (SA): 80, 443                                                   │  │
│  │   - Web (SA) → API (SA): 8080                                                │  │
│  │   - API (SA) → DB (SA): 5432                                                 │  │
│  │   - IAP → All: 22                                                            │  │
│  │   - Deny all other                                                           │  │
│  │                                                                              │  │
│  │   Logging: Activé sur toutes les règles                                      │  │
│  │   VPC Flow Logs: Activé                                                      │  │
│  └──────────────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────────────┘
```

### Script de déploiement

```bash
#!/bin/bash
# Architecture sécurisée complète

set -e

export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-secure"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE SÉCURISÉE"
echo "=========================================="

# ===== 1. VPC et sous-réseaux =====
echo ">>> Création VPC..."
gcloud compute networks create $VPC_NAME --subnet-mode=custom

gcloud compute networks subnets create subnet-dmz \
    --network=$VPC_NAME --region=$REGION --range=10.0.1.0/24 \
    --enable-flow-logs --logging-flow-sampling=1.0

gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME --region=$REGION --range=10.0.2.0/24 \
    --enable-flow-logs --logging-flow-sampling=1.0 \
    --enable-private-ip-google-access

# ===== 2. Service Accounts =====
echo ">>> Création Service Accounts..."
for SA in web api db; do
    gcloud iam service-accounts create sa-${SA}-secure \
        --display-name="SA ${SA} - Secure Architecture"
done

# ===== 3. Global Network Firewall Policy =====
echo ">>> Création Global Network Firewall Policy..."
gcloud compute network-firewall-policies create secure-global-policy --global

# Deny dangerous ports
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=deny \
    --layer4-configs=tcp:23,tcp:445,tcp:3389 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Deny dangerous ports"

# Allow Health Checks
gcloud compute network-firewall-policies rules create 200 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=allow \
    --layer4-configs=tcp:80,tcp:443,tcp:8080 \
    --src-ip-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Allow Health Checks"

# Allow IAP
gcloud compute network-firewall-policies rules create 300 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=allow \
    --layer4-configs=tcp:22 \
    --src-ip-ranges=35.235.240.0/20 \
    --description="Allow IAP SSH"

# Associer au VPC
gcloud compute network-firewall-policies associations create \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --network=$VPC_NAME --name=assoc-secure

# ===== 4. VPC Firewall Rules (Service Accounts) =====
echo ">>> Création règles pare-feu..."

# HTTP vers Web
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-to-web \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-service-accounts=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="HTTP/S vers Web"

# Web vers API
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="Web vers API"

# API vers DB
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:5432 \
    --source-service-accounts=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-db-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="API vers DB"

# Deny all egress (mode strict)
gcloud compute firewall-rules create ${VPC_NAME}-deny-all-egress \
    --network=$VPC_NAME --direction=EGRESS --action=DENY \
    --rules=all --destination-ranges=0.0.0.0/0 \
    --priority=65000 --enable-logging \
    --description="Deny all egress"

# Allow egress Google APIs
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME --direction=EGRESS --action=ALLOW \
    --rules=tcp:443 \
    --destination-ranges=199.36.153.8/30,199.36.153.4/30 \
    --priority=1000 \
    --description="Allow Google APIs"

# Allow egress internal
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-internal \
    --network=$VPC_NAME --direction=EGRESS --action=ALLOW \
    --rules=all --destination-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Allow internal egress"

# ===== 5. VMs =====
echo ">>> Création VMs..."

gcloud compute instances create vm-web-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-dmz \
    --service-account=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y nginx'

gcloud compute instances create vm-api-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-backend \
    --service-account=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud

gcloud compute instances create vm-db-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-backend \
    --service-account=sa-db-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud

echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""
echo "Architecture déployée avec:"
echo "- VPC Flow Logs activés"
echo "- Network Firewall Policy globale"
echo "- Règles basées sur Service Accounts"
echo "- Logging sur toutes les règles"
echo "- Pas d'IP publiques sur les VMs"
echo "- Egress restreint"
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage Module 8

echo "=== Suppression des VMs ==="
for VM in vm-web vm-api vm-db vm-web-sa vm-api-sa vm-db-sa vm-web-secure vm-api-secure vm-db-secure; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des Service Accounts ==="
for SA in sa-web sa-api sa-db sa-web-secure sa-api-secure sa-db-secure; do
    gcloud iam service-accounts delete ${SA}@${PROJECT_ID}.iam.gserviceaccount.com --quiet 2>/dev/null
done

echo "=== Suppression des Network Firewall Policies ==="
for POLICY in global-security-policy secure-global-policy europe-policy; do
    gcloud compute network-firewall-policies delete $POLICY --global --quiet 2>/dev/null
    gcloud compute network-firewall-policies delete $POLICY --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-security-lab vpc-secure; do
    for RULE in $(gcloud compute firewall-rules list --filter="network:$VPC" --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
    done
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-frontend subnet-backend subnet-dmz; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in vpc-security-lab vpc-secure; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Suppression des rôles personnalisés ==="
gcloud iam roles delete NetworkViewerCustom --project=$PROJECT_ID --quiet 2>/dev/null

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 8

### Règles de pare-feu VPC
```bash
# Créer
gcloud compute firewall-rules create NAME --network=VPC --direction=INGRESS|EGRESS \
    --action=ALLOW|DENY --rules=PROTOCOL:PORT --source-ranges=CIDR --priority=N

# Avec Service Accounts
--source-service-accounts=SA@PROJECT.iam.gserviceaccount.com
--target-service-accounts=SA@PROJECT.iam.gserviceaccount.com

# Avec logging
--enable-logging --logging-metadata=INCLUDE_ALL_METADATA
```

### Network Firewall Policies
```bash
# Créer politique globale
gcloud compute network-firewall-policies create NAME --global

# Ajouter règle
gcloud compute network-firewall-policies rules create PRIORITY --firewall-policy=NAME \
    --global-firewall-policy --direction=INGRESS --action=allow|deny|goto_next \
    --layer4-configs=PROTOCOL:PORT --src-ip-ranges=CIDR

# Associer au VPC
gcloud compute network-firewall-policies associations create --firewall-policy=NAME \
    --global-firewall-policy --network=VPC
```

### Cloud IDS
```bash
# Créer endpoint
gcloud ids endpoints create NAME --zone=ZONE --network=VPC --severity=LEVEL

# Packet mirroring
gcloud compute packet-mirrorings create NAME --region=REGION --network=VPC \
    --collector-ilb=ILB --mirrored-subnets=SUBNET
```
