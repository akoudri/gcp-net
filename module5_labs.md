# Module 5 - Options de Connexion Privée
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Configurer Private Google Access (PGA) pour accéder aux APIs Google
- Mettre en place Private Services Access (PSA) pour les services managés
- Implémenter Private Service Connect (PSC) pour une connectivité avancée
- Configurer le DNS pour la connectivité privée
- Choisir la solution appropriée selon le contexte
- Sécuriser les accès privés avec les bonnes pratiques

### Prérequis
- Modules 1 à 4 complétés
- Projet GCP avec facturation activée
- APIs activées : Compute Engine, Cloud DNS, Service Networking
- Droits : roles/compute.networkAdmin, roles/dns.admin, roles/servicenetworking.networksAdmin

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 5.1 | Private Google Access - Configuration de base | ⭐ |
| 5.2 | PGA - Configuration DNS avancée | ⭐⭐ |
| 5.3 | Private Services Access - Cloud SQL | ⭐⭐ |
| 5.4 | PSA - Memorystore Redis | ⭐⭐ |
| 5.5 | Private Service Connect - APIs Google | ⭐⭐⭐ |
| 5.6 | PSC - Publier un service (Producteur) | ⭐⭐⭐ |
| 5.7 | PSC - Consommer un service (Consommateur) | ⭐⭐⭐ |
| 5.8 | Comparaison PGA vs PSA vs PSC | ⭐⭐ |
| 5.9 | Scénario intégrateur : Architecture hybride sécurisée | ⭐⭐⭐ |

---

## Lab 5.1 : Private Google Access - Configuration de base
**Difficulté : ⭐**

### Objectifs
- Comprendre le fonctionnement de PGA
- Activer PGA sur un sous-réseau
- Tester l'accès aux APIs Google sans IP externe

### Architecture cible

```
                                    APIs Google
                                   (Cloud Storage,
                                    BigQuery, etc.)
                                         │
                                         │ Private Google Access
                                         │ (199.36.153.8/30)
                                         │
    ┌────────────────────────────────────┴─────────────────────────────────┐
    │                              VPC                                     │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │                    subnet-pga                                │   │
    │   │                   10.0.0.0/24                                │   │
    │   │                 PGA: ENABLED ✓                               │   │
    │   │                                                              │   │
    │   │   ┌───────────────┐                                         │   │
    │   │   │    vm-pga     │ ──────► Cloud Storage                   │   │
    │   │   │ (no external  │         BigQuery                        │   │
    │   │   │     IP)       │         Pub/Sub                         │   │
    │   │   └───────────────┘         etc.                            │   │
    │   │                                                              │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    └──────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 5.1.1 : Créer l'infrastructure de test

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-private-access"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --description="VPC pour tester la connectivité privée"

# Créer un sous-réseau SANS PGA initialement
gcloud compute networks subnets create subnet-pga \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.0.0/24 \
    --no-enable-private-ip-google-access

# Vérifier que PGA est désactivé
gcloud compute networks subnets describe subnet-pga \
    --region=$REGION \
    --format="get(privateIpGoogleAccess)"
# Résultat attendu: False

# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH via IAP"

gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --allow=tcp:443 \
    --destination-ranges=199.36.153.0/24 \
    --description="Egress vers APIs Google"
```

#### Exercice 5.1.2 : Créer une VM sans IP externe

```bash
# VM sans IP externe avec scopes pour Cloud Storage
gcloud compute instances create vm-pga \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-pga \
    --no-address \
    --scopes=storage-ro,logging-write \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils'

# Vérifier que la VM n'a pas d'IP externe
gcloud compute instances describe vm-pga \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs)"
# Résultat attendu: vide (pas d'IP externe)
```

#### Exercice 5.1.3 : Tester AVANT l'activation de PGA

```bash
# Se connecter à la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap

# Tester l'accès à Cloud Storage (devrait échouer)
gsutil ls gs://gcp-public-data-landsat
# Résultat attendu: Erreur de connexion

# Tester la résolution DNS
nslookup storage.googleapis.com
# Note: La résolution fonctionne car le DNS passe par le metadata server

# Tester la connectivité HTTP vers les APIs
curl -v --connect-timeout 10 https://storage.googleapis.com
# Résultat attendu: Timeout (pas de route vers Internet)

exit
```

**Questions :**
1. Pourquoi la résolution DNS fonctionne-t-elle malgré l'absence d'IP externe ?
2. Pourquoi la connexion HTTPS échoue-t-elle ?

#### Exercice 5.1.4 : Activer Private Google Access

```bash
# Activer PGA sur le sous-réseau
gcloud compute networks subnets update subnet-pga \
    --region=$REGION \
    --enable-private-google-access

# Vérifier l'activation
gcloud compute networks subnets describe subnet-pga \
    --region=$REGION \
    --format="get(privateIpGoogleAccess)"
# Résultat attendu: True
```

#### Exercice 5.1.5 : Tester APRÈS l'activation de PGA

```bash
# Se reconnecter à la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap

# Tester l'accès à Cloud Storage (devrait fonctionner)
gsutil ls gs://gcp-public-data-landsat | head -5
# Résultat attendu: Liste des fichiers

# Tester l'accès à d'autres APIs Google
curl -s -o /dev/null -w "%{http_code}" https://www.googleapis.com/discovery/v1/apis
# Résultat attendu: 200

# Tester l'accès à Internet (toujours impossible)
curl -v --connect-timeout 5 https://www.github.com
# Résultat attendu: Timeout (PGA ≠ Internet)

exit
```

**Questions :**
1. PGA permet-il d'accéder à github.com ? Pourquoi ?
2. Quel mécanisme permet maintenant à la VM d'atteindre Cloud Storage ?

#### Exercice 5.1.6 : Observer les routes utilisées par PGA

```bash
# Voir les routes du VPC
gcloud compute routes list --filter="network=$VPC_NAME"

# La route par défaut (0.0.0.0/0) vers default-internet-gateway
# est utilisée pour router le trafic vers les IPs Google
# PGA "intercepte" ce trafic pour les APIs Google
```

