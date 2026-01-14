# Module 4 - Partage de réseaux VPC
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Configurer et gérer le VPC Peering entre différents projets
- Comprendre l'architecture et les rôles IAM du Shared VPC
- Maîtriser la non-transitivité du peering et ses solutions
- Choisir la bonne solution selon le contexte
- Appliquer les bonnes pratiques de sécurité

### Prérequis
- Modules 1 à 3 complétés
- Pour les labs VPC Peering : 2 projets GCP (ou simulation dans un seul projet)
- Pour Shared VPC : Organisation GCP (ou mode simulation/démonstration)
- Droits : roles/compute.networkAdmin, roles/compute.xpnAdmin (pour Shared VPC)

### Note importante sur Shared VPC
⚠️ **Shared VPC nécessite une organisation GCP**. Les labs Shared VPC sont présentés de deux façons :
- **Mode simulation** : Exercices pratiques simulant l'architecture sans organisation
- **Mode organisation** : Commandes réelles pour ceux qui ont accès à une organisation

### Labs proposés

| Lab | Titre | Difficulté | Prérequis |
|-----|-------|------------|-----------|
| 4.1 | VPC Peering - Configuration de base | ⭐⭐ | 2 VPC |
| 4.2 | VPC Peering - Options avancées et routes | ⭐⭐ | Lab 4.1 |
| 4.3 | VPC Peering - Non-transitivité et solutions | ⭐⭐⭐ | Lab 4.1 |
| 4.4 | Shared VPC - Architecture et rôles IAM | ⭐⭐ | Organisation GCP |
| 4.5 | Shared VPC - Configuration complète | ⭐⭐⭐ | Organisation GCP |
| 4.6 | Shared VPC - Simulation sans organisation | ⭐⭐ | 1 projet |
| 4.7 | Règles de pare-feu dans les réseaux partagés | ⭐⭐ | Labs précédents |
| 4.8 | Scénario : Choisir entre Shared VPC et Peering | ⭐⭐ | Conceptuel |
| 4.9 | Architecture hybride : Shared VPC + Peering | ⭐⭐⭐ | Tous les labs |

---

## Lab 4.1 : VPC Peering - Configuration de base
**Difficulté : ⭐⭐**

### Objectifs
- Créer un peering VPC entre deux réseaux
- Comprendre le processus bidirectionnel
- Tester la connectivité entre VPC peerés

### Architecture cible

```
    Projet A (ou VPC-A)                    Projet B (ou VPC-B)
    ┌─────────────────────┐                ┌─────────────────────┐
    │     vpc-alpha       │                │     vpc-beta        │
    │   10.10.0.0/16      │                │   10.20.0.0/16      │
    │                     │    Peering     │                     │
    │  ┌───────────────┐  │◄──────────────►│  ┌───────────────┐  │
    │  │ subnet-alpha  │  │                │  │  subnet-beta  │  │
    │  │ 10.10.1.0/24  │  │                │  │ 10.20.1.0/24  │  │
    │  │               │  │                │  │               │  │
    │  │  ┌─────────┐  │  │                │  │  ┌─────────┐  │  │
    │  │  │ vm-alpha│  │  │                │  │  │ vm-beta │  │  │
    │  │  │10.10.1.10│ │  │                │  │  │10.20.1.10│ │  │
    │  │  └─────────┘  │  │                │  │  └─────────┘  │  │
    │  └───────────────┘  │                │  └───────────────┘  │
    └─────────────────────┘                └─────────────────────┘
```

### Exercices

#### Exercice 4.1.1 : Créer les deux VPC

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Note: Si vous avez 2 projets, utilisez PROJECT_A et PROJECT_B
# Sinon, nous créons 2 VPC dans le même projet (simulation)

export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer VPC Alpha
gcloud compute networks create $VPC_ALPHA \
    --subnet-mode=custom \
    --description="VPC Alpha pour peering lab"

gcloud compute networks subnets create subnet-alpha \
    --network=$VPC_ALPHA \
    --region=$REGION \
    --range=10.10.1.0/24

# Créer VPC Beta
gcloud compute networks create $VPC_BETA \
    --subnet-mode=custom \
    --description="VPC Beta pour peering lab"

gcloud compute networks subnets create subnet-beta \
    --network=$VPC_BETA \
    --region=$REGION \
    --range=10.20.1.0/24

# Vérifier
gcloud compute networks list
```

#### Exercice 4.1.2 : Déployer les VMs de test

```bash
# Règles de pare-feu pour chaque VPC
# VPC Alpha
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-internal \
    --network=$VPC_ALPHA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_ALPHA}-allow-ssh-iap \
    --network=$VPC_ALPHA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# VPC Beta
gcloud compute firewall-rules create ${VPC_BETA}-allow-internal \
    --network=$VPC_BETA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_BETA}-allow-ssh-iap \
    --network=$VPC_BETA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# VM dans VPC Alpha
gcloud compute instances create vm-alpha \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_ALPHA \
    --subnet=subnet-alpha \
    --private-network-ip=10.10.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# VM dans VPC Beta
gcloud compute instances create vm-beta \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_BETA \
    --subnet=subnet-beta \
    --private-network-ip=10.20.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 4.1.3 : Tester AVANT le peering

```bash
# Se connecter à vm-alpha
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap

# Tenter de ping vm-beta (devrait échouer)
ping -c 3 10.20.1.10
# Résultat attendu: Network unreachable ou timeout

exit
```

**Question :** Pourquoi le ping échoue-t-il ?

#### Exercice 4.1.4 : Créer le peering VPC

```bash
# IMPORTANT: Le peering doit être configuré DES DEUX CÔTÉS

# Côté VPC Alpha → VPC Beta
gcloud compute networks peerings create peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --peer-network=$VPC_BETA \
    --peer-project=$PROJECT_ID

# Vérifier le statut (devrait être INACTIVE)
gcloud compute networks peerings list --network=$VPC_ALPHA

# Côté VPC Beta → VPC Alpha
gcloud compute networks peerings create peering-beta-to-alpha \
    --network=$VPC_BETA \
    --peer-network=$VPC_ALPHA \
    --peer-project=$PROJECT_ID

# Vérifier le statut (devrait maintenant être ACTIVE des deux côtés)
gcloud compute networks peerings list --network=$VPC_ALPHA
gcloud compute networks peerings list --network=$VPC_BETA
```

**Questions :**
1. Que se passe-t-il si on ne configure le peering que d'un seul côté ?
2. Quel est le statut du peering avant la configuration bilatérale ?

#### Exercice 4.1.5 : Vérifier les routes échangées

```bash
# Voir les routes dans VPC Alpha (inclut maintenant les routes de VPC Beta)
gcloud compute routes list --filter="network=$VPC_ALPHA"

# Voir les routes dans VPC Beta
gcloud compute routes list --filter="network=$VPC_BETA"

# Détails du peering
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA
```