---

## Lab 5.2 : PGA - Configuration DNS avancée
**Difficulté : ⭐⭐**

### Objectifs
- Configurer le DNS pour forcer l'utilisation de PGA
- Comprendre la différence entre private.googleapis.com et restricted.googleapis.com
- Préparer l'infrastructure pour VPC Service Controls

### Exercices

#### Exercice 5.2.1 : Vérifier la résolution DNS par défaut

```bash
# Se connecter à la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap

# Voir comment googleapis.com est résolu par défaut
nslookup storage.googleapis.com

# Les IPs retournées sont des IPs publiques Google Anycast
# Exemple: 142.250.x.x (varie selon votre localisation)

dig storage.googleapis.com +short

exit
```

#### Exercice 5.2.2 : Créer une zone DNS privée pour googleapis.com

```bash
# Créer la zone DNS privée
gcloud dns managed-zones create googleapis-private \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_NAME \
    --description="Zone privée pour router googleapis.com vers PGA"

# Vérifier la création
gcloud dns managed-zones describe googleapis-private
```

#### Exercice 5.2.3 : Ajouter les enregistrements DNS pour private.googleapis.com

```bash
# Enregistrement A pour private.googleapis.com
gcloud dns record-sets create "private.googleapis.com." \
    --zone=googleapis-private \
    --type=A \
    --ttl=300 \
    --rrdatas="199.36.153.8,199.36.153.9,199.36.153.10,199.36.153.11"

# CNAME wildcard pour rediriger *.googleapis.com
gcloud dns record-sets create "*.googleapis.com." \
    --zone=googleapis-private \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="private.googleapis.com."

# Lister les enregistrements
gcloud dns record-sets list --zone=googleapis-private
```

#### Exercice 5.2.4 : Tester la nouvelle résolution DNS

```bash
# Se connecter à la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap

# Tester la résolution - devrait maintenant pointer vers 199.36.153.x
nslookup storage.googleapis.com
dig storage.googleapis.com +short

# Vérifier que ça fonctionne toujours
gsutil ls gs://gcp-public-data-landsat | head -3

exit
```

**Questions :**
1. Quelle est la différence entre les IPs Anycast publiques et 199.36.153.x ?
2. Pourquoi configurer le DNS ainsi améliore-t-il la sécurité ?

#### Exercice 5.2.5 : Comprendre restricted.googleapis.com

```bash
# restricted.googleapis.com est utilisé avec VPC Service Controls
# IPs: 199.36.153.4/30

cat << 'EOF'
=== Comparaison private.googleapis.com vs restricted.googleapis.com ===

| Aspect | private.googleapis.com | restricted.googleapis.com |
|--------|------------------------|---------------------------|
| IPs | 199.36.153.8/30 | 199.36.153.4/30 |
| Usage | PGA standard | VPC Service Controls |
| Services | Tous les services Google | Services compatibles VPC-SC |
| Périmètre | Pas de restriction | Respecte les périmètres VPC-SC |
| Cas d'usage | VMs sans IP externe | Données sensibles, conformité |

Quand utiliser restricted.googleapis.com :
- Projet dans un périmètre VPC Service Controls
- Exigences de conformité strictes (HIPAA, PCI-DSS)
- Prévention de l'exfiltration de données
EOF
```

#### Exercice 5.2.6 : (Optionnel) Configurer pour restricted.googleapis.com

```bash
# Créer une zone DNS pour restricted (ne pas faire si vous n'avez pas VPC-SC)
# Ceci est fourni à titre informatif

cat << 'EOF'
# Zone pour VPC Service Controls
gcloud dns managed-zones create googleapis-restricted \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=VPC_AVEC_VPC_SC \
    --description="Zone pour VPC Service Controls"

# Enregistrement pour restricted
gcloud dns record-sets create "restricted.googleapis.com." \
    --zone=googleapis-restricted \
    --type=A \
    --ttl=300 \
    --rrdatas="199.36.153.4,199.36.153.5,199.36.153.6,199.36.153.7"

# CNAME wildcard
gcloud dns record-sets create "*.googleapis.com." \
    --zone=googleapis-restricted \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="restricted.googleapis.com."
EOF
```

---

## Lab 5.3 : Private Services Access - Cloud SQL
**Difficulté : ⭐⭐**

### Objectifs
- Configurer Private Services Access
- Déployer Cloud SQL avec IP privée uniquement
- Comprendre le VPC Peering automatique avec Google

### Architecture cible

```
              Votre VPC                              VPC Google (Services Managés)
    ┌──────────────────────────┐              ┌──────────────────────────────────┐
    │                          │              │                                  │
    │   subnet-app             │   Peering   │   Plage réservée: 10.100.0.0/24  │
    │   10.0.0.0/24            │◄───────────►│                                  │
    │                          │  (automatique) │   ┌──────────────────────┐    │
    │   ┌───────────────┐      │              │   │    Cloud SQL          │    │
    │   │    vm-app     │──────┼──────────────┼──►│    10.100.0.2         │    │
    │   │   10.0.0.10   │      │              │   │    PostgreSQL         │    │
    │   └───────────────┘      │              │   └──────────────────────┘    │
    │                          │              │                                  │
    └──────────────────────────┘              └──────────────────────────────────┘
```

### Exercices

#### Exercice 5.3.1 : Activer l'API Service Networking

```bash
# Activer l'API nécessaire pour PSA
gcloud services enable servicenetworking.googleapis.com

# Vérifier l'activation
gcloud services list --filter="name:servicenetworking"
```

#### Exercice 5.3.2 : Réserver une plage d'adresses pour les services Google

```bash
# Réserver une plage IP pour les services managés Google
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --addresses=10.100.0.0 \
    --prefix-length=24 \
    --network=$VPC_NAME \
    --description="Plage réservée pour les services managés Google"

# Vérifier la réservation
gcloud compute addresses list --global --filter="purpose=VPC_PEERING"

# Voir les détails
gcloud compute addresses describe google-managed-services --global
```

**Questions :**
1. Pourquoi réserver une plage /24 et non une seule IP ?
2. Cette plage peut-elle chevaucher vos sous-réseaux existants ?

#### Exercice 5.3.3 : Créer la connexion Private Services Access

```bash
# Créer la connexion de service privé
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=$VPC_NAME

# Cette commande crée automatiquement un VPC Peering avec le VPC de Google
# Attendre quelques minutes pour l'établissement

# Vérifier la connexion
gcloud services vpc-peerings list --network=$VPC_NAME

# Voir le peering créé
gcloud compute networks peerings list --network=$VPC_NAME
```

#### Exercice 5.3.4 : Créer une instance Cloud SQL avec IP privée

```bash
# Activer l'API Cloud SQL
gcloud services enable sqladmin.googleapis.com

# Créer l'instance Cloud SQL PostgreSQL
gcloud sql instances create sql-private \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=$REGION \
    --network=$VPC_NAME \
    --no-assign-ip \
    --storage-size=10GB \
    --storage-type=HDD

# Cette opération prend 5-10 minutes
echo "Création de l'instance Cloud SQL en cours..."

# Vérifier l'état
gcloud sql instances describe sql-private \
    --format="yaml(name,state,ipAddresses,settings.ipConfiguration)"
```

#### Exercice 5.3.5 : Configurer l'utilisateur et la base de données

```bash
# Définir le mot de passe de l'utilisateur postgres
gcloud sql users set-password postgres \
    --instance=sql-private \
    --password=MySecureP@ssw0rd!

# Créer une base de données
gcloud sql databases create testdb --instance=sql-private

# Récupérer l'IP privée de l'instance
export SQL_IP=$(gcloud sql instances describe sql-private \
    --format="get(ipAddresses[0].ipAddress)")
echo "IP Cloud SQL: $SQL_IP"
```

#### Exercice 5.3.6 : Créer une VM pour tester la connexion

```bash
# Créer un sous-réseau pour les applications
gcloud compute networks subnets create subnet-app \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access

# Règle de pare-feu pour la communication interne
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

# VM cliente
gcloud compute instances create vm-sql-client \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-app \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y postgresql-client'
```

#### Exercice 5.3.7 : Tester la connexion à Cloud SQL

```bash
# Se connecter à la VM
gcloud compute ssh vm-sql-client --zone=$ZONE --tunnel-through-iap

# Tester la connexion à Cloud SQL
# Remplacer $SQL_IP par l'IP obtenue précédemment
psql -h <SQL_IP> -U postgres -d testdb -c "SELECT version();"
# Entrer le mot de passe: MySecureP@ssw0rd!

# Créer une table de test
psql -h <SQL_IP> -U postgres -d testdb << 'EOF'
CREATE TABLE test_psa (
    id SERIAL PRIMARY KEY,
    message VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_psa (message) VALUES ('PSA fonctionne !');

SELECT * FROM test_psa;
EOF

exit
```

**Questions :**
1. L'IP de Cloud SQL (10.100.0.x) fait-elle partie de vos sous-réseaux ?
2. Pourquoi utiliser PSA plutôt qu'une IP publique pour Cloud SQL ?

---

## Lab 5.4 : PSA - Memorystore Redis
**Difficulté : ⭐⭐**

### Objectifs
- Déployer Memorystore Redis avec PSA
- Utiliser la même plage PSA pour plusieurs services
- Tester la connectivité Redis

### Exercices

#### Exercice 5.4.1 : Activer l'API Memorystore

```bash
# Activer l'API Redis
gcloud services enable redis.googleapis.com

# Vérifier
gcloud services list --filter="name:redis"
```

#### Exercice 5.4.2 : Créer une instance Memorystore Redis

```bash
# Créer l'instance Redis avec IP privée
# Elle utilisera la même connexion PSA que Cloud SQL
gcloud redis instances create redis-private \
    --region=$REGION \
    --network=$VPC_NAME \
    --tier=basic \
    --size=1 \
    --redis-version=redis_6_x

# Attendre la création (5-10 minutes)
echo "Création de Redis en cours..."

# Vérifier l'état
gcloud redis instances describe redis-private \
    --region=$REGION \
    --format="yaml(name,state,host,port,currentLocationId)"

# Récupérer l'IP Redis
export REDIS_IP=$(gcloud redis instances describe redis-private \
    --region=$REGION \
    --format="get(host)")
echo "IP Redis: $REDIS_IP"
```

#### Exercice 5.4.3 : Tester la connexion Redis

```bash
# Installer redis-cli sur la VM cliente
gcloud compute ssh vm-sql-client --zone=$ZONE --tunnel-through-iap

# Installer redis-tools
sudo apt-get update && sudo apt-get install -y redis-tools

# Tester la connexion Redis (remplacer <REDIS_IP>)
redis-cli -h <REDIS_IP> ping
# Résultat attendu: PONG

# Tester quelques commandes
redis-cli -h <REDIS_IP> << 'EOF'
SET test:psa "Memorystore fonctionne!"
GET test:psa
KEYS *
INFO server
EOF

exit
```

#### Exercice 5.4.4 : Observer les ressources PSA

```bash
# Voir toutes les adresses réservées pour PSA
gcloud compute addresses list --global --filter="purpose=VPC_PEERING"

# Voir le peering
gcloud compute networks peerings list --network=$VPC_NAME

# Cloud SQL et Redis partagent la même connexion PSA
# mais ont des IPs différentes dans la plage réservée
```

---

## Lab 5.5 : Private Service Connect - APIs Google
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer un endpoint PSC pour les APIs Google
- Configurer le DNS pour utiliser l'endpoint
- Comparer PSC avec PGA

### Architecture cible