**Question :** Quelles nouvelles routes apparaissent après le peering ?

#### Exercice 4.1.6 : Tester APRÈS le peering

```bash
# Se connecter à vm-alpha
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap

# Ping vm-beta (devrait fonctionner maintenant)
ping -c 5 10.20.1.10

# Traceroute
traceroute -n 10.20.1.10

exit

# Tester dans l'autre sens (depuis vm-beta)
gcloud compute ssh vm-beta --zone=$ZONE --tunnel-through-iap

ping -c 5 10.10.1.10

exit
```

**Questions :**
1. Combien de sauts montre le traceroute ?
2. Le trafic passe-t-il par Internet ?

---

## Lab 4.2 : VPC Peering - Options avancées et routes
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre l'export/import des routes personnalisées
- Configurer les options avancées du peering
- Gérer les routes dans un environnement peeré

### Exercices

#### Exercice 4.2.1 : Créer des routes personnalisées

```bash
# Créer une route personnalisée dans VPC Alpha (vers un réseau fictif)
gcloud compute routes create custom-route-alpha \
    --network=$VPC_ALPHA \
    --destination-range=192.168.100.0/24 \
    --next-hop-instance=vm-alpha \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

# Vérifier que la route existe dans VPC Alpha
gcloud compute routes list --filter="network=$VPC_ALPHA"
```

#### Exercice 4.2.2 : Vérifier si la route est exportée par défaut

```bash
# Vérifier les routes dans VPC Beta
gcloud compute routes list --filter="network=$VPC_BETA"

# La route custom-route-alpha n'apparaît PAS dans VPC Beta
# Car l'export des routes personnalisées est désactivé par défaut
```

#### Exercice 4.2.3 : Activer l'export/import des routes personnalisées

```bash
# Mettre à jour le peering côté Alpha pour EXPORTER les routes
gcloud compute networks peerings update peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --export-custom-routes

# Mettre à jour le peering côté Beta pour IMPORTER les routes
gcloud compute networks peerings update peering-beta-to-alpha \
    --network=$VPC_BETA \
    --import-custom-routes

# Vérifier la configuration
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --format="yaml(exportCustomRoutes,importCustomRoutes)"

gcloud compute networks peerings describe peering-beta-to-alpha \
    --network=$VPC_BETA \
    --format="yaml(exportCustomRoutes,importCustomRoutes)"
```

#### Exercice 4.2.4 : Vérifier que la route est maintenant visible

```bash
# Vérifier les routes dans VPC Beta (la route custom devrait apparaître)
gcloud compute routes list --filter="network=$VPC_BETA"

# La route 192.168.100.0/24 devrait maintenant être visible avec un tag "peering"
```

**Questions :**
1. Pourquoi l'export des routes personnalisées est-il désactivé par défaut ?
2. Dans quel scénario activeriez-vous l'export/import des routes ?

#### Exercice 4.2.5 : Comprendre les routes avec IP publiques

```bash
# Vérifier les options pour les routes avec IP publiques
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --format="yaml(exportSubnetRoutesWithPublicIp,importSubnetRoutesWithPublicIp)"

# Par défaut, ces options sont activées
# Elles concernent les plages secondaires (GKE) qui peuvent avoir des IPs publiques
```

#### Exercice 4.2.6 : Documenter la configuration du peering

```bash
# Script pour documenter tous les peerings d'un projet
cat << 'EOF' > document_peerings.sh
#!/bin/bash
echo "=== Documentation des VPC Peerings ==="
echo ""

for VPC in $(gcloud compute networks list --format="get(name)"); do
    echo "VPC: $VPC"
    echo "---"
    gcloud compute networks peerings list --network=$VPC \
        --format="table(name,peerNetwork,state,exportCustomRoutes,importCustomRoutes)"
    echo ""
done
EOF

chmod +x document_peerings.sh
./document_peerings.sh
```

---

## Lab 4.3 : VPC Peering - Non-transitivité et solutions
**Difficulté : ⭐⭐⭐**

### Objectifs
- Démontrer la non-transitivité du peering
- Explorer les solutions pour la connectivité transitive
- Implémenter un routage via appliance

### Architecture cible

```
                        VPC-Alpha                VPC-Beta                VPC-Gamma
                      10.10.0.0/16            10.20.0.0/16            10.30.0.0/16
                    ┌─────────────┐          ┌─────────────┐          ┌─────────────┐
                    │             │          │             │          │             │
                    │  ┌───────┐  │ Peering  │  ┌───────┐  │ Peering  │  ┌───────┐  │
                    │  │vm-alpha│ │◄────────►│  │vm-beta│  │◄────────►│  │vm-gamma│ │
                    │  └───────┘  │          │  └───────┘  │          │  └───────┘  │
                    │             │          │             │          │             │
                    └─────────────┘          └─────────────┘          └─────────────┘
                           │                                                │
                           │          Pas de connectivité directe           │
                           └───────────────── ✗ ────────────────────────────┘
```

### Exercices

#### Exercice 4.3.1 : Créer un troisième VPC

```bash
# Créer VPC Gamma
export VPC_GAMMA="vpc-gamma"

gcloud compute networks create $VPC_GAMMA \
    --subnet-mode=custom \
    --description="VPC Gamma pour démontrer la non-transitivité"

gcloud compute networks subnets create subnet-gamma \
    --network=$VPC_GAMMA \
    --region=$REGION \
    --range=10.30.1.0/24

# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_GAMMA}-allow-internal \
    --network=$VPC_GAMMA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_GAMMA}-allow-ssh-iap \
    --network=$VPC_GAMMA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# VM dans VPC Gamma
gcloud compute instances create vm-gamma \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_GAMMA \
    --subnet=subnet-gamma \
    --private-network-ip=10.30.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 4.3.2 : Créer le peering Beta ↔ Gamma

```bash
# Peering Beta → Gamma
gcloud compute networks peerings create peering-beta-to-gamma \
    --network=$VPC_BETA \
    --peer-network=$VPC_GAMMA \
    --peer-project=$PROJECT_ID

# Peering Gamma → Beta
gcloud compute networks peerings create peering-gamma-to-beta \
    --network=$VPC_GAMMA \
    --peer-network=$VPC_BETA \
    --peer-project=$PROJECT_ID

# Vérifier
gcloud compute networks peerings list --network=$VPC_BETA
gcloud compute networks peerings list --network=$VPC_GAMMA
```

#### Exercice 4.3.3 : Démontrer la non-transitivité

```bash
# Tester la connectivité Alpha → Beta (fonctionne)
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Beta ==="
ping -c 3 10.20.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

# Tester la connectivité Beta → Gamma (fonctionne)
gcloud compute ssh vm-beta --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Beta → Gamma ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