```
                                    APIs Google
                                         │
                                         │
    ┌────────────────────────────────────┴─────────────────────────────────┐
    │                              VPC                                     │
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │                    subnet-psc                                │   │
    │   │                   10.1.0.0/24                                │   │
    │   │                                                              │   │
    │   │   ┌───────────────┐        ┌───────────────────────┐        │   │
    │   │   │    vm-psc     │───────►│   PSC Endpoint        │────────┼───┼──► APIs Google
    │   │   │   10.1.0.10   │        │   10.1.0.100          │        │   │
    │   │   └───────────────┘        │   (all-apis bundle)   │        │   │
    │   │                            └───────────────────────┘        │   │
    │   │                                     ▲                        │   │
    │   │                                     │                        │   │
    │   │                            DNS: *.googleapis.com             │   │
    │   │                                 → 10.1.0.100                 │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    └──────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 5.5.1 : Créer un sous-réseau pour PSC

```bash
# Sous-réseau dédié pour PSC
gcloud compute networks subnets create subnet-psc \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.1.0.0/24 \
    --enable-private-ip-google-access
```

#### Exercice 5.5.2 : Réserver une adresse IP pour l'endpoint PSC

```bash
# Réserver une IP interne pour l'endpoint
gcloud compute addresses create psc-apis-endpoint \
    --region=$REGION \
    --subnet=subnet-psc \
    --addresses=10.1.0.100

# Vérifier
gcloud compute addresses describe psc-apis-endpoint --region=$REGION
```

#### Exercice 5.5.3 : Créer l'endpoint PSC pour les APIs Google

```bash
# Créer la forwarding rule PSC vers toutes les APIs Google
gcloud compute forwarding-rules create psc-endpoint-all-apis \
    --region=$REGION \
    --network=$VPC_NAME \
    --address=psc-apis-endpoint \
    --target-google-apis-bundle=all-apis

# Vérifier la création
gcloud compute forwarding-rules describe psc-endpoint-all-apis \
    --region=$REGION

# Voir le statut
gcloud compute forwarding-rules list \
    --filter="name:psc-endpoint" \
    --format="table(name,IPAddress,target)"
```

**Questions :**
1. Quelle est la différence entre `all-apis` et `vpc-sc` comme bundle ?
2. L'endpoint PSC a-t-il une IP publique ou privée ?

#### Exercice 5.5.4 : Configurer le DNS pour utiliser l'endpoint PSC

```bash
# Créer une zone DNS privée pour PSC (ou mettre à jour l'existante)
# Si la zone googleapis-private existe déjà, la supprimer d'abord
gcloud dns managed-zones delete googleapis-private --quiet 2>/dev/null

# Créer la nouvelle zone
gcloud dns managed-zones create googleapis-psc \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_NAME \
    --description="Zone DNS pour PSC APIs Google"

# Enregistrement A pour l'endpoint PSC
gcloud dns record-sets create "storage.googleapis.com." \
    --zone=googleapis-psc \
    --type=A \
    --ttl=300 \
    --rrdatas="10.1.0.100"

# Enregistrement pour d'autres APIs courantes
for API in www.googleapis.com bigquery.googleapis.com pubsub.googleapis.com; do
    gcloud dns record-sets create "${API}." \
        --zone=googleapis-psc \
        --type=A \
        --ttl=300 \
        --rrdatas="10.1.0.100"
done

# Lister les enregistrements
gcloud dns record-sets list --zone=googleapis-psc
```

#### Exercice 5.5.5 : Créer une VM pour tester PSC

```bash
# VM dans le sous-réseau PSC
gcloud compute instances create vm-psc \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-psc \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --scopes=storage-ro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils tcpdump'
```

#### Exercice 5.5.6 : Tester l'accès via l'endpoint PSC

```bash
# Se connecter à la VM
gcloud compute ssh vm-psc --zone=$ZONE --tunnel-through-iap

# Vérifier la résolution DNS
nslookup storage.googleapis.com
# Devrait retourner 10.1.0.100

dig storage.googleapis.com +short
# 10.1.0.100

# Tester l'accès à Cloud Storage via PSC
gsutil ls gs://gcp-public-data-landsat | head -3

# Tester avec curl en mode verbose
curl -v https://storage.googleapis.com 2>&1 | head -20
# Vérifier que la connexion est établie vers 10.1.0.100

# Observer le trafic (dans un autre terminal)
sudo tcpdump -i any host 10.1.0.100 -n

exit
```

#### Exercice 5.5.7 : Comparer PSC avec PGA

```bash
cat << 'EOF'
=== Comparaison PSC vs PGA pour les APIs Google ===

| Aspect | PGA | PSC |
|--------|-----|-----|
| IP utilisée | IPs Google (199.36.153.x) | IP dans VOTRE VPC (10.1.0.100) |
| Configuration | Par sous-réseau | Par endpoint |
| DNS | Optionnel mais recommandé | Obligatoire |
| Transitivité on-prem | Via routes spéciales | Native (IP routable) |
| Isolation | Partagé entre tous | Dédié par endpoint |
| Granularité | Tout ou rien | Par bundle/service |
| Complexité | Simple | Moyenne |

Quand choisir PSC :
✅ Accès depuis on-premise (IP routable)
✅ Besoin d'isolation/contrôle fin
✅ Exigences de sécurité strictes
✅ VPC Service Controls

Quand PGA suffit :
✅ VMs GCP uniquement
✅ Configuration simple
✅ Pas d'exigences on-premise
EOF
```

---

## Lab 5.6 : PSC - Publier un service (Producteur)
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer un service backend avec Internal Load Balancer
- Publier le service via Private Service Connect
- Comprendre le rôle du producteur

### Architecture cible

```
    VPC Producteur
    ┌──────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   subnet-producer              subnet-psc-nat                        │
    │   10.50.0.0/24                 10.50.1.0/24                          │
    │                                (PURPOSE: PSC)                        │
    │   ┌───────────────┐                                                  │
    │   │   backend-vm  │                                                  │
    │   │   (nginx)     │                                                  │
    │   │   10.50.0.10  │                                                  │
    │   └───────┬───────┘                                                  │
    │           │                                                          │
    │           ▼                                                          │
    │   ┌───────────────────┐         ┌────────────────────────┐          │
    │   │  Internal LB      │────────►│  Service Attachment    │──────────┼──► Vers consommateurs
    │   │  10.50.0.100      │         │  (PSC Producteur)      │          │
    │   └───────────────────┘         └────────────────────────┘          │
    │                                                                      │
    └──────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 5.6.1 : Créer le VPC Producteur

```bash
# VPC pour le producteur
export VPC_PRODUCER="vpc-producer"

gcloud compute networks create $VPC_PRODUCER \
    --subnet-mode=custom \
    --description="VPC du producteur de service"

# Sous-réseau pour les backends
gcloud compute networks subnets create subnet-producer \
    --network=$VPC_PRODUCER \
    --region=$REGION \
    --range=10.50.0.0/24

# Sous-réseau spécial pour PSC NAT
gcloud compute networks subnets create subnet-psc-nat \
    --network=$VPC_PRODUCER \
    --region=$REGION \
    --range=10.50.1.0/24 \
    --purpose=PRIVATE_SERVICE_CONNECT

# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-internal \
    --network=$VPC_PRODUCER \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-ssh-iap \
    --network=$VPC_PRODUCER \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-health-check \
    --network=$VPC_PRODUCER \
    --allow=tcp:80 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=backend
```

#### Exercice 5.6.2 : Déployer le backend

```bash
# VM backend avec nginx
gcloud compute instances create backend-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PRODUCER \
    --subnet=subnet-producer \
    --private-network-ip=10.50.0.10 \
    --no-address \
    --tags=backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "<h1>Service du Producteur</h1><p>Hostname: $(hostname)</p><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
        systemctl enable nginx
        systemctl start nginx'

# Attendre que nginx démarre
sleep 30

# Créer un Instance Group (nécessaire pour le LB)
gcloud compute instance-groups unmanaged create backend-group \
    --zone=$ZONE

gcloud compute instance-groups unmanaged add-instances backend-group \
    --zone=$ZONE \
    --instances=backend-vm

# Définir le port nommé
gcloud compute instance-groups unmanaged set-named-ports backend-group \
    --zone=$ZONE \
    --named-ports=http:80
```

#### Exercice 5.6.3 : Créer l'Internal Load Balancer

```bash
# Health check
gcloud compute health-checks create http hc-backend \
    --port=80 \
    --request-path=/

# Backend service
gcloud compute backend-services create backend-service \
    --load-balancing-scheme=INTERNAL \
    --protocol=TCP \
    --region=$REGION \
    --health-checks=hc-backend \
    --health-checks-region=$REGION

gcloud compute backend-services add-backend backend-service \
    --region=$REGION \
    --instance-group=backend-group \
    --instance-group-zone=$ZONE

# Forwarding rule (Internal LB)
gcloud compute forwarding-rules create ilb-producer \
    --region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --network=$VPC_PRODUCER \
    --subnet=subnet-producer \
    --address=10.50.0.100 \
    --ip-protocol=TCP \
    --ports=80 \
    --backend-service=backend-service \
    --backend-service-region=$REGION

# Vérifier
gcloud compute forwarding-rules describe ilb-producer --region=$REGION
```

#### Exercice 5.6.4 : Créer le Service Attachment PSC

```bash
# Créer le Service Attachment
gcloud compute service-attachments create my-service-attachment \
    --region=$REGION \
    --producer-forwarding-rule=ilb-producer \
    --connection-preference=ACCEPT_AUTOMATIC \
    --nat-subnets=subnet-psc-nat \
    --description="Service exposé via PSC"

# Vérifier
gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION

# Récupérer l'URI du service attachment (nécessaire pour les consommateurs)
export SERVICE_ATTACHMENT_URI=$(gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION \
    --format="get(selfLink)")
echo "Service Attachment URI: $SERVICE_ATTACHMENT_URI"
```

**Questions :**
1. Pourquoi avons-nous besoin d'un sous-réseau avec `purpose=PRIVATE_SERVICE_CONNECT` ?
2. Quelle est la différence entre `ACCEPT_AUTOMATIC` et `ACCEPT_MANUAL` ?

---

## Lab 5.7 : PSC - Consommer un service (Consommateur)
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer un endpoint PSC vers un service publié
- Consommer le service depuis un VPC différent
- Comprendre le flux de trafic PSC

### Architecture complète

```
    VPC Consommateur                                    VPC Producteur
    ┌────────────────────────────┐                    ┌────────────────────────────┐
    │                            │                    │                            │
    │   subnet-consumer          │                    │   subnet-producer          │
    │   10.60.0.0/24             │                    │   10.50.0.0/24             │
    │                            │                    │                            │
    │   ┌───────────────┐        │                    │   ┌───────────────┐        │
    │   │  consumer-vm  │        │                    │   │  backend-vm   │        │
    │   │   10.60.0.10  │        │                    │   │   (nginx)     │        │
    │   └───────┬───────┘        │                    │   └───────────────┘        │
    │           │                │                    │           ▲                │
    │           ▼                │                    │           │                │
    │   ┌───────────────────┐    │     PSC          │   ┌───────────────┐        │
    │   │  PSC Endpoint     │────┼─────────────────►│   │  Service      │        │
    │   │  10.60.0.100      │    │                    │   │  Attachment   │        │
    │   └───────────────────┘    │                    │   └───────────────┘        │
    │                            │                    │                            │
    └────────────────────────────┘                    └────────────────────────────┘
```

### Exercices

#### Exercice 5.7.1 : Créer le VPC Consommateur

```bash
# VPC pour le consommateur
export VPC_CONSUMER="vpc-consumer"

gcloud compute networks create $VPC_CONSUMER \
    --subnet-mode=custom \
    --description="VPC du consommateur de service"

# Sous-réseau
gcloud compute networks subnets create subnet-consumer \
    --network=$VPC_CONSUMER \
    --region=$REGION \
    --range=10.60.0.0/24

# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_CONSUMER}-allow-internal \
    --network=$VPC_CONSUMER \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_CONSUMER}-allow-ssh-iap \
    --network=$VPC_CONSUMER \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
```

#### Exercice 5.7.2 : Réserver une IP pour l'endpoint PSC

```bash
# Réserver une IP pour l'endpoint
gcloud compute addresses create psc-consumer-endpoint \
    --region=$REGION \
    --subnet=subnet-consumer \
    --addresses=10.60.0.100

# Vérifier
gcloud compute addresses describe psc-consumer-endpoint --region=$REGION
```