# Tester la connectivité Alpha → Gamma (ÉCHOUE - non transitif)
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Gamma (via Beta) ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED - NON TRANSITIF"
EOF
```

**Question :** Pourquoi Alpha ne peut-il pas atteindre Gamma alors que Alpha↔Beta et Beta↔Gamma sont peerés ?

#### Exercice 4.3.4 : Solution 1 - Peering direct Alpha ↔ Gamma

```bash
# Créer un peering direct entre Alpha et Gamma
gcloud compute networks peerings create peering-alpha-to-gamma \
    --network=$VPC_ALPHA \
    --peer-network=$VPC_GAMMA \
    --peer-project=$PROJECT_ID

gcloud compute networks peerings create peering-gamma-to-alpha \
    --network=$VPC_GAMMA \
    --peer-network=$VPC_ALPHA \
    --peer-project=$PROJECT_ID

# Tester la connectivité Alpha → Gamma (fonctionne maintenant)
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Gamma (direct) ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

# Compter les peerings de chaque VPC
echo "Peerings de VPC Alpha:"
gcloud compute networks peerings list --network=$VPC_ALPHA --format="value(name)" | wc -l

echo "Peerings de VPC Beta:"
gcloud compute networks peerings list --network=$VPC_BETA --format="value(name)" | wc -l

echo "Peerings de VPC Gamma:"
gcloud compute networks peerings list --network=$VPC_GAMMA --format="value(name)" | wc -l
```

**Question :** Avec 4 VPC en full mesh, combien de peerings faut-il créer ?

#### Exercice 4.3.5 : Comprendre les limites du full mesh

```bash
# Calculer le nombre de peerings pour un full mesh
# Formule : n × (n-1) / 2 connexions, mais chaque connexion = 2 peerings
# Donc : n × (n-1) peerings au total
```
=== Limites du Full Mesh ===

| Nombre de VPC | Peerings par VPC | Total peerings |
|---------------|------------------|----------------|
| 3             | 2                | 6              |
| 5             | 4                | 20             |
| 10            | 9                | 90             |
| 25            | 24               | 600            |
| 26            | 25               | 650 ⚠️ LIMITE ATTEINTE |

Avec la limite de 25 peerings par VPC, le full mesh ne fonctionne que jusqu'à 26 VPC.
Pour plus de VPC, il faut une architecture hub-and-spoke avec transit.

#### Exercice 4.3.6 : Solution 2 - Transit via une appliance (Hub)

```bash
# Supprimer le peering direct Alpha ↔ Gamma pour simuler le scénario hub-and-spoke
gcloud compute networks peerings delete peering-alpha-to-gamma \
    --network=$VPC_ALPHA --quiet
gcloud compute networks peerings delete peering-gamma-to-alpha \
    --network=$VPC_GAMMA --quiet

# Transformer vm-beta en routeur/hub
gcloud compute instances add-metadata vm-beta \
    --zone=$ZONE \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'

# Activer IP forwarding sur vm-beta
gcloud compute instances stop vm-beta --zone=$ZONE --quiet
gcloud compute instances set-machine-type vm-beta \
    --zone=$ZONE \
    --machine-type=e2-small  # Besoin d'un peu plus de puissance

# Note: can-ip-forward doit être défini à la création
# Recréer vm-beta avec can-ip-forward
gcloud compute instances delete vm-beta --zone=$ZONE --quiet

gcloud compute instances create vm-beta \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_BETA \
    --subnet=subnet-beta \
    --private-network-ip=10.20.1.10 \
    --no-address \
    --can-ip-forward \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y iptables'
```

#### Exercice 4.3.7 : Configurer le routage via le hub

```bash
# Activer l'export des routes personnalisées sur les peerings
gcloud compute networks peerings update peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --export-custom-routes

gcloud compute networks peerings update peering-beta-to-alpha \
    --network=$VPC_BETA \
    --import-custom-routes \
    --export-custom-routes

gcloud compute networks peerings update peering-beta-to-gamma \
    --network=$VPC_BETA \
    --import-custom-routes \
    --export-custom-routes

gcloud compute networks peerings update peering-gamma-to-beta \
    --network=$VPC_GAMMA \
    --import-custom-routes

# Route dans VPC Alpha vers Gamma via vm-beta
gcloud compute routes create route-alpha-to-gamma-via-beta \
    --network=$VPC_ALPHA \
    --destination-range=10.30.0.0/16 \
    --next-hop-instance=vm-beta \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

# Route dans VPC Gamma vers Alpha via vm-beta
gcloud compute routes create route-gamma-to-alpha-via-beta \
    --network=$VPC_GAMMA \
    --destination-range=10.10.0.0/16 \
    --next-hop-instance=vm-beta \
    --next-hop-instance-zone=$ZONE \
    --priority=1000
```

**Note :** Cette configuration est complexe et nécessite que vm-beta soit dans le chemin réseau. En production, utilisez Network Connectivity Center pour un transit managé.

---

## Lab 4.4 : Shared VPC - Architecture et rôles IAM
**Difficulté : ⭐⭐**

### ⚠️ Prérequis : Organisation GCP
Ce lab nécessite une organisation GCP. Sans organisation, consultez le Lab 4.6 pour une simulation.

### Objectifs
- Comprendre l'architecture Shared VPC
- Maîtriser les rôles IAM nécessaires
- Planifier une architecture Shared VPC

### Exercices

#### Exercice 4.4.1 : Vérifier l'appartenance à une organisation

```bash
# Vérifier si le projet appartient à une organisation
gcloud projects describe $PROJECT_ID \
    --format="get(parent.type,parent.id)"

# Si le résultat montre "organization" et un ID, vous avez une organisation
# Si c'est vide ou "folder", vérifiez la structure

# Lister les organisations accessibles
gcloud organizations list

# Définir l'organisation
export ORG_ID=$(gcloud organizations list --format="get(name)" | head -1 | cut -d'/' -f2)
echo "Organisation ID: $ORG_ID"
```

#### Exercice 4.4.2 : Comprendre les rôles IAM Shared VPC

```bash
# Lister les rôles liés au Shared VPC
gcloud iam roles list --filter="name:compute.xpn" --format="table(name,title)"

# Détails de chaque rôle
echo "=== compute.xpnAdmin ==="
gcloud iam roles describe roles/compute.xpnAdmin

echo "=== compute.networkAdmin ==="
gcloud iam roles describe roles/compute.networkAdmin

echo "=== compute.networkUser ==="
gcloud iam roles describe roles/compute.networkUser
```

#### Exercice 4.4.3 : Cartographier les personas et rôles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MATRICE DES RÔLES SHARED VPC                         │
├─────────────────────┬───────────────────┬───────────────────────────────────┤
│ Persona             │ Rôle IAM          │ Portée                            │
├─────────────────────┼───────────────────┼───────────────────────────────────┤
│ Admin Organisation  │ compute.xpnAdmin  │ Organisation ou Dossier           │
│                     │                   │ - Active/désactive Shared VPC     │
│                     │                   │ - Associe les projets de service  │
├─────────────────────┼───────────────────┼───────────────────────────────────┤
│ Admin Réseau        │ compute.          │ Projet hôte                       │
│                     │ networkAdmin      │ - Crée/gère VPC et sous-réseaux   │
│                     │                   │ - Configure les routes            │
├─────────────────────┼───────────────────┼───────────────────────────────────┤
│ Admin Sécurité      │ compute.          │ Projet hôte                       │
│                     │ securityAdmin     │ - Gère les règles de pare-feu     │
├─────────────────────┼───────────────────┼───────────────────────────────────┤
│ Développeur         │ compute.          │ Sous-réseaux spécifiques          │
│                     │ networkUser       │ - Utilise les sous-réseaux        │
│                     │                   │ - Crée des VMs dans ces subnets   │
├─────────────────────┼───────────────────┼───────────────────────────────────┤
│ Service Account     │ compute.          │ Sous-réseaux spécifiques          │
│ (GKE, Cloud Run...) │ networkUser       │ - Permet aux services managés     │
│                     │                   │   d'utiliser le réseau partagé    │
└─────────────────────┴───────────────────┴───────────────────────────────────┘
```

#### Exercice 4.4.4 : Planifier l'architecture Shared VPC

=== Template de planification ===
=== Plan d'Architecture Shared VPC ===

1. Projet Hôte
- Nom: network-host-prod
- Usage: Héberge le VPC partagé (aucune workload applicative)

2. Projets de Service

| Projet            | Équipe | Environnement  | Sous-réseaux autorisés |
|-------------------|--------|----------------|------------------------|
| app-frontend-prod | Web    | Production     | subnet-frontend-prod   |
| app-backend-prod  | API    | Production     | subnet-backend-prod    |
| app-data-prod     | Data   | Production     | subnet-data-prod       |
| app-dev           | DevOps | Développement  | subnet-dev             |

3. Sous-réseaux

| Sous-réseau         | Région        | Plage IP       | Usage                  |
|---------------------|---------------|----------------|------------------------|
| subnet-frontend-prod| europe-west1  | 10.100.0.0/24  | Frontend web           |
| subnet-backend-prod | europe-west1  | 10.100.1.0/24  | APIs backend           |
| subnet-data-prod    | europe-west1  | 10.100.2.0/24  | Bases de données       |
| subnet-dev          | europe-west1  | 10.200.0.0/24  | Environnement dev      |
| subnet-gke-nodes    | europe-west1  | 10.100.10.0/24 | Nœuds GKE              |
| subnet-gke-pods     | europe-west1  | 10.101.0.0/16  | Pods GKE (secondaire)  |
| subnet-gke-services | europe-west1  | 10.102.0.0/20  | Services GKE (secondaire) |

4. Attribution des Rôles

| Utilisateur/Groupe         | Rôle                    | Portée             |
|----------------------------|-------------------------|--------------------|
| network-admins@company.com | compute.xpnAdmin        | Organisation       |
| network-admins@company.com | compute.networkAdmin    | network-host-prod  |
| security-team@company.com  | compute.securityAdmin   | network-host-prod  |
| frontend-devs@company.com  | compute.networkUser     | subnet-frontend-prod |
| backend-devs@company.com   | compute.networkUser     | subnet-backend-prod  |
| data-team@company.com      | compute.networkUser     | subnet-data-prod     |

---

## Lab 4.5 : Shared VPC - Configuration complète
**Difficulté : ⭐⭐⭐**

### ⚠️ Prérequis : Organisation GCP et rôle compute.xpnAdmin

### Objectifs
- Configurer un Shared VPC de bout en bout
- Associer des projets de service
- Déployer des ressources dans les projets de service

### Exercices

#### Exercice 4.5.1 : Créer les projets (si nécessaire)

```bash
# Variables
export ORG_ID="YOUR_ORG_ID"
export BILLING_ACCOUNT="YOUR_BILLING_ACCOUNT"
export HOST_PROJECT="network-host-$(date +%Y%m%d)"
export SERVICE_PROJECT_1="service-frontend-$(date +%Y%m%d)"
export SERVICE_PROJECT_2="service-backend-$(date +%Y%m%d)"

# Créer le projet hôte
gcloud projects create $HOST_PROJECT \
    --organization=$ORG_ID \
    --name="Network Host Project"

gcloud billing projects link $HOST_PROJECT \
    --billing-account=$BILLING_ACCOUNT

# Créer les projets de service
gcloud projects create $SERVICE_PROJECT_1 \
    --organization=$ORG_ID \
    --name="Service Frontend"

gcloud billing projects link $SERVICE_PROJECT_1 \
    --billing-account=$BILLING_ACCOUNT

gcloud projects create $SERVICE_PROJECT_2 \
    --organization=$ORG_ID \
    --name="Service Backend"

gcloud billing projects link $SERVICE_PROJECT_2 \
    --billing-account=$BILLING_ACCOUNT

# Activer les APIs nécessaires
for PROJECT in $HOST_PROJECT $SERVICE_PROJECT_1 $SERVICE_PROJECT_2; do
    gcloud services enable compute.googleapis.com --project=$PROJECT
done
```

#### Exercice 4.5.2 : Configurer le projet hôte

```bash
# Activer Shared VPC sur le projet hôte
gcloud compute shared-vpc enable $HOST_PROJECT

# Vérifier l'activation
gcloud compute shared-vpc organizations list-host-projects \
    --organization=$ORG_ID

# Créer le VPC partagé dans le projet hôte
gcloud compute networks create shared-vpc \
    --project=$HOST_PROJECT \
    --subnet-mode=custom

# Créer les sous-réseaux
gcloud compute networks subnets create subnet-frontend \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --region=europe-west1 \
    --range=10.100.0.0/24 \
    --enable-private-ip-google-access

gcloud compute networks subnets create subnet-backend \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --region=europe-west1 \
    --range=10.100.1.0/24 \
    --enable-private-ip-google-access
```

#### Exercice 4.5.3 : Associer les projets de service

```bash
# Associer le projet frontend
gcloud compute shared-vpc associated-projects add $SERVICE_PROJECT_1 \
    --host-project=$HOST_PROJECT

# Associer le projet backend
gcloud compute shared-vpc associated-projects add $SERVICE_PROJECT_2 \
    --host-project=$HOST_PROJECT

# Vérifier les associations
gcloud compute shared-vpc list-associated-resources $HOST_PROJECT
```

#### Exercice 4.5.4 : Configurer les permissions IAM