#### Exercice 5.7.3 : Créer l'endpoint PSC vers le service du producteur

```bash
# Créer la forwarding rule PSC vers le Service Attachment
gcloud compute forwarding-rules create psc-to-producer \
    --region=$REGION \
    --network=$VPC_CONSUMER \
    --address=psc-consumer-endpoint \
    --target-service-attachment=$SERVICE_ATTACHMENT_URI

# Vérifier
gcloud compute forwarding-rules describe psc-to-producer --region=$REGION

# Voir l'état de la connexion côté producteur
gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION \
    --format="yaml(connectedEndpoints)"
```

#### Exercice 5.7.4 : Créer une VM consommateur et tester

```bash
# VM consommateur
gcloud compute instances create consumer-vm \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_CONSUMER \
    --subnet=subnet-consumer \
    --private-network-ip=10.60.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl'
```

#### Exercice 5.7.5 : Tester la connectivité via PSC

```bash
# Se connecter à la VM consommateur
gcloud compute ssh consumer-vm --zone=$ZONE --tunnel-through-iap

# Tester l'accès au service via l'endpoint PSC
curl http://10.60.0.100
# Devrait afficher: "Service du Producteur" avec le hostname et IP du backend

# Tester plusieurs fois pour voir la réponse
for i in {1..5}; do
    echo "=== Requête $i ==="
    curl -s http://10.60.0.100
    echo ""
done

exit
```

**Questions :**
1. Le consommateur connaît-il l'IP réelle du backend (10.50.0.10) ?
2. Le trafic traverse-t-il Internet entre les deux VPC ?

#### Exercice 5.7.6 : (Optionnel) Configurer DNS pour le service

```bash
# Créer une zone DNS privée pour le service
gcloud dns managed-zones create service-internal \
    --dns-name="service.internal." \
    --visibility=private \
    --networks=$VPC_CONSUMER

# Enregistrement A vers l'endpoint PSC
gcloud dns record-sets create "myapi.service.internal." \
    --zone=service-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.60.0.100"

# Tester depuis la VM
gcloud compute ssh consumer-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
nslookup myapi.service.internal
curl http://myapi.service.internal
EOF
```

---

## Lab 5.8 : Comparaison PGA vs PSA vs PSC
**Difficulté : ⭐⭐**

### Objectifs
- Comparer les trois solutions dans différents scénarios
- Choisir la bonne solution selon le contexte
- Documenter les avantages/inconvénients

### Exercices

#### Exercice 5.8.1 : Tableau comparatif complet

```bash
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║                    COMPARAISON PGA vs PSA vs PSC                                          ║
╠═══════════════════════════════════════════════════════════════════════════════════════════╣
║ Critère            │ PGA                 │ PSA                  │ PSC                     ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Cible principale   │ APIs Google         │ Services managés     │ APIs Google +           ║
║                    │ (Storage, BigQuery) │ (Cloud SQL, Redis)   │ Services tiers          ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Mécanisme          │ Routage vers IPs    │ VPC Peering avec     │ Endpoint privé dans     ║
║                    │ Google + DNS        │ VPC Google           │ votre VPC               ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ IP utilisée        │ IPs Google          │ IP dans plage        │ IP de votre             ║
║                    │ (199.36.153.x)      │ réservée (PSA)       │ sous-réseau             ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Configuration      │ Par sous-réseau     │ Par VPC              │ Par endpoint            ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Transitivité       │ Via routes + DNS    │ Nécessite export     │ Native                  ║
║ on-premise         │ on-premise          │ routes custom        │ (IP routable)           ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ VPC Service        │ restricted.         │ Supporté             │ Supporté                ║
║ Controls           │ googleapis.com      │                      │                         ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Isolation          │ Partagé             │ Partagé              │ Dédié par endpoint      ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Complexité         │ ⭐ Simple           │ ⭐⭐ Moyenne         │ ⭐⭐⭐ Avancée          ║
╠════════════════════╪═════════════════════╪══════════════════════╪═════════════════════════╣
║ Coût               │ Gratuit             │ Selon le service     │ Faible coût endpoint    ║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
EOF
```

#### Exercice 5.8.2 : Scénarios de décision

```bash
cat << 'EOF'
=== SCÉNARIOS ET RECOMMANDATIONS ===

SCÉNARIO 1: VMs GCP accédant à Cloud Storage
┌─────────────────────────────────────────────────────────────┐
│ Contexte: VMs sans IP externe, besoin d'accès Storage      │
│ Recommandation: PGA                                         │
│ Raison: Simple, gratuit, suffisant pour ce cas             │
└─────────────────────────────────────────────────────────────┘

SCÉNARIO 2: Application avec base de données Cloud SQL
┌─────────────────────────────────────────────────────────────┐
│ Contexte: App GKE/VMs connectée à Cloud SQL                │
│ Recommandation: PSA                                         │
│ Raison: Cloud SQL utilise PSA, IP privée automatique       │
└─────────────────────────────────────────────────────────────┘

SCÉNARIO 3: Accès aux APIs Google depuis datacenter on-premise
┌─────────────────────────────────────────────────────────────┐
│ Contexte: Serveurs on-prem via VPN/Interconnect            │
│ Recommandation: PSC                                         │
│ Raison: IP dans votre espace d'adressage, routable         │
└─────────────────────────────────────────────────────────────┘

SCÉNARIO 4: Service partagé entre équipes/organisations
┌─────────────────────────────────────────────────────────────┐
│ Contexte: API interne exposée à plusieurs consommateurs    │
│ Recommandation: PSC (Producteur/Consommateur)              │
│ Raison: Isolation, contrôle, pas de VPC Peering            │
└─────────────────────────────────────────────────────────────┘

SCÉNARIO 5: Conformité VPC Service Controls
┌─────────────────────────────────────────────────────────────┐
│ Contexte: Données sensibles, périmètre de sécurité         │
│ Recommandation: PSC avec bundle vpc-sc                      │
│ Raison: Contrôle strict, compatibilité VPC-SC              │
└─────────────────────────────────────────────────────────────┘
EOF
```