```bash
# Obtenir les service accounts des projets de service
export SA_FRONTEND=$(gcloud projects describe $SERVICE_PROJECT_1 \
    --format="get(projectNumber)")@cloudservices.gserviceaccount.com
export SA_BACKEND=$(gcloud projects describe $SERVICE_PROJECT_2 \
    --format="get(projectNumber)")@cloudservices.gserviceaccount.com

echo "Service Account Frontend: $SA_FRONTEND"
echo "Service Account Backend: $SA_BACKEND"

# Donner les permissions sur les sous-réseaux spécifiques
# Frontend → subnet-frontend uniquement
gcloud compute networks subnets add-iam-policy-binding subnet-frontend \
    --project=$HOST_PROJECT \
    --region=europe-west1 \
    --member="serviceAccount:$SA_FRONTEND" \
    --role="roles/compute.networkUser"

# Backend → subnet-backend uniquement
gcloud compute networks subnets add-iam-policy-binding subnet-backend \
    --project=$HOST_PROJECT \
    --region=europe-west1 \
    --member="serviceAccount:$SA_BACKEND" \
    --role="roles/compute.networkUser"
```

#### Exercice 4.5.5 : Créer les règles de pare-feu centralisées

```bash
# Règles de pare-feu dans le projet hôte
gcloud compute firewall-rules create shared-vpc-allow-internal \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp,udp,icmp \
    --source-ranges=10.100.0.0/16 \
    --description="Autoriser trafic interne"

gcloud compute firewall-rules create shared-vpc-allow-ssh-iap \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH via IAP"

gcloud compute firewall-rules create shared-vpc-allow-health-checks \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp:80,tcp:443,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Health checks Google"
```

#### Exercice 4.5.6 : Déployer des ressources dans les projets de service

```bash
# VM dans le projet frontend (utilisant le sous-réseau partagé)
gcloud compute instances create vm-frontend \
    --project=$SERVICE_PROJECT_1 \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --subnet=projects/$HOST_PROJECT/regions/europe-west1/subnetworks/subnet-frontend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# VM dans le projet backend
gcloud compute instances create vm-backend \
    --project=$SERVICE_PROJECT_2 \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --subnet=projects/$HOST_PROJECT/regions/europe-west1/subnetworks/subnet-backend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 4.5.7 : Tester la connectivité

```bash
# Se connecter à vm-frontend et ping vm-backend
gcloud compute ssh vm-frontend \
    --project=$SERVICE_PROJECT_1 \
    --zone=europe-west1-b \
    --tunnel-through-iap << 'EOF'
echo "=== Test de connectivité vers backend ==="
ping -c 5 10.100.1.2  # IP de vm-backend
EOF
```

---

## Lab 4.6 : Shared VPC - Simulation sans organisation
**Difficulté : ⭐⭐**

### Objectifs
- Simuler l'architecture Shared VPC dans un seul projet
- Comprendre les concepts sans organisation GCP
- Pratiquer la séparation des responsabilités
- Configurer Cloud NAT pour l'accès sortant sécurisé

### Architecture simulée

```
                    Projet Unique (simule Hôte + Services)
    ┌─────────────────────────────────────────────────────────────────────┐
    │                          shared-vpc                                 │
    │                                                                     │
    │   subnet-frontend                          subnet-backend           │
    │   10.100.0.0/24                           10.100.1.0/24             │
    │   ┌─────────────────┐                    ┌─────────────────┐        │
    │   │                 │                    │                 │        │
    │   │  vm-frontend    │◄──────────────────►│   vm-backend    │        │
    │   │  (simule projet │                    │  (simule projet │        │
    │   │   de service)   │                    │   de service)   │        │
    │   │                 │                    │                 │        │
    │   └─────────────────┘                    └─────────────────┘        │
    │                                                                     │
    │   Règles de pare-feu centralisées (simule gestion par équipe réseau)│
    └─────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 4.6.1 : Créer le VPC "partagé"

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_SHARED="shared-vpc-sim"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC (simule le projet hôte)
gcloud compute networks create $VPC_SHARED \
    --subnet-mode=custom \
    --description="VPC partagé simulé"

# Sous-réseau frontend
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.0.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe frontend"

# Sous-réseau backend
gcloud compute networks subnets create subnet-backend \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.1.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe backend"

# Sous-réseau data
gcloud compute networks subnets create subnet-data \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.2.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe data"
```

#### Exercice 4.6.2 : Créer les règles de pare-feu centralisées

```bash
# Règle 1: Trafic interne (équipe réseau contrôle)
gcloud compute firewall-rules create ${VPC_SHARED}-allow-internal \
    --network=$VPC_SHARED \
    --allow=tcp,udp,icmp \
    --source-ranges=10.100.0.0/16 \
    --description="Trafic interne - géré par équipe réseau"

# Règle 2: SSH via IAP (équipe sécurité contrôle)
gcloud compute firewall-rules create ${VPC_SHARED}-allow-ssh-iap \
    --network=$VPC_SHARED \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH IAP - géré par équipe sécurité"

# Règle 3: Frontend vers Backend (spécifique aux tags)
gcloud compute firewall-rules create ${VPC_SHARED}-frontend-to-backend \
    --network=$VPC_SHARED \
    --allow=tcp:8080 \
    --source-tags=frontend \
    --target-tags=backend \
    --description="Flux frontend vers backend - géré centralement"

# Règle 4: Backend vers Data
gcloud compute firewall-rules create ${VPC_SHARED}-backend-to-data \
    --network=$VPC_SHARED \
    --allow=tcp:5432,tcp:3306 \
    --source-tags=backend \
    --target-tags=database \
    --description="Flux backend vers bases de données"
```

#### Exercice 4.6.3 : Configurer Cloud NAT pour l'accès sortant

```bash
# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create router-nat-shared \
    --network=$VPC_SHARED \
    --region=$REGION

# Configurer Cloud NAT pour permettre l'accès Internet sortant
gcloud compute routers nats create nat-shared-vpc \
    --router=router-nat-shared \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Vérifier la configuration
gcloud compute routers nats describe nat-shared-vpc \
    --router=router-nat-shared \
    --region=$REGION
```

**Questions :**
1. Pourquoi configurer Cloud NAT avant de déployer les VMs sans IP externe ?
2. Dans un vrai Shared VPC, quelle équipe serait responsable de la configuration Cloud NAT ?
3. Les VMs peuvent-elles recevoir du trafic entrant depuis Internet via Cloud NAT ?

#### Exercice 4.6.4 : Déployer les VMs (simulant les projets de service)

```bash
# VM Frontend (simule déploiement par équipe frontend)
gcloud compute instances create vm-frontend \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-frontend \
    --private-network-ip=10.100.0.10 \
    --no-address \
    --tags=frontend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx curl'

# VM Backend (simule déploiement par équipe backend)
gcloud compute instances create vm-backend \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-backend \
    --private-network-ip=10.100.1.10 \
    --no-address \
    --tags=backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"Backend OK\")