#### Exercice 5.8.3 : Arbre de décision

```
                    ┌─────────────────────────────────────┐
                    │ Quel type de service accédez-vous ? │
                    └─────────────────┬───────────────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
              ▼                       ▼                       ▼
    ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
    │ APIs Google     │     │ Services managés│     │ Services tiers/ │
    │ (Storage, BQ)   │     │ (SQL, Redis)    │     │ personnalisés   │
    └────────┬────────┘     └────────┬────────┘     └────────┬────────┘
             │                       │                       │
             ▼                       │                       │
    ┌─────────────────┐              │                       │
    │ Accès depuis    │              │                       │
    │ on-premise ?    │              │                       │
    └────────┬────────┘              │                       │
             │                       │                       │
      ┌──────┴──────┐                │                       │
      │             │                │                       │
      ▼             ▼                ▼                       ▼
   ┌─────┐       ┌─────┐          ┌─────┐               ┌─────┐
   │ OUI │       │ NON │          │ PSA │               │ PSC │
   └──┬──┘       └──┬──┘          └─────┘               │Prod/│
      │             │                                    │Cons │
      ▼             ▼                                    └─────┘
   ┌─────┐       ┌─────┐
   │ PSC │       │ PGA │
   │APIs │       │     │
   └─────┘       └─────┘
```

---

## Lab 5.9 : Scénario intégrateur - Architecture hybride sécurisée
**Difficulté : ⭐⭐⭐**

### Objectifs
- Combiner toutes les solutions de connectivité privée
- Créer une architecture enterprise complète
- Sécuriser les accès avec les bonnes pratiques

### Architecture cible

```
                                      ┌─────────────────────────┐
                                      │     APIs Google         │
                                      │  (Storage, BigQuery)    │
                                      └───────────┬─────────────┘
                                                  │
                                                  │ PSC Endpoint
                                                  │
    ┌─────────────────────────────────────────────┴──────────────────────────────────────┐
    │                                    VPC Hub                                         │
    │                                                                                    │
    │   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐            │
    │   │  subnet-psc      │    │  subnet-app      │    │  subnet-data     │            │
    │   │  10.0.1.0/24     │    │  10.0.2.0/24     │    │  10.0.3.0/24     │            │
    │   │                  │    │                  │    │                  │            │
    │   │ ┌──────────────┐ │    │ ┌──────────────┐ │    │                  │            │
    │   │ │PSC Endpoint  │ │    │ │   App VMs    │ │    │   Cloud SQL      │◄── PSA     │
    │   │ │10.0.1.100    │ │    │ │              │ │    │   Memorystore    │            │
    │   │ └──────────────┘ │    │ └──────────────┘ │    │                  │            │
    │   └──────────────────┘    └──────────────────┘    └──────────────────┘            │
    │                                    │                                              │
    │   PGA: Enabled ✓                   │                                              │
    │   DNS: Configuré pour PSC          │                                              │
    │   Firewall: Egress restreint       │                                              │
    │                                    │                                              │
    └────────────────────────────────────┴──────────────────────────────────────────────┘
```

### Exercice : Déploiement complet

```bash
#!/bin/bash
# Script de déploiement de l'architecture hybride sécurisée

set -e

export PROJECT_ID=$(gcloud config get-value project)
export VPC_HUB="vpc-hub-secure"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=== 1. Création du VPC Hub ==="
gcloud compute networks create $VPC_HUB \
    --subnet-mode=custom \
    --description="VPC Hub avec connectivité privée complète"

echo "=== 2. Création des sous-réseaux ==="
# Sous-réseau pour PSC
gcloud compute networks subnets create subnet-psc \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access

# Sous-réseau pour les applications
gcloud compute networks subnets create subnet-app \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access

# Sous-réseau pour les données (utilisé par PSA)
gcloud compute networks subnets create subnet-data \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.3.0/24 \
    --enable-private-ip-google-access

echo "=== 3. Configuration PSA ==="
# Réserver une plage pour PSA
gcloud compute addresses create psa-range \
    --global \
    --purpose=VPC_PEERING \
    --addresses=10.100.0.0 \
    --prefix-length=20 \
    --network=$VPC_HUB

# Créer la connexion PSA
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=psa-range \
    --network=$VPC_HUB

echo "=== 4. Configuration PSC pour APIs Google ==="
# Réserver IP pour endpoint PSC
gcloud compute addresses create psc-apis \
    --region=$REGION \
    --subnet=subnet-psc \
    --addresses=10.0.1.100

# Créer endpoint PSC
gcloud compute forwarding-rules create psc-googleapis \
    --region=$REGION \
    --network=$VPC_HUB \
    --address=psc-apis \
    --target-google-apis-bundle=all-apis

echo "=== 5. Configuration DNS ==="
# Zone DNS pour googleapis.com
gcloud dns managed-zones create googleapis-hub \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_HUB

# Enregistrements DNS vers PSC
for API in storage www bigquery pubsub; do
    gcloud dns record-sets create "${API}.googleapis.com." \
        --zone=googleapis-hub \
        --type=A \
        --ttl=300 \
        --rrdatas="10.0.1.100"
done

echo "=== 6. Règles de pare-feu sécurisées ==="
# Bloquer tout trafic sortant par défaut
gcloud compute firewall-rules create ${VPC_HUB}-deny-egress-all \
    --network=$VPC_HUB \
    --direction=EGRESS \
    --action=DENY \
    --rules=all \
    --destination-ranges=0.0.0.0/0 \
    --priority=65534

# Autoriser egress vers PSC endpoint
gcloud compute firewall-rules create ${VPC_HUB}-allow-egress-psc \
    --network=$VPC_HUB \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=tcp:443 \
    --destination-ranges=10.0.1.100/32 \
    --priority=1000

# Autoriser egress vers PSA (services managés)
gcloud compute firewall-rules create ${VPC_HUB}-allow-egress-psa \
    --network=$VPC_HUB \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=tcp:5432,tcp:6379,tcp:3306 \
    --destination-ranges=10.100.0.0/20 \
    --priority=1000

# Autoriser trafic interne
gcloud compute firewall-rules create ${VPC_HUB}-allow-internal \
    --network=$VPC_HUB \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

# Autoriser SSH via IAP
gcloud compute firewall-rules create ${VPC_HUB}-allow-ssh-iap \
    --network=$VPC_HUB \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# Autoriser health checks
gcloud compute firewall-rules create ${VPC_HUB}-allow-health-checks \
    --network=$VPC_HUB \
    --allow=tcp:80,tcp:443 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22

echo "=== 7. Déploiement des VMs ==="
# VM applicative
gcloud compute instances create app-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_HUB \
    --subnet=subnet-app \
    --no-address \
    --scopes=storage-ro,logging-write,monitoring-write \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils postgresql-client redis-tools'

echo "=== 8. (Optionnel) Cloud SQL avec PSA ==="
# Décommenter pour créer Cloud SQL
# gcloud sql instances create sql-secure \
#     --database-version=POSTGRES_14 \
#     --tier=db-f1-micro \
#     --region=$REGION \
#     --network=$VPC_HUB \
#     --no-assign-ip

echo "=== Déploiement terminé ==="
echo ""
echo "Architecture déployée:"
echo "- VPC: $VPC_HUB"
echo "- PSC Endpoint: 10.0.1.100 (APIs Google)"
echo "- PSA Range: 10.100.0.0/20 (Services managés)"
echo "- Egress: Restreint aux services autorisés uniquement"
```