HTTPServer((\"0.0.0.0\", 8080), H).serve_forever()" > /app.py
        python3 /app.py &'

# VM Database (simule déploiement par équipe data)
gcloud compute instances create vm-database \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-data \
    --private-network-ip=10.100.2.10 \
    --no-address \
    --tags=database \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 4.6.5 : Tester les flux autorisés

```bash
# Test: Frontend → Backend (port 8080) - Autorisé
gcloud compute ssh vm-frontend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Frontend → Backend (port 8080) ==="
curl -s --connect-timeout 5 http://10.100.1.10:8080 && echo " SUCCESS" || echo " FAILED"
EOF

# Test: Frontend → Database (port 5432) - Refusé (pas de règle)
gcloud compute ssh vm-frontend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Frontend → Database (port 5432) ==="
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/10.100.2.10/5432' 2>/dev/null && echo "SUCCESS" || echo "BLOCKED (as expected)"
EOF

# Test: Backend → Database (ping) - Autorisé (règle interne)
gcloud compute ssh vm-backend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Backend → Database (ping) ==="
ping -c 3 10.100.2.10
EOF
```

#### Exercice 4.6.6 : Simuler les rôles IAM

Dans un vrai Shared VPC, les permissions seraient:

=== Simulation des Rôles IAM ===

ÉQUIPE RÉSEAU (compute.networkAdmin sur projet hôte):
- ✅ Peut créer/modifier les sous-réseaux
- ✅ Peut voir toutes les ressources réseau
- ❌ Ne peut pas créer de VMs

ÉQUIPE SÉCURITÉ (compute.securityAdmin sur projet hôte):
- ✅ Peut créer/modifier les règles de pare-feu
- ✅ Peut auditer le trafic
- ❌ Ne peut pas modifier les sous-réseaux

ÉQUIPE FRONTEND (compute.networkUser sur subnet-frontend):
- ✅ Peut créer des VMs dans subnet-frontend
- ❌ Ne peut pas créer de VMs dans subnet-backend
- ❌ Ne peut pas modifier les règles de pare-feu

ÉQUIPE BACKEND (compute.networkUser sur subnet-backend):
- ✅ Peut créer des VMs dans subnet-backend
- ❌ Ne peut pas créer de VMs dans subnet-frontend
- ❌ Ne peut pas modifier les règles de pare-feu

ÉQUIPE DATA (compute.networkUser sur subnet-data):
- ✅ Peut créer des VMs/Cloud SQL dans subnet-data
- ❌ Ne peut pas accéder aux autres sous-réseaux
- ❌ Ne peut pas modifier les règles de pare-feu

---

## Lab 4.7 : Règles de pare-feu dans les réseaux partagés
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre comment les pare-feux fonctionnent avec Shared VPC et Peering
- Configurer des règles appropriées pour chaque scénario
- Éviter les pièges courants

### Exercices

#### Exercice 4.7.1 : Pare-feu avec VPC Peering

```bash
# Rappel de l'architecture: vpc-alpha ↔ vpc-beta (peerés)

# Vérifier les règles existantes
gcloud compute firewall-rules list --filter="network=$VPC_ALPHA"
gcloud compute firewall-rules list --filter="network=$VPC_BETA"

# POINT IMPORTANT: Le trafic peeré arrive comme du trafic INTERNE
# La source sera l'IP du VPC peer, pas une IP externe

# Créer une règle spécifique pour autoriser HTTP depuis VPC Beta
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-http-from-beta \
    --network=$VPC_ALPHA \
    --allow=tcp:80,tcp:443 \
    --source-ranges=10.20.0.0/16 \
    --target-tags=web \
    --description="HTTP depuis VPC Beta (peeré)"
```

#### Exercice 4.7.2 : Démontrer l'isolation par défaut

```bash
# Par défaut, même avec peering, le trafic peut être bloqué si aucune règle ne l'autorise

# Supprimer temporairement les règles allow-internal
gcloud compute firewall-rules delete ${VPC_ALPHA}-allow-internal --quiet
gcloud compute firewall-rules delete ${VPC_BETA}-allow-internal --quiet

# Tester la connectivité (devrait échouer même avec peering actif)
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test sans règle allow-internal ==="
ping -c 3 10.20.1.10 && echo "SUCCESS" || echo "BLOCKED by firewall"
EOF

# Rétablir les règles
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-internal \
    --network=$VPC_ALPHA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_BETA}-allow-internal \
    --network=$VPC_BETA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8
```

**Point clé :** Le peering établit la connectivité réseau, mais les règles de pare-feu contrôlent toujours le trafic autorisé.

#### Exercice 4.7.3 : Pare-feu avec Shared VPC (conceptuel)

Dans un Shared VPC, toutes les règles sont dans le projet HÔTE
Les projets de service NE PEUVENT PAS créer leurs propres règles

=== Règles de pare-feu Shared VPC ===

DANS LE PROJET HÔTE (centralisé):
| Règle                  | Source          | Cible                    |
|------------------------|-----------------|--------------------------|
| allow-internal         | 10.0.0.0/8      | Tout le VPC              |
| allow-ssh-iap          | 35.235.240.0/20 | tag:ssh-allowed          |
| allow-http-external    | 0.0.0.0/0       | tag:web-server           |
| allow-frontend-backend | tag:frontend    | tag:backend              |
| deny-all-ingress       | 0.0.0.0/0       | Tout (priorité basse)    |

DANS LES PROJETS DE SERVICE:
- ❌ Impossible de créer des règles de pare-feu
- ❌ Impossible de modifier les règles existantes
- ✅ Peuvent utiliser les tags définis dans le projet hôte

#### Exercice 4.7.4 : Bonnes pratiques de pare-feu

```bash
# Script de validation des règles de pare-feu
cat << 'EOF' > audit_firewall.sh
#!/bin/bash
echo "=== Audit des règles de pare-feu ==="

VPC=$1
if [ -z "$VPC" ]; then
    echo "Usage: $0 <vpc-name>"
    exit 1
fi

echo ""
echo "1. Règles avec source 0.0.0.0/0 (attention!):"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND sourceRanges=0.0.0.0/0" \
    --format="table(name,direction,allowed,targetTags)"

echo ""
echo "2. Règles autorisant tout le trafic (tcp,udp,icmp):"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND allowed.ports:*" \
    --format="table(name,sourceRanges,allowed)"

echo ""
echo "3. Règles sans tags cibles (s'appliquent à toutes les VMs):"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND targetTags=''" \
    --format="table(name,sourceRanges,allowed)"

echo ""
echo "4. Résumé par direction:"
echo "INGRESS:"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND direction=INGRESS" \
    --format="value(name)" | wc -l
echo "EGRESS:"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND direction=EGRESS" \
    --format="value(name)" | wc -l
EOF

chmod +x audit_firewall.sh
./audit_firewall.sh $VPC_ALPHA
```

---

## Lab 4.8 : Scénario - Choisir entre Shared VPC et Peering
**Difficulté : ⭐⭐**

### Objectifs
- Analyser différents scénarios d'entreprise
- Appliquer l'arbre de décision
- Justifier le choix architectural

### Exercices

#### Exercice 4.8.1 : Scénario 1 - Startup en croissance

CONTEXTE:
- Startup avec 20 développeurs
- 3 équipes: Frontend, Backend, Data
- Pas d'organisation GCP (projets standalone)
- Budget limité
- Besoin de communication entre les équipes

QUESTION: Shared VPC ou VPC Peering?

**Analyse:**
- ❌ Pas d'organisation GCP → Shared VPC impossible
- ✅ VPC Peering est la seule option

**Recommandation:** VPC Peering entre 3 VPC (Frontend, Backend, Data)

#### Exercice 4.8.2 : Scénario 2 - Grande entreprise

CONTEXTE:
- Entreprise de 500 personnes
- Organisation GCP existante
- 15 équipes projet
- Équipe réseau centralisée
- Conformité stricte (PCI-DSS)
- Besoin de politiques de sécurité uniformes

QUESTION: Shared VPC ou VPC Peering?

**Analyse:**
- ✅ Organisation GCP → Shared VPC possible
- ✅ Équipe réseau centralisée → Modèle Shared VPC idéal
- ✅ Conformité stricte → Pare-feu centralisé nécessaire
- ✅ Politiques uniformes → Shared VPC préférable

**Recommandation:** Shared VPC avec projet hôte dédié

#### Exercice 4.8.3 : Scénario 3 - Multi-cloud / Partenaires

CONTEXTE:
- Entreprise utilisant GCP et AWS
- Partenaire externe sur GCP (autre organisation)
- Besoin de partager certains services entre les organisations
- Chaque organisation gère son propre réseau

QUESTION: Shared VPC ou VPC Peering?

**Analyse:**
- ❌ Cross-organisation → Shared VPC impossible
- ✅ VPC Peering supporte cross-organisation

**Recommandation:** VPC Peering entre les organisations

#### Exercice 4.8.4 : Scénario 4 - Architecture hybride

CONTEXTE:
- Grande entreprise avec organisation GCP
- Départements internes (Finance, RH, IT)
- Partenaires externes (Auditeurs, Fournisseurs)
- Connexion on-premise via Cloud Interconnect

QUESTION: Quelle architecture?

**Analyse:**
- Interne → Shared VPC (gestion centralisée)
- Externe → VPC Peering (isolation, cross-org)
- Hybride → Connectivité via le VPC hôte partagé

**Recommandation:** 
```
                    On-Premise
                        │
                        │ Cloud Interconnect
                        ▼
    ┌───────────────────────────────────────┐
    │           Shared VPC (Hôte)           │
    │  - Finance (projet service)           │
    │  - RH (projet service)                │
    │  - IT (projet service)                │
    └───────────────┬───────────────────────┘
                    │ VPC Peering
                    ▼
    ┌───────────────────────────────────────┐
    │      VPC Partenaires (autre org)      │
    │  - Auditeurs                          │
    │  - Fournisseurs                       │
    └───────────────────────────────────────┘
```

#### Exercice 4.8.5 : Arbre de décision interactif

=== ARBRE DE DÉCISION: SHARED VPC vs VPC PEERING ===

```
Q1: Avez-vous une organisation GCP?
    │
    ├─► NON → VPC Peering (seule option)
    │
    └─► OUI → Q2: Les VPC sont-ils dans différentes organisations?
                  │
                  ├─► OUI → VPC Peering (cross-org)
                  │
                  └─► NON → Q3: Avez-vous une équipe réseau centralisée?
                                │
                                ├─► OUI → Q4: Plus de 25 connexions nécessaires?
                                │         │
                                │         ├─► OUI → Shared VPC
                                │         │
                                │         └─► NON → Q5: Besoin de politiques
                                │                       de sécurité uniformes?
                                │                       │
                                │                       ├─► OUI → Shared VPC
                                │                       │
                                │                       └─► NON → VPC Peering
                                │                                 ou Shared VPC
                                │
                                └─► NON → VPC Peering (gestion décentralisée)
```

RÉSUMÉ:
| Scénario            | Utilisation                                                              |
|---------------------|--------------------------------------------------------------------------|
| Choisir Shared VPC  | Grande org, équipe réseau centralisée, sécurité uniforme, >25 connexions |
| Choisir VPC Peering | Pas d'org GCP, cross-organisation, équipes autonomes, <25 connexions     |
| Combiner les deux   | Grande entreprise avec partenaires externes                              |

---

## Lab 4.9 : Architecture hybride - Shared VPC + Peering
**Difficulté : ⭐⭐⭐**

### Objectifs
- Combiner Shared VPC et VPC Peering
- Créer une architecture enterprise complète
- Gérer la complexité multi-modèle

### Architecture cible

```
                                    Organisation Interne
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │    Shared VPC (Projet Hôte: network-hub)                                │
    │    ┌─────────────────────────────────────────────────────────────────┐  │
    │    │                                                                 │  │
    │    │   subnet-prod          subnet-staging        subnet-dev         │  │
    │    │   10.10.0.0/24         10.20.0.0/24         10.30.0.0/24        │  │
    │    │       │                     │                    │              │  │
    │    │       ▼                     ▼                    ▼              │  │
    │    │   Projet Service:      Projet Service:     Projet Service:      │  │
    │    │   app-prod             app-staging         app-dev              │  │
    │    │                                                                 │  │
    │    └────────────────────────────┬────────────────────────────────────┘  │
    │                                 │                                       │
    └─────────────────────────────────┼───────────────────────────────────────┘
                                      │ VPC Peering
                                      ▼
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                     Organisation Partenaire                             │
    │    ┌─────────────────────────────────────────────────────────────────┐  │
    │    │                      VPC Partenaire                             │  │
    │    │                      10.200.0.0/16                              │  │
    │    │                                                                 │  │
    │    │                     Services partagés                           │  │
    │    │                     (API, données)                              │  │
    │    └─────────────────────────────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────────────────────────────┘
```

### Exercices (Mode simulation - même projet)

#### Exercice 4.9.1 : Créer l'architecture

```bash
# Variables
export VPC_HUB="vpc-hub"
export VPC_PARTNER="vpc-partner"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# 1. Créer le VPC Hub (simule Shared VPC hôte)
gcloud compute networks create $VPC_HUB \
    --subnet-mode=custom \
    --description="VPC Hub - simule Shared VPC"

# Sous-réseaux internes
gcloud compute networks subnets create subnet-prod \
    --network=$VPC_HUB --region=$REGION --range=10.10.0.0/24

gcloud compute networks subnets create subnet-staging \
    --network=$VPC_HUB --region=$REGION --range=10.20.0.0/24

gcloud compute networks subnets create subnet-dev \
    --network=$VPC_HUB --region=$REGION --range=10.30.0.0/24

# 2. Créer le VPC Partenaire (autre organisation simulée)
gcloud compute networks create $VPC_PARTNER \
    --subnet-mode=custom \
    --description="VPC Partenaire - autre organisation"

gcloud compute networks subnets create subnet-partner \
    --network=$VPC_PARTNER --region=$REGION --range=10.200.0.0/24

# 3. Règles de pare-feu
# Hub
gcloud compute firewall-rules create ${VPC_HUB}-allow-internal \
    --network=$VPC_HUB --allow=tcp,udp,icmp --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_HUB}-allow-ssh-iap \
    --network=$VPC_HUB --allow=tcp:22 --source-ranges=35.235.240.0/20

# Partenaire
gcloud compute firewall-rules create ${VPC_PARTNER}-allow-internal \
    --network=$VPC_PARTNER --allow=tcp,udp,icmp --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_PARTNER}-allow-ssh-iap \
    --network=$VPC_PARTNER --allow=tcp:22 --source-ranges=35.235.240.0/20
```

#### Exercice 4.9.2 : Établir le peering Hub ↔ Partenaire

```bash
# Peering bidirectionnel
gcloud compute networks peerings create peering-hub-to-partner \
    --network=$VPC_HUB \
    --peer-network=$VPC_PARTNER \
    --peer-project=$PROJECT_ID \
    --export-custom-routes

gcloud compute networks peerings create peering-partner-to-hub \
    --network=$VPC_PARTNER \
    --peer-network=$VPC_HUB \
    --peer-project=$PROJECT_ID \
    --import-custom-routes

# Vérifier
gcloud compute networks peerings list --network=$VPC_HUB
```

#### Exercice 4.9.3 : Déployer les VMs

```bash
# VM Production
gcloud compute instances create vm-prod \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-prod \
    --private-network-ip=10.10.0.10 --no-address \
    --tags=prod,internal \
    --image-family=debian-11 --image-project=debian-cloud

# VM Staging
gcloud compute instances create vm-staging \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-staging \
    --private-network-ip=10.20.0.10 --no-address \
    --tags=staging,internal \
    --image-family=debian-11 --image-project=debian-cloud

# VM Dev
gcloud compute instances create vm-dev \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-dev \
    --private-network-ip=10.30.0.10 --no-address \
    --tags=dev,internal \
    --image-family=debian-11 --image-project=debian-cloud

# VM Partenaire
gcloud compute instances create vm-partner \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_PARTNER --subnet=subnet-partner \
    --private-network-ip=10.200.0.10 --no-address \
    --tags=partner,external \
    --image-family=debian-11 --image-project=debian-cloud
```

#### Exercice 4.9.4 : Contrôler l'accès partenaire

```bash
# Le partenaire ne doit accéder qu'à la production, pas au dev/staging

# Règle: Autoriser partenaire → prod uniquement
gcloud compute firewall-rules create ${VPC_HUB}-allow-partner-to-prod \
    --network=$VPC_HUB \
    --allow=tcp:443,tcp:8080 \
    --source-ranges=10.200.0.0/16 \
    --target-tags=prod \
    --description="Partenaire peut accéder à prod"

# Règle: Bloquer partenaire → dev/staging (explicit deny)
gcloud compute firewall-rules create ${VPC_HUB}-deny-partner-to-nonprod \
    --network=$VPC_HUB \
    --action=DENY \
    --rules=all \
    --source-ranges=10.200.0.0/16 \
    --target-tags=dev,staging \
    --priority=900 \
    --description="Partenaire ne peut PAS accéder à dev/staging"
```

#### Exercice 4.9.5 : Tester l'isolation

```bash
# Partenaire → Prod (devrait fonctionner)
gcloud compute ssh vm-partner --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Partenaire → Prod ==="
ping -c 3 10.10.0.10 && echo "SUCCESS" || echo "BLOCKED"
EOF

# Partenaire → Dev (devrait être bloqué)
gcloud compute ssh vm-partner --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Partenaire → Dev ==="
ping -c 3 10.30.0.10 && echo "SUCCESS" || echo "BLOCKED (expected)"
EOF

# Interne: Prod → Dev (devrait fonctionner)
gcloud compute ssh vm-prod --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Prod → Dev (interne) ==="
ping -c 3 10.30.0.10 && echo "SUCCESS" || echo "BLOCKED"
EOF
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage de toutes les ressources des labs du Module 4

echo "=== Suppression des VMs ==="
for VM in vm-alpha vm-beta vm-gamma vm-frontend vm-backend vm-database \
          vm-prod vm-staging vm-dev vm-partner; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des peerings ==="
for VPC in vpc-alpha vpc-beta vpc-gamma vpc-hub vpc-partner; do
    for PEERING in $(gcloud compute networks peerings list --network=$VPC \
                     --format="get(name)" 2>/dev/null); do
        gcloud compute networks peerings delete $PEERING --network=$VPC --quiet 2>/dev/null
    done
done

echo "=== Suppression des routes personnalisées ==="
for ROUTE in custom-route-alpha route-alpha-to-gamma-via-beta route-gamma-to-alpha-via-beta; do
    gcloud compute routes delete $ROUTE --quiet 2>/dev/null
done

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-alpha vpc-beta vpc-gamma shared-vpc-sim vpc-hub vpc-partner; do
    for RULE in $(gcloud compute firewall-rules list --filter="network:$VPC" \
                  --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
    done
done

echo "=== Suppression des Cloud NAT ==="
gcloud compute routers nats delete nat-shared-vpc --router=router-nat-shared --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des Cloud Routers ==="
gcloud compute routers delete router-nat-shared --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-alpha subnet-beta subnet-gamma subnet-frontend subnet-backend \
              subnet-data subnet-prod subnet-staging subnet-dev subnet-partner; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in vpc-alpha vpc-beta vpc-gamma shared-vpc-sim vpc-hub vpc-partner; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 4

### VPC Peering
```bash
# Créer un peering
gcloud compute networks peerings create NAME \
    --network=VPC --peer-network=PEER_VPC --peer-project=PROJECT

# Lister les peerings
gcloud compute networks peerings list --network=VPC

# Mettre à jour (export/import routes)
gcloud compute networks peerings update NAME \
    --network=VPC --export-custom-routes --import-custom-routes

# Supprimer
gcloud compute networks peerings delete NAME --network=VPC
```

### Shared VPC
```bash
# Activer le projet hôte
gcloud compute shared-vpc enable HOST_PROJECT

# Associer un projet de service
gcloud compute shared-vpc associated-projects add SERVICE_PROJECT \
    --host-project=HOST_PROJECT

# Lister les projets associés
gcloud compute shared-vpc list-associated-resources HOST_PROJECT

# Désassocier un projet
gcloud compute shared-vpc associated-projects remove SERVICE_PROJECT \
    --host-project=HOST_PROJECT

# Désactiver Shared VPC
gcloud compute shared-vpc disable HOST_PROJECT
```

### Permissions IAM
```bash
# Donner accès à un sous-réseau
gcloud compute networks subnets add-iam-policy-binding SUBNET \
    --region=REGION --project=HOST_PROJECT \
    --member="user:EMAIL" --role="roles/compute.networkUser"

# Voir les permissions
gcloud compute networks subnets get-iam-policy SUBNET \
    --region=REGION --project=HOST_PROJECT
```