### Tests de validation

```bash
# Test 1: Vérifier que la VM peut accéder à Cloud Storage via PSC
gcloud compute ssh app-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test DNS ==="
nslookup storage.googleapis.com
echo ""
echo "=== Test accès Storage ==="
gsutil ls gs://gcp-public-data-landsat | head -3
EOF

# Test 2: Vérifier que l'accès Internet direct est bloqué
gcloud compute ssh app-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test accès Internet (devrait échouer) ==="
curl -v --connect-timeout 5 https://www.github.com 2>&1 | head -10
EOF
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage de toutes les ressources des labs du Module 5

echo "=== Suppression des VMs ==="
for VM in vm-pga vm-psc vm-sql-client app-vm backend-vm consumer-vm; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des instance groups ==="
gcloud compute instance-groups unmanaged delete backend-group \
    --zone=europe-west1-b --quiet 2>/dev/null

echo "=== Suppression des forwarding rules PSC ==="
for FR in psc-endpoint-all-apis psc-to-producer psc-googleapis ilb-producer; do
    gcloud compute forwarding-rules delete $FR --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des service attachments ==="
gcloud compute service-attachments delete my-service-attachment \
    --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des backend services ==="
gcloud compute backend-services delete backend-service \
    --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des health checks ==="
gcloud compute health-checks delete hc-backend --quiet 2>/dev/null

echo "=== Suppression des adresses réservées ==="
for ADDR in psc-apis-endpoint psc-consumer-endpoint google-managed-services psa-range psc-apis; do
    gcloud compute addresses delete $ADDR --region=europe-west1 --quiet 2>/dev/null
    gcloud compute addresses delete $ADDR --global --quiet 2>/dev/null
done

echo "=== Suppression des instances Cloud SQL ==="
gcloud sql instances delete sql-private --quiet 2>/dev/null
gcloud sql instances delete sql-secure --quiet 2>/dev/null

echo "=== Suppression des instances Memorystore ==="
gcloud redis instances delete redis-private --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des zones DNS ==="
for ZONE in googleapis-private googleapis-psc service-internal googleapis-hub; do
    # Supprimer les enregistrements d'abord
    for RS in $(gcloud dns record-sets list --zone=$ZONE \
                --format="get(name,type)" 2>/dev/null | grep -v "SOA\|NS"); do
        NAME=$(echo $RS | cut -d' ' -f1)
        TYPE=$(echo $RS | cut -d' ' -f2)
        gcloud dns record-sets delete "$NAME" --zone=$ZONE --type=$TYPE --quiet 2>/dev/null
    done
    gcloud dns managed-zones delete $ZONE --quiet 2>/dev/null
done

echo "=== Suppression des connexions PSA ==="
gcloud services vpc-peerings delete \
    --service=servicenetworking.googleapis.com \
    --network=vpc-private-access --quiet 2>/dev/null

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-private-access vpc-producer vpc-consumer vpc-hub-secure; do
    for RULE in $(gcloud compute firewall-rules list \
                  --filter="network:$VPC" --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
    done
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-pga subnet-app subnet-psc subnet-data subnet-producer \
              subnet-psc-nat subnet-consumer; do
    gcloud compute networks subnets delete $SUBNET \
        --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in vpc-private-access vpc-producer vpc-consumer vpc-hub-secure; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 5

### Private Google Access
```bash
# Activer PGA
gcloud compute networks subnets update SUBNET --region=REGION --enable-private-google-access

# Vérifier PGA
gcloud compute networks subnets describe SUBNET --region=REGION --format="get(privateIpGoogleAccess)"
```

### Private Services Access
```bash
# Réserver plage IP
gcloud compute addresses create NAME --global --purpose=VPC_PEERING --addresses=IP --prefix-length=N --network=VPC

# Créer connexion PSA
gcloud services vpc-peerings connect --service=servicenetworking.googleapis.com --ranges=NAME --network=VPC

# Lister connexions
gcloud services vpc-peerings list --network=VPC
```

### Private Service Connect
```bash
# Endpoint vers APIs Google
gcloud compute forwarding-rules create NAME --region=REGION --network=VPC --address=ADDR --target-google-apis-bundle=all-apis

# Service Attachment (producteur)
gcloud compute service-attachments create NAME --region=REGION --producer-forwarding-rule=ILB --nat-subnets=SUBNET --connection-preference=ACCEPT_AUTOMATIC

# Endpoint vers service (consommateur)
gcloud compute forwarding-rules create NAME --region=REGION --network=VPC --address=ADDR --target-service-attachment=URI
```
