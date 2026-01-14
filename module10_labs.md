# Module 10 - Équilibrage de Charge et Gestion du Trafic
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Comprendre et choisir le bon type de Load Balancer
- Déployer des Application Load Balancers (externes et internes)
- Configurer le routage avancé avec URL Maps
- Implémenter des déploiements Canary et Blue-Green
- Configurer la session affinity
- Déployer des Network Load Balancers (L4)
- Créer des architectures hybrides avec Hybrid NEGs
- Optimiser les performances avec Cloud CDN
- Configurer les signed URLs pour le contenu protégé

### Prérequis
- Modules 1 à 9 complétés
- Projet GCP avec facturation activée
- Droits : roles/compute.loadBalancerAdmin, roles/compute.networkAdmin
- (Optionnel) Un domaine pour les certificats HTTPS managés

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 10.1 | Vue d'ensemble des Load Balancers GCP | ⭐ |
| 10.2 | Global External Application LB - Configuration complète | ⭐⭐ |
| 10.3 | URL Maps et routage avancé | ⭐⭐ |
| 10.4 | Gestion du trafic - Canary et Blue-Green | ⭐⭐⭐ |
| 10.5 | Session Affinity et persistance | ⭐⭐ |
| 10.6 | Internal Application Load Balancer | ⭐⭐ |
| 10.7 | Network Load Balancer (L4) | ⭐⭐ |
| 10.8 | Équilibrage hybride avec Hybrid NEG | ⭐⭐⭐ |
| 10.9 | Network Endpoint Groups (NEGs) | ⭐⭐ |
| 10.10 | Cloud CDN - Configuration et optimisation | ⭐⭐ |
| 10.11 | Cloud CDN - Signed URLs et contenu protégé | ⭐⭐⭐ |
| 10.12 | Scénario intégrateur - Architecture multi-tier | ⭐⭐⭐ |

---

## Lab 10.1 : Vue d'ensemble des Load Balancers GCP
**Difficulté : ⭐**

### Objectifs
- Comprendre les différents types de Load Balancers
- Savoir choisir le bon LB pour chaque cas d'usage
- Comprendre les modes Proxy vs Passthrough

### Exercices

#### Exercice 10.1.1 : Panorama des Load Balancers

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                     PANORAMA DES LOAD BALANCERS GCP                            ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║   LAYER 7 (APPLICATION) - HTTP/HTTPS/HTTP2/gRPC                                ║
║   ─────────────────────────────────────────────────────────────────────────────║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Global External Application LB                                          │   ║
║  │ • Portée: Globale (Anycast IP)                                          │   ║
║  │ • Trafic: Externe (Internet)                                            │   ║
║  │ • Usage: Web apps mondiales, APIs publiques                             │   ║
║  │ • Fonctionnalités: CDN, Cloud Armor, IAP, routage URL                   │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Regional External Application LB                                        │   ║
║  │ • Portée: Régionale                                                     │   ║
║  │ • Trafic: Externe (Internet)                                            │   ║
║  │ • Usage: Apps régionales, conformité data residency                     │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Internal Application LB                                                 │   ║
║  │ • Portée: Régionale                                                     │   ║
║  │ • Trafic: Interne (VPC)                                                 │   ║
║  │ • Usage: Microservices, APIs internes                                   │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Cross-Region Internal Application LB                                    │   ║
║  │ • Portée: Globale                                                       │   ║
║  │ • Trafic: Interne (VPC)                                                 │   ║
║  │ • Usage: Microservices multi-régions                                    │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║  LAYER 4 (NETWORK) - TCP/UDP/SSL                                               ║
║  ───────────────────────────────────────────────────────────────────────────── ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Global External Proxy Network LB                                        │   ║
║  │ • Mode: Proxy                                                           │   ║
║  │ • Portée: Globale                                                       │   ║
║  │ • Usage: TCP/SSL global (non-HTTP)                                      │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Regional External Passthrough Network LB                                │   ║
║  │ • Mode: Passthrough (DSR)                                               │   ║
║  │ • Portée: Régionale                                                     │   ║
║  │ • Usage: Jeux, VoIP, performance max                                    │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ┌─────────────────────────────────────────────────────────────────────────┐   ║
║  │ Regional Internal Passthrough Network LB                                │   ║
║  │ • Mode: Passthrough                                                     │   ║
║  │ • Portée: Régionale                                                     │   ║
║  │ • Usage: Bases de données, services L4 internes                         │   ║
║  └─────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

#### Exercice 10.1.2 : Proxy vs Passthrough

```
═══════════════════════════════════════════════════════════════════════════════
                         MODE PROXY vs PASSTHROUGH
═══════════════════════════════════════════════════════════════════════════════

MODE PROXY
──────────────────────────────────────────────────────────────────────────────
Client ──────► Load Balancer ──────► Backend
        Conn 1    (termine)    Conn 2

• Le LB termine la connexion client
• Nouvelle connexion vers le backend
• L'IP client n'est pas préservée (utiliser X-Forwarded-For)
• Fonctionnalités avancées : TLS termination, routage L7, Cloud Armor

Avantages:                        Inconvénients:
✅ Fonctionnalités L7             ❌ Latence légèrement plus élevée
✅ TLS offload                    ❌ IP client non préservée nativement
✅ Protection avancée             ❌ Plus de ressources LB
✅ Routage intelligent


MODE PASSTHROUGH (DSR - Direct Server Return)
──────────────────────────────────────────────────────────────────────────────
Client ──────► Load Balancer ──────► Backend
        │                            │
        └────────────────────────────┘
              Réponse directe

• Le LB transmet les paquets sans modification
• Le backend répond directement au client
• L'IP client est préservée
• Pas de fonctionnalités L7

Avantages:                        Inconvénients:
✅ Latence minimale               ❌ Pas de fonctionnalités L7
✅ IP client préservée            ❌ Pas de TLS termination
✅ Performance maximale           ❌ Pas de Cloud Armor
✅ Moins de ressources LB         ❌ Configuration backend spécifique
```

#### Exercice 10.1.3 : Arbre de décision

```
═══════════════════════════════════════════════════════════════════════════════
                    ARBRE DE DÉCISION - QUEL LOAD BALANCER ?
═══════════════════════════════════════════════════════════════════════════════

                              Début
                                │
                                ▼
                    ┌───────────────────────┐
                    │ Trafic HTTP/HTTPS ?   │
                    └───────────┬───────────┘
                          │           │
                         Oui         Non
                          │           │
                          ▼           ▼
              ┌───────────────┐   ┌───────────────┐
              │ Trafic externe│   │ Besoin perf   │
              │ ou interne ?  │   │ maximale ?    │
              └───────┬───────┘   └───────┬───────┘
                │         │         │         │
             Externe   Interne    Oui        Non
                │         │         │         │
                ▼         ▼         ▼         ▼
        ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
        │ Audience  │ │ Multi-    │ │Passthrough│ │  Proxy    │
        │ globale ? │ │ région ?  │ │Network LB │ │Network LB │
        └─────┬─────┘ └─────┬─────┘ └───────────┘ └───────────┘
          │       │     │       │
         Oui     Non   Oui     Non
          │       │     │       │
          ▼       ▼     ▼       ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ Global  │ │Regional │ │Cross-   │ │Internal │
    │External │ │External │ │Region   │ │ App LB  │
    │ App LB  │ │ App LB  │ │Int. LB  │ │         │
    └─────────┘ └─────────┘ └─────────┘ └─────────┘


RÉSUMÉ RAPIDE:
──────────────────────────────────────────────────────────────────────────────
• Web app globale          → Global External Application LB
• API interne              → Internal Application LB
• Jeux, VoIP, streaming    → Regional Passthrough Network LB
• Base de données interne  → Internal Passthrough Network LB
• Microservices multi-reg  → Cross-Region Internal Application LB
```

---

## Lab 10.2 : Global External Application LB - Configuration complète
**Difficulté : ⭐⭐**

### Objectifs
- Créer un Application Load Balancer global
- Comprendre tous les composants
- Configurer les health checks et backends

### Architecture cible

```
                              Internet
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Forwarding Rule      │
                    │    (IP Anycast)         │
                    │    Ports: 80, 443       │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │    Target HTTP(S)       │
                    │    Proxy                │
                    │    (TLS Termination)    │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │       URL Map           │
                    │                         │
                    │  /api/* → backend-api   │
                    │  /static/* → bucket     │
                    │  /* → backend-web       │
                    └───────────┬─────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
         ▼                      ▼                      ▼
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ Backend Service │   │ Backend Service │   │  Backend Bucket │
│   backend-web   │   │   backend-api   │   │  bucket-static  │
│                 │   │                 │   │                 │
│ ┌─────────────┐ │   │ ┌─────────────┐ │   │   Cloud Storage │
│ │Instance Grp │ │   │ │Instance Grp │ │   │                 │
│ │  ig-web     │ │   │ │  ig-api     │ │   │                 │
│ └─────────────┘ │   │ └─────────────┘ │   │                 │
└─────────────────┘   └─────────────────┘   └─────────────────┘
```

### Exercices

#### Exercice 10.2.1 : Créer l'infrastructure de base

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC
gcloud compute networks create vpc-lb-lab \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-web \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.1.0/24

# Règles de pare-feu
gcloud compute firewall-rules create vpc-lb-lab-allow-health-check \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=web-server

gcloud compute firewall-rules create vpc-lb-lab-allow-iap \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20
```

#### Exercice 10.2.2 : Créer les Instance Templates et Groups

```bash
# Template pour le frontend web
gcloud compute instance-templates create web-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
HOSTNAME=$(hostname)
ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>Web Server</title></head>
<body>
<h1>Frontend Web Server</h1>
<p>Hostname: $HOSTNAME</p>
<p>Zone: $ZONE</p>
<p>Version: v1</p>
</body>
</html>
EOF
mkdir -p /var/www/html/health
echo "OK" > /var/www/html/health/index.html
systemctl restart nginx'

# Template pour l'API
gcloud compute instance-templates create api-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
HOSTNAME=$(hostname)
cat > /var/www/html/index.html << EOF
{"service": "api", "hostname": "$HOSTNAME", "version": "v1"}
EOF
mkdir -p /var/www/html/health /var/www/html/api
echo "OK" > /var/www/html/health/index.html
echo "{\"status\": \"ok\", \"service\": \"api\"}" > /var/www/html/api/index.html
systemctl restart nginx'

# Créer les Managed Instance Groups
gcloud compute instance-groups managed create ig-web \
    --template=web-template \
    --size=2 \
    --zone=$ZONE

gcloud compute instance-groups managed create ig-api \
    --template=api-template \
    --size=2 \
    --zone=$ZONE

# Configurer les named ports
gcloud compute instance-groups managed set-named-ports ig-web \
    --zone=$ZONE \
    --named-ports=http:80

gcloud compute instance-groups managed set-named-ports ig-api \
    --zone=$ZONE \
    --named-ports=http:80
```

#### Exercice 10.2.3 : Créer les Health Checks

```bash
# Health check pour le web
gcloud compute health-checks create http hc-web \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

# Health check pour l'API
gcloud compute health-checks create http hc-api \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3
```

#### Exercice 10.2.4 : Créer les Backend Services

```bash
# Backend service pour le web
gcloud compute backend-services create backend-web \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global

gcloud compute backend-services add-backend backend-web \
    --instance-group=ig-web \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global

# Backend service pour l'API
gcloud compute backend-services create backend-api \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-api \
    --global

gcloud compute backend-services add-backend backend-api \
    --instance-group=ig-api \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global
```

#### Exercice 10.2.5 : Créer le bucket pour le contenu statique

```bash
# Créer le bucket
gsutil mb -l $REGION gs://${PROJECT_ID}-static-content

# Ajouter du contenu
echo "body { font-family: Arial; }" | gsutil cp - gs://${PROJECT_ID}-static-content/style.css
echo "console.log('Hello');" | gsutil cp - gs://${PROJECT_ID}-static-content/app.js

# Rendre public
gsutil iam ch allUsers:objectViewer gs://${PROJECT_ID}-static-content

# Créer le backend bucket
gcloud compute backend-buckets create bucket-static \
    --gcs-bucket-name=${PROJECT_ID}-static-content
```

#### Exercice 10.2.6 : Créer l'URL Map

```bash
# URL Map avec routage
gcloud compute url-maps create urlmap-app \
    --default-service=backend-web

# Path matcher pour l'API
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=api-matcher \
    --default-service=backend-api \
    --path-rules="/api/*=backend-api"

gcloud compute url-maps add-host-rule urlmap-app \
    --hosts="*" \
    --path-matcher-name=api-matcher

# Ajouter le routage pour le contenu statique
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=static-matcher \
    --default-service=backend-web \
    --backend-bucket-path-rules="/static/*=bucket-static"
```

#### Exercice 10.2.7 : Créer le Frontend (HTTP)

```bash
# Réserver une IP externe
gcloud compute addresses create lb-ip-global \
    --ip-version=IPV4 \
    --global

LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"

# Target HTTP proxy
gcloud compute target-http-proxies create proxy-http-app \
    --url-map=urlmap-app

# Forwarding rule HTTP
gcloud compute forwarding-rules create fr-http-app \
    --address=lb-ip-global \
    --target-http-proxy=proxy-http-app \
    --ports=80 \
    --global

echo "Load Balancer accessible sur: http://$LB_IP"
```

#### Exercice 10.2.8 : Tester le Load Balancer

```bash
# Attendre que les backends soient healthy
echo "Attente des backends (60s)..."
sleep 60

# Vérifier la santé des backends
gcloud compute backend-services get-health backend-web --global
gcloud compute backend-services get-health backend-api --global

# Tester les différentes routes
echo "=== Test Frontend ==="
curl -s http://$LB_IP/

echo -e "\n=== Test API ==="
curl -s http://$LB_IP/api/

echo -e "\n=== Test Static ==="
curl -s http://$LB_IP/static/style.css
```

---

## Lab 10.3 : URL Maps et routage avancé
**Difficulté : ⭐⭐**

### Objectifs
- Configurer le routage basé sur le host
- Implémenter le routage par path
- Utiliser les headers pour le routage

### Exercices

#### Exercice 10.3.1 : Routage par Host

```
═══════════════════════════════════════════════════════════════════════════════
                           ROUTAGE PAR HOST
═══════════════════════════════════════════════════════════════════════════════

                        ┌─────────────────────┐
                        │      URL Map        │
                        └─────────┬───────────┘
                                  │
           ┌──────────────────────┼──────────────────────┐
           │                      │                      │
           ▼                      ▼                      ▼
    www.example.com       api.example.com       admin.example.com
           │                      │                      │
           ▼                      ▼                      ▼
    ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
    │ backend-web  │      │ backend-api  │      │backend-admin │
    └──────────────┘      └──────────────┘      └──────────────┘
```

```bash
# Créer un URL Map avec routage par host
gcloud compute url-maps create urlmap-multihost \
    --default-service=backend-web

# Ajouter les host rules
gcloud compute url-maps add-path-matcher urlmap-multihost \
    --path-matcher-name=www-matcher \
    --default-service=backend-web

gcloud compute url-maps add-host-rule urlmap-multihost \
    --hosts="www.example.com,example.com" \
    --path-matcher-name=www-matcher

gcloud compute url-maps add-path-matcher urlmap-multihost \
    --path-matcher-name=api-matcher \
    --default-service=backend-api

gcloud compute url-maps add-host-rule urlmap-multihost \
    --hosts="api.example.com" \
    --path-matcher-name=api-matcher
```

#### Exercice 10.3.2 : Routage par Path avancé

```bash
# URL Map avec paths multiples
gcloud compute url-maps create urlmap-paths \
    --default-service=backend-web

# Créer un path matcher complexe
gcloud compute url-maps add-path-matcher urlmap-paths \
    --path-matcher-name=complex-matcher \
    --default-service=backend-web \
    --path-rules="/api/v1/*=backend-api,/api/v2/*=backend-api,/static/*=bucket-static,/images/*=bucket-static"

gcloud compute url-maps add-host-rule urlmap-paths \
    --hosts="*" \
    --path-matcher-name=complex-matcher
```

#### Exercice 10.3.3 : Configuration YAML avancée

```bash
# Exporter l'URL Map actuel
gcloud compute url-maps export urlmap-app \
    --destination=urlmap-export.yaml \
    --global

# Afficher la structure
cat urlmap-export.yaml

# Créer une configuration avancée
cat > urlmap-advanced.yaml << 'EOF'
name: urlmap-advanced
defaultService: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-web
hostRules:
- hosts:
  - "*"
  pathMatcher: main-matcher
pathMatchers:
- name: main-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-web
  routeRules:
  # Route basée sur le header
  - priority: 1
    matchRules:
    - prefixMatch: /api
      headerMatches:
      - headerName: X-API-Version
        exactMatch: "v2"
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-api-v2
  # Route par défaut pour /api
  - priority: 2
    matchRules:
    - prefixMatch: /api
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-api
  # Contenu statique
  - priority: 3
    matchRules:
    - prefixMatch: /static
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendBuckets/bucket-static
EOF

# Remplacer PROJECT_ID
sed -i "s/PROJECT_ID/$PROJECT_ID/g" urlmap-advanced.yaml
```

#### Exercice 10.3.4 : URL Rewrite

```
═══════════════════════════════════════════════════════════════════════════════
                              URL REWRITE
═══════════════════════════════════════════════════════════════════════════════

Avant:  Client demande /old-api/users
Après:  Backend reçoit /api/v2/users

Configuration YAML:
routeRules:
- priority: 1
  matchRules:
  - prefixMatch: /old-api/
  routeAction:
    urlRewrite:
      pathPrefixRewrite: /api/v2/
    weightedBackendServices:
    - backendService: backend-api
      weight: 100
```

---

## Lab 10.4 : Gestion du trafic - Canary et Blue-Green
**Difficulté : ⭐⭐⭐**

### Objectifs
- Implémenter un déploiement Canary avec traffic splitting
- Configurer un déploiement Blue-Green
- Utiliser le routage basé sur les headers

### Architecture Canary

```
                              Internet
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       URL Map           │
                    │    Traffic Splitting    │
                    └───────────┬─────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼ 90%                   ▼ 10%
            ┌───────────────┐       ┌───────────────┐
            │  backend-v1   │       │  backend-v2   │
            │  (stable)     │       │  (canary)     │
            └───────────────┘       └───────────────┘
```

### Exercices

#### Exercice 10.4.1 : Créer les backends v1 et v2

```bash
# Template v1 (stable)
gcloud compute instance-templates create web-template-v1 \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>App v1</title>
<style>body{background-color:#e8f5e9;font-family:Arial;text-align:center;padding-top:50px;}</style>
</head>
<body>
<h1 style="color:#2e7d32;">Version 1 (Stable)</h1>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF
echo "OK" > /var/www/html/health
systemctl restart nginx'

# Template v2 (canary)
gcloud compute instance-templates create web-template-v2 \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>App v2</title>
<style>body{background-color:#e3f2fd;font-family:Arial;text-align:center;padding-top:50px;}</style>
</head>
<body>
<h1 style="color:#1565c0;">Version 2 (Canary)</h1>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF
echo "OK" > /var/www/html/health
systemctl restart nginx'

# Instance groups
gcloud compute instance-groups managed create ig-v1 \
    --template=web-template-v1 \
    --size=2 \
    --zone=$ZONE

gcloud compute instance-groups managed create ig-v2 \
    --template=web-template-v2 \
    --size=1 \
    --zone=$ZONE

# Named ports
gcloud compute instance-groups managed set-named-ports ig-v1 \
    --zone=$ZONE --named-ports=http:80

gcloud compute instance-groups managed set-named-ports ig-v2 \
    --zone=$ZONE --named-ports=http:80

# Backend services
gcloud compute backend-services create backend-v1 \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global

gcloud compute backend-services add-backend backend-v1 \
    --instance-group=ig-v1 \
    --instance-group-zone=$ZONE \
    --global

gcloud compute backend-services create backend-v2 \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global

gcloud compute backend-services add-backend backend-v2 \
    --instance-group=ig-v2 \
    --instance-group-zone=$ZONE \
    --global
```

#### Exercice 10.4.2 : Configurer le Traffic Splitting (Canary)

```
# Créer un URL Map avec traffic splitting
cat > urlmap-canary.yaml << EOF
name: urlmap-canary
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: canary-matcher
pathMatchers:
- name: canary-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
        weight: 90
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
        weight: 10
EOF
```

```bash
gcloud compute url-maps import urlmap-canary \
    --source=urlmap-canary.yaml \
    --global

# Mettre à jour le proxy pour utiliser le nouvel URL Map
gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-canary
```

#### Exercice 10.4.3 : Tester le Traffic Splitting

```bash
# Tester la distribution (environ 90% v1, 10% v2)
echo "Test de distribution du trafic (20 requêtes)..."

V1_COUNT=0
V2_COUNT=0

for i in {1..20}; do
    RESPONSE=$(curl -s http://$LB_IP/ | grep -o "Version [12]")
    if [[ "$RESPONSE" == "Version 1" ]]; then
        ((V1_COUNT++))
    else
        ((V2_COUNT++))
    fi
done

echo "Résultats:"
echo "  Version 1 (stable): $V1_COUNT requêtes"
echo "  Version 2 (canary): $V2_COUNT requêtes"
```

#### Exercice 10.4.4 : Augmenter progressivement le trafic Canary

```bash
# Fonction pour mettre à jour les poids
update_weights() {
    V1_WEIGHT=$1
    V2_WEIGHT=$2
    
    cat > urlmap-canary.yaml << EOF
name: urlmap-canary
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: canary-matcher
pathMatchers:
- name: canary-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
        weight: $V1_WEIGHT
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
        weight: $V2_WEIGHT
EOF

    gcloud compute url-maps import urlmap-canary \
        --source=urlmap-canary.yaml \
        --global --quiet
    
    echo "Poids mis à jour: v1=$V1_WEIGHT%, v2=$V2_WEIGHT%"
}

# Progression Canary
echo "=== Phase 1: 90/10 ==="
update_weights 90 10

echo "=== Phase 2: 50/50 ==="
update_weights 50 50

echo "=== Phase 3: 10/90 ==="
update_weights 10 90

echo "=== Phase 4: 0/100 (rollout complet) ==="
update_weights 0 100
```

#### Exercice 10.4.5 : Déploiement Blue-Green

```
═══════════════════════════════════════════════════════════════════════════════
                         DÉPLOIEMENT BLUE-GREEN
═══════════════════════════════════════════════════════════════════════════════

Principe:
- Deux environnements identiques: Blue (actuel) et Green (nouveau)
- Le switch est instantané (changement de backend par défaut)
- Rollback rapide en cas de problème

                     AVANT                           APRÈS
              ┌───────────────┐               ┌───────────────┐
   Traffic ──►│     BLUE      │    Traffic ──►│     GREEN     │
              │   (actif)     │               │   (actif)     │
              └───────────────┘               └───────────────┘
              ┌───────────────┐               ┌───────────────┐
              │     GREEN     │               │     BLUE      │
              │   (standby)   │               │   (standby)   │
              └───────────────┘               └───────────────┘
```

```bash
# Switch vers Green (v2)
gcloud compute url-maps set-default-service urlmap-canary \
    --default-service=backend-v2 \
    --global

echo "Trafic redirigé vers backend-v2 (Green)"

# Vérifier
curl -s http://$LB_IP/ | grep "Version"

# Rollback vers Blue (v1) si problème
gcloud compute url-maps set-default-service urlmap-canary \
    --default-service=backend-v1 \
    --global

echo "Rollback vers backend-v1 (Blue)"
```

#### Exercice 10.4.6 : Routage basé sur les Headers (Beta users)

```bash
# Configurer le routage par header pour les beta testers
cat > urlmap-header-routing.yaml << EOF
name: urlmap-header-routing
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: header-matcher
pathMatchers:
- name: header-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  # Les utilisateurs beta (header X-Beta-User: true) vont vers v2
  - priority: 1
    matchRules:
    - prefixMatch: /
      headerMatches:
      - headerName: X-Beta-User
        exactMatch: "true"
    service: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
  # Tous les autres vont vers v1
  - priority: 2
    matchRules:
    - prefixMatch: /
    service: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
EOF

gcloud compute url-maps import urlmap-header-routing \
    --source=urlmap-header-routing.yaml \
    --global

gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-header-routing

# Tester
echo "=== Utilisateur normal (v1) ==="
curl -s http://$LB_IP/ | grep "Version"

echo "=== Utilisateur beta (v2) ==="
curl -s -H "X-Beta-User: true" http://$LB_IP/ | grep "Version"
```

---

## Lab 10.5 : Session Affinity et persistance
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre les types de session affinity
- Configurer l'affinité par cookie
- Tester la persistance de session

### Exercices

#### Exercice 10.5.1 : Types de Session Affinity

```
═══════════════════════════════════════════════════════════════════════════════
                        TYPES DE SESSION AFFINITY
═══════════════════════════════════════════════════════════════════════════════

Type              │ Mécanisme                    │ Cas d'usage
──────────────────┼──────────────────────────────┼─────────────────────────────
NONE              │ Pas d'affinité               │ Apps stateless
CLIENT_IP         │ Hash de l'IP client          │ Apps simples sans proxy
GENERATED_COOKIE  │ Cookie généré par le LB      │ Sessions web
HEADER_FIELD      │ Hash d'un header HTTP        │ APIs avec tokens
HTTP_COOKIE       │ Cookie applicatif existant   │ Sessions déjà gérées

⚠️ ATTENTION:
- L'affinité N'EST PAS garantie si le backend devient unhealthy
- Le backend peut changer si le pool de backends change
- Préférer des apps stateless + cache externe (Redis, Memorystore)
```

#### Exercice 10.5.2 : Configurer l'affinité par cookie

```bash
# Activer GENERATED_COOKIE sur le backend service
gcloud compute backend-services update backend-web \
    --session-affinity=GENERATED_COOKIE \
    --affinity-cookie-ttl=3600 \
    --global

# Vérifier la configuration
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(sessionAffinity,affinityCookieTtlSec)"
```

#### Exercice 10.5.3 : Tester l'affinité de session

```bash
# Restaurer l'URL Map original
gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-app

# Première requête - le LB génère un cookie
echo "=== Première requête ==="
curl -c cookies.txt -b cookies.txt -s http://$LB_IP/ | grep "Hostname"
cat cookies.txt

# Requêtes suivantes avec le cookie - même backend
echo "=== Requêtes suivantes (même backend attendu) ==="
for i in {1..5}; do
    curl -c cookies.txt -b cookies.txt -s http://$LB_IP/ | grep "Hostname"
done

# Sans cookie - backend peut changer
echo "=== Sans cookie (backends différents possibles) ==="
for i in {1..5}; do
    curl -s http://$LB_IP/ | grep "Hostname"
done
```

#### Exercice 10.5.4 : Affinité par header (API)

```bash
# Configurer l'affinité par header Authorization
gcloud compute backend-services update backend-api \
    --session-affinity=HEADER_FIELD \
    --custom-request-header="X-Session-Token:{client_ip}" \
    --global

# Tester avec différents tokens
echo "=== Token A ==="
curl -H "Authorization: Bearer tokenA" -s http://$LB_IP/api/ | head -1

echo "=== Token B ==="
curl -H "Authorization: Bearer tokenB" -s http://$LB_IP/api/ | head -1

echo "=== Token A (même backend) ==="
curl -H "Authorization: Bearer tokenA" -s http://$LB_IP/api/ | head -1
```

---

## Lab 10.6 : Internal Application Load Balancer
**Difficulté : ⭐⭐**

### Objectifs
- Déployer un Internal Application LB
- Configurer Cloud NAT pour l'accès sortant des VMs sans IP publique
- Configurer le routage interne
- Tester la communication entre services

### Architecture

```
                         VPC
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │   ┌─────────────────────────────────────────────────────┐   │
    │   │              Internal Application LB                │   │
    │   │              IP: 10.0.1.100                         │   │
    │   │                                                     │   │
    │   │   /users → backend-users                            │   │
    │   │   /orders → backend-orders                          │   │
    │   │   /* → backend-default                              │   │
    │   └─────────────────────────────────────────────────────┘   │
    │                           │                                 │
    │          ┌────────────────┼────────────────┐                │
    │          │                │                │                │
    │          ▼                ▼                ▼                │
    │   ┌────────────┐   ┌────────────┐   ┌────────────┐          │
    │   │  ig-users  │   │ ig-orders  │   │ ig-default │          │
    │   └────────────┘   └────────────┘   └────────────┘          │
    │                                                             │
    │   ┌─────────────────────────────────────────────────────┐   │
    │   │              Client VM                              │   │
    │   │              (pour tester)                          │   │
    │   └─────────────────────────────────────────────────────┘   │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 10.6.1 : Créer le sous-réseau pour l'ILB

```bash
# Sous-réseau pour le proxy-only (requis pour Internal Managed LB)
gcloud compute networks subnets create subnet-proxy-only \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.100.0/24 \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE

# Sous-réseau pour les backends internes
gcloud compute networks subnets create subnet-internal \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.2.0/24
```

#### Exercice 10.6.2 : Configurer Cloud NAT pour l'accès sortant

```bash
# Cloud NAT est nécessaire pour que les VMs sans IP externe puissent:
# - Télécharger des paquets (apt-get install)
# - Accéder aux services Google APIs
# - Se connecter à Internet de manière sécurisée

# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create router-nat-lb \
    --network=vpc-lb-lab \
    --region=$REGION

# Configurer Cloud NAT pour l'accès sortant
gcloud compute routers nats create nat-internal-lb \
    --router=router-nat-lb \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Vérifier la configuration
gcloud compute routers nats list \
    --router=router-nat-lb \
    --region=$REGION

gcloud compute routers describe router-nat-lb \
    --region=$REGION \
    --format="yaml(nats)"
```

**Questions :**
1. Pourquoi utiliser Cloud NAT pour les microservices internes plutôt que des IPs externes ?
2. Quel est l'impact de Cloud NAT sur la sécurité de l'architecture ?
3. Les VMs derrière Cloud NAT peuvent-elles recevoir du trafic entrant depuis Internet ?

#### Exercice 10.6.3 : Créer les backends internes

```bash
# Template pour les microservices
for SERVICE in users orders default; do
    gcloud compute instance-templates create ${SERVICE}-template \
        --machine-type=e2-micro \
        --network=vpc-lb-lab \
        --subnet=subnet-internal \
        --no-address \
        --tags=internal-service \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script="#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
{\"service\": \"${SERVICE}\", \"hostname\": \"\$(hostname)\"}
EOF
mkdir -p /var/www/html/${SERVICE}
echo '{\"data\": \"${SERVICE} response\"}' > /var/www/html/${SERVICE}/index.html
echo 'OK' > /var/www/html/health
systemctl restart nginx"

    gcloud compute instance-groups managed create ig-${SERVICE} \
        --template=${SERVICE}-template \
        --size=1 \
        --zone=$ZONE

    gcloud compute instance-groups managed set-named-ports ig-${SERVICE} \
        --zone=$ZONE \
        --named-ports=http:80
done

# Règle de pare-feu pour le trafic interne
gcloud compute firewall-rules create vpc-lb-lab-allow-internal-lb \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=internal-service
```

#### Exercice 10.6.4 : Créer l'Internal Application LB

```bash
# Health check régional
gcloud compute health-checks create http hc-internal \
    --port=80 \
    --request-path="/health" \
    --region=$REGION

# Backend services régionaux
for SERVICE in users orders default; do
    gcloud compute backend-services create backend-${SERVICE} \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=hc-internal \
        --health-checks-region=$REGION \
        --load-balancing-scheme=INTERNAL_MANAGED \
        --region=$REGION

    gcloud compute backend-services add-backend backend-${SERVICE} \
        --instance-group=ig-${SERVICE} \
        --instance-group-zone=$ZONE \
        --region=$REGION
done

# URL Map régional
gcloud compute url-maps create urlmap-internal \
    --default-service=backend-default \
    --region=$REGION

gcloud compute url-maps add-path-matcher urlmap-internal \
    --path-matcher-name=services \
    --default-service=backend-default \
    --path-rules="/users/*=backend-users,/orders/*=backend-orders" \
    --region=$REGION

gcloud compute url-maps add-host-rule urlmap-internal \
    --hosts="*" \
    --path-matcher-name=services \
    --region=$REGION

# Target proxy régional
gcloud compute target-http-proxies create proxy-internal \
    --url-map=urlmap-internal \
    --url-map-region=$REGION \
    --region=$REGION

# Forwarding rule avec IP interne
gcloud compute forwarding-rules create fr-internal \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --network=vpc-lb-lab \
    --subnet=subnet-internal \
    --address=10.0.2.100 \
    --target-http-proxy=proxy-internal \
    --target-http-proxy-region=$REGION \
    --ports=80 \
    --region=$REGION
```

#### Exercice 10.6.5 : Tester l'Internal LB

```bash
# Créer une VM client pour tester
gcloud compute instances create vm-client \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-lb-lab \
    --subnet=subnet-internal \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Tester depuis la VM client
gcloud compute ssh vm-client --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Internal LB ==="

echo "Service Users:"
curl -s http://10.0.2.100/users/

echo -e "\nService Orders:"
curl -s http://10.0.2.100/orders/

echo -e "\nService Default:"
curl -s http://10.0.2.100/
EOF
```

---

## Lab 10.7 : Network Load Balancer (L4)
**Difficulté : ⭐⭐**

### Objectifs
- Déployer un Network Load Balancer passthrough
- Comprendre les différences avec l'Application LB
- Configurer l'Internal Network LB

### Exercices

#### Exercice 10.7.1 : Créer un Internal Passthrough Network LB

```bash
# Cas d'usage: Load balancer pour base de données

# Sous-réseau pour les backends DB
gcloud compute networks subnets create subnet-db \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.3.0/24

# Template pour simuler des DB
gcloud compute instance-templates create db-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-db \
    --no-address \
    --tags=db-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y netcat-openbsd
# Simuler un service DB sur le port 5432
while true; do echo -e "HTTP/1.1 200 OK\n\nDB Server: $(hostname)" | nc -l -p 5432 -q 1; done &'

# Instance group
gcloud compute instance-groups managed create ig-db \
    --template=db-template \
    --size=2 \
    --zone=$ZONE

# Règle de pare-feu
gcloud compute firewall-rules create vpc-lb-lab-allow-db \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:5432 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=db-server

# Health check régional TCP
gcloud compute health-checks create tcp hc-tcp-db \
    --port=5432 \
    --region=$REGION

# Backend service L4
gcloud compute backend-services create backend-db \
    --protocol=TCP \
    --health-checks=hc-tcp-db \
    --health-checks-region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION

gcloud compute backend-services add-backend backend-db \
    --instance-group=ig-db \
    --instance-group-zone=$ZONE \
    --region=$REGION

# Forwarding rule
gcloud compute forwarding-rules create fr-db \
    --load-balancing-scheme=INTERNAL \
    --network=vpc-lb-lab \
    --subnet=subnet-db \
    --address=10.0.3.100 \
    --backend-service=backend-db \
    --ports=5432 \
    --region=$REGION

echo "Internal Network LB créé: 10.0.3.100:5432"
```

#### Exercice 10.7.2 : Comparer Proxy vs Passthrough

| Aspect                | Application LB (L7)      | Network LB Passthrough  |
|-----------------------|--------------------------|-------------------------|
| Couche OSI            | Layer 7 (HTTP/HTTPS)     | Layer 4 (TCP/UDP)       |
| Mode                  | Proxy                    | Passthrough (DSR)       |
| Terminaison connexion | Oui (au LB)              | Non                     |
| IP client préservée   | Non (X-Forwarded-For)    | Oui                     |
| Latence               | Légèrement plus élevée   | Minimale                |
| Routage intelligent   | Oui (URL, headers)       | Non                     |
| TLS termination       | Oui                      | Non                     |
| Cloud Armor           | Oui                      | Non                     |
| CDN                   | Oui                      | Non                     |
| Health checks         | HTTP/HTTPS/HTTP2         | TCP/SSL/HTTP            |

Cas d'usage:
• Application LB: Web apps, APIs, microservices HTTP
• Network LB: Bases de données, jeux, VoIP, streaming, protocoles custom

---

## Lab 10.8 : Équilibrage hybride avec Hybrid NEG
**Difficulté : ⭐⭐⭐**

### Objectifs
- Comprendre les Hybrid NEGs
- Configurer l'équilibrage vers des backends on-premise
- Créer une architecture hybride

### Architecture hybride

```
                              Internet
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │   Global Application LB │
                    └───────────┬─────────────┘
                                │
              ┌─────────────────┴─────────────────┐
              │                                   │
              ▼                                   ▼
    ┌──────────────────┐                ┌──────────────────┐
    │   GCP Backends   │                │  Hybrid NEG      │
    │   (Instance Grp) │                │  (On-Premise)    │
    │                  │                │                  │
    │   10.0.1.10      │   VPN/         │   192.168.1.10   │
    │   10.0.1.11      │   Interconnect │   192.168.1.11   │
    └──────────────────┘                └──────────────────┘
              │                                   │
              │         Cloud VPN / Interconnect  │
              └───────────────────────────────────┘
```

### Exercices

#### Exercice 10.8.1 : Comprendre les Hybrid NEGs

Un Hybrid NEG permet d'inclure des backends EXTERNES à GCP dans un 
Load Balancer GCP:

• Serveurs on-premise
• Serveurs dans d'autres clouds (AWS, Azure)
• Serveurs dans d'autres régions GCP non supportées

Prérequis:
• Connectivité réseau (VPN ou Interconnect)
• Les IPs doivent être routables depuis GCP
• Health checks doivent pouvoir atteindre les backends

Type de NEG: NON_GCP_PRIVATE_IP_PORT

Limites:
• Uniquement pour Global external Application LB
• Max 100 endpoints par NEG
• Les endpoints doivent avoir des IPs privées (RFC 1918)

#### Exercice 10.8.2 : Créer un Hybrid NEG (simulation)

```bash
# Note: Ceci simule des backends on-premise
# En production, les IPs seraient celles de vos serveurs on-premise

# Créer le Hybrid NEG
gcloud compute network-endpoint-groups create neg-onprem \
    --network-endpoint-type=NON_GCP_PRIVATE_IP_PORT \
    --zone=$ZONE \
    --network=vpc-lb-lab

# Ajouter des endpoints (IPs simulées on-premise)
# En production: IPs de vos serveurs on-premise accessibles via VPN
gcloud compute network-endpoint-groups update neg-onprem \
    --zone=$ZONE \
    --add-endpoint="ip=10.1.1.10,port=80" \
    --add-endpoint="ip=10.1.1.11,port=80"

# Lister les endpoints
gcloud compute network-endpoint-groups list-network-endpoints neg-onprem \
    --zone=$ZONE
```

#### Exercice 10.8.3 : Créer le backend service hybride

```bash
# Backend service avec le Hybrid NEG
gcloud compute backend-services create backend-hybrid \
    --protocol=HTTP \
    --health-checks=hc-web \
    --global

# Ajouter le NEG hybride
gcloud compute backend-services add-backend backend-hybrid \
    --network-endpoint-group=neg-onprem \
    --network-endpoint-group-zone=$ZONE \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100 \
    --global

# Vérifier
gcloud compute backend-services describe backend-hybrid \
    --global \
    --format="yaml(backends)"
```

#### Exercice 10.8.4 : Configurer le failover GCP ↔ On-premise

```bash
# URL Map avec failover
cat > urlmap-hybrid.yaml << EOF
name: urlmap-hybrid
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
hostRules:
- hosts:
  - "*"
  pathMatcher: hybrid-matcher
pathMatchers:
- name: hybrid-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
  routeRules:
  # Traffic splitting entre GCP et on-premise
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
        weight: 80
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-hybrid
        weight: 20
EOF

gcloud compute url-maps import urlmap-hybrid \
    --source=urlmap-hybrid.yaml \
    --global
```

---

## Lab 10.9 : Network Endpoint Groups (NEGs)
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre les différents types de NEGs
- Créer un Serverless NEG pour Cloud Run
- Configurer un Internet NEG

### Exercices

#### Exercice 10.9.1 : Types de NEGs

| Type                                   | Backends                                | Portée |
|----------------------------------------|-----------------------------------------|--------|
| Zonal NEG<br>(GCE_VM_IP_PORT)          | VMs, containers GKE                     | Zone   |
| Serverless NEG<br>(SERVERLESS)         | Cloud Run, Cloud Functions, App Engine  | Région |
| Internet NEG<br>(INTERNET_FQDN_PORT)   | Endpoints publics (FQDN ou IP externe)  | Global |
| Hybrid NEG<br>(NON_GCP_PRIVATE_IP_PORT)| On-premise, autres clouds               | Zone   |
| PSC NEG<br>(PRIVATE_SERVICE_CONNECT)   | Services via Private Service Connect    | Région |

#### Exercice 10.9.2 : Créer un Serverless NEG (Cloud Run)

```bash
# Déployer un service Cloud Run simple
gcloud run deploy hello-service \
    --image=gcr.io/cloudrun/hello \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated

# Créer le Serverless NEG
gcloud compute network-endpoint-groups create neg-cloudrun \
    --region=$REGION \
    --network-endpoint-type=SERVERLESS \
    --cloud-run-service=hello-service

# Créer un backend service pour le NEG serverless
gcloud compute backend-services create backend-cloudrun \
    --global

gcloud compute backend-services add-backend backend-cloudrun \
    --network-endpoint-group=neg-cloudrun \
    --network-endpoint-group-region=$REGION \
    --global

# Ajouter au URL Map
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=serverless \
    --default-service=backend-cloudrun \
    --path-rules="/run/*=backend-cloudrun"
```

#### Exercice 10.9.3 : Créer un Internet NEG

```bash
# Internet NEG pour un backend externe
gcloud compute network-endpoint-groups create neg-external \
    --network-endpoint-type=INTERNET_FQDN_PORT \
    --global

# Ajouter un endpoint externe (exemple: API publique)
gcloud compute network-endpoint-groups update neg-external \
    --add-endpoint="fqdn=httpbin.org,port=443" \
    --global

# Backend service pour l'Internet NEG
gcloud compute backend-services create backend-external \
    --protocol=HTTPS \
    --global

gcloud compute backend-services add-backend backend-external \
    --network-endpoint-group=neg-external \
    --global-network-endpoint-group \
    --global
```

---

## Lab 10.10 : Cloud CDN - Configuration et optimisation
**Difficulté : ⭐⭐**

### Objectifs
- Activer Cloud CDN sur un backend
- Configurer les modes de cache
- Invalider le cache
- Analyser les métriques CDN

### Exercices

#### Exercice 10.10.1 : Activer Cloud CDN

```bash
# Activer Cloud CDN sur le backend web
gcloud compute backend-services update backend-web \
    --enable-cdn \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=3600 \
    --max-ttl=86400 \
    --global

# Vérifier
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(enableCDN,cdnPolicy)"
```

#### Exercice 10.10.2 : Modes de cache CDN

| Mode                | Comportement                                                                                                                                                     |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CACHE_ALL_STATIC    | Cache automatique du contenu statique:<br>- Images (jpg, png, gif, webp, ico)<br>- CSS, JS<br>- Fonts (woff, woff2)<br>- Documents (pdf)                       |
| USE_ORIGIN_HEADERS  | Respecte les headers Cache-Control de l'origin<br>- Flexible, contrôle côté application<br>- Nécessite une configuration applicative correcte                  |
| FORCE_CACHE_ALL     | Cache TOUT le contenu (ignore les headers)<br>- Agressif, attention aux données dynamiques<br>- Utile pour CDN origin avec contenu 100% statique                |

Paramètres TTL:
- default-ttl: TTL par défaut si pas de header (défaut: 3600s)
- max-ttl: TTL maximum (cap les valeurs trop longues)
- client-ttl: TTL envoyé au client (Cache-Control: max-age)

```bash
# Configurer pour respecter les headers origin
gcloud compute backend-services update backend-web \
    --cache-mode=USE_ORIGIN_HEADERS \
    --global
```

#### Exercice 10.10.3 : Configurer les Cache Keys

```bash
# Par défaut, la cache key inclut: protocol + host + path + query string
# Personnaliser la cache key

gcloud compute backend-services update backend-web \
    --cache-key-include-protocol \
    --cache-key-include-host \
    --no-cache-key-include-query-string \
    --global

# Ou inclure seulement certains query params
gcloud compute backend-services update backend-web \
    --cache-key-query-string-whitelist=version,locale \
    --global
```

#### Exercice 10.10.4 : Tester le cache CDN

```bash
# Tester et observer les headers de cache
echo "=== Première requête (cache MISS) ==="
curl -sI http://$LB_IP/static/style.css | grep -E "(X-Cache|Age|Cache-Control)"

echo "=== Deuxième requête (cache HIT) ==="
curl -sI http://$LB_IP/static/style.css | grep -E "(X-Cache|Age|Cache-Control)"

# Observer les métriques
echo "Headers importants:"
echo "- X-Cache: HIT/MISS indique si servi du cache"
echo "- Age: Temps depuis la mise en cache"
echo "- Cache-Control: Politique de cache"
```

#### Exercice 10.10.5 : Invalider le cache

```bash
# Invalider un fichier spécifique
gcloud compute url-maps invalidate-cdn-cache urlmap-app \
    --path="/static/style.css" \
    --global

# Invalider un préfixe
gcloud compute url-maps invalidate-cdn-cache urlmap-app \
    --path="/static/*" \
    --global

# Invalider tout
gcloud compute url-maps invalidate-cdn-cache urlmap-app \
    --path="/*" \
    --global

echo "⚠️ L'invalidation peut prendre quelques minutes à se propager"
```

#### Exercice 10.10.6 : Métriques Cloud CDN

```
Métriques Importantes :
──────────────────────────────────────────────────────────────────────────────
cdn/cache_hit_count         │ Nombre de requêtes servies depuis le cache
cdn/cache_miss_count        │ Nombre de requêtes envoyées à l'origin
cdn/cache_hit_ratio         │ Ratio de cache hit (objectif > 80%)
cdn/cache_fill_bytes_count  │ Bytes récupérés depuis l'origin
cdn/cache_hit_bytes_count   │ Bytes servis depuis le cache

Calcul du ratio:
cache_hit_ratio = cache_hit_count / (cache_hit_count + cache_miss_count)
```

```bash
# Consulter les métriques via gcloud
gcloud monitoring metrics list --filter="metric.type:cdn"
```

---

## Lab 10.11 : Cloud CDN - Signed URLs et contenu protégé
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer des clés de signature pour Cloud CDN
- Générer des Signed URLs
- Protéger du contenu premium

### Exercices

#### Exercice 10.11.1 : Comprendre les Signed URLs

Les Signed URLs permettent de:
- Donner un accès temporaire à du contenu
- Protéger du contenu premium/payant
- Limiter la durée d'accès
- Éviter le partage de liens

Format d'une Signed URL:
https://example.com/video.mp4?Expires=1704067200&KeyName=key-v1&Signature=abc123...

Composants:
- URL de base: Le contenu à protéger
- Expires: Timestamp Unix d'expiration
- KeyName: Nom de la clé utilisée
- Signature: HMAC-SHA1 de l'URL

Signed Cookies:
- Même principe mais via cookie HTTP
- Permet l'accès à plusieurs ressources
- Utile pour le streaming vidéo

#### Exercice 10.11.2 : Créer une clé de signature

```bash
# Générer une clé aléatoire (128 bits = 16 bytes)
head -c 16 /dev/urandom | base64 | tr '+/' '-_' > cdn-signing-key.txt
cat cdn-signing-key.txt

# Ajouter la clé au backend service
gcloud compute backend-services add-signed-url-key backend-web \
    --key-name=key-v1 \
    --key-file=cdn-signing-key.txt \
    --global

# Vérifier
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(cdnPolicy.signedUrlKeyNames)"

# Configurer le cache max age pour les signed URLs
gcloud compute backend-services update backend-web \
    --signed-url-cache-max-age=3600 \
    --global
```

#### Exercice 10.11.3 : Script Python pour générer des Signed URLs

```bash
# Créer le script de génération
cat > generate_signed_url.py << 'PYTHON'
#!/usr/bin/env python3
"""Génère une Signed URL pour Cloud CDN."""

import argparse
import base64
import datetime
import hashlib
import hmac

def sign_url(url: str, key_name: str, key: bytes, expiration: datetime.datetime) -> str:
    """Génère une Signed URL.
    
    Args:
        url: URL de base à signer
        key_name: Nom de la clé
        key: Clé de signature (bytes)
        expiration: Date/heure d'expiration
    
    Returns:
        URL signée
    """
    # Timestamp Unix
    expiration_timestamp = int(expiration.timestamp())
    
    # URL à signer
    url_to_sign = f"{url}{'&' if '?' in url else '?'}Expires={expiration_timestamp}&KeyName={key_name}"
    
    # Signature HMAC-SHA1
    signature = hmac.new(
        key,
        url_to_sign.encode('utf-8'),
        hashlib.sha1
    ).digest()
    
    # Encoder la signature en base64 URL-safe
    encoded_signature = base64.urlsafe_b64encode(signature).decode('utf-8')
    
    return f"{url_to_sign}&Signature={encoded_signature}"

def main():
    parser = argparse.ArgumentParser(description='Génère une Signed URL Cloud CDN')
    parser.add_argument('--url', required=True, help='URL à signer')
    parser.add_argument('--key-name', required=True, help='Nom de la clé')
    parser.add_argument('--key-file', required=True, help='Fichier contenant la clé')
    parser.add_argument('--expires-in', type=int, default=3600, help='Durée de validité en secondes')
    
    args = parser.parse_args()
    
    # Lire la clé
    with open(args.key_file, 'r') as f:
        key = base64.urlsafe_b64decode(f.read().strip())
    
    # Calculer l'expiration
    expiration = datetime.datetime.utcnow() + datetime.timedelta(seconds=args.expires_in)
    
    # Générer l'URL signée
    signed_url = sign_url(args.url, args.key_name, key, expiration)
    
    print(f"URL signée (valide {args.expires_in}s):")
    print(signed_url)

if __name__ == '__main__':
    main()
PYTHON

chmod +x generate_signed_url.py
```

#### Exercice 10.11.4 : Tester les Signed URLs

```bash
# Générer une Signed URL
python3 generate_signed_url.py \
    --url="http://$LB_IP/static/style.css" \
    --key-name=key-v1 \
    --key-file=cdn-signing-key.txt \
    --expires-in=300

# Tester l'URL signée (devrait fonctionner)
# Copier l'URL générée et la tester

# Tester sans signature (devrait échouer si le backend est configuré pour exiger des signatures)
# Note: Par défaut, les signed URLs sont optionnelles
```

#### Exercice 10.11.5 : Rotation des clés

```bash
# Bonne pratique: Rotation régulière des clés

# Générer une nouvelle clé
head -c 16 /dev/urandom | base64 | tr '+/' '-_' > cdn-signing-key-v2.txt

# Ajouter la nouvelle clé (sans supprimer l'ancienne)
gcloud compute backend-services add-signed-url-key backend-web \
    --key-name=key-v2 \
    --key-file=cdn-signing-key-v2.txt \
    --global

# Migrer progressivement vers la nouvelle clé
# (Mettre à jour l'application pour utiliser key-v2)

# Supprimer l'ancienne clé après migration
# gcloud compute backend-services delete-signed-url-key backend-web \
#     --key-name=key-v1 \
#     --global
```

---

## Lab 10.12 : Scénario intégrateur - Architecture multi-tier
**Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer une architecture complète multi-tier
- Combiner Load Balancers externes et internes
- Implémenter les bonnes pratiques

### Architecture cible

```
                              Internet
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Global External Application LB                            │
│                    (Cloud Armor + CDN)                                       │
│                                                                              │
│   /static/* → Cloud Storage (CDN)                                            │
│   /api/* → Backend API                                                       │
│   /* → Backend Web (Canary 90/10)                                            │
└──────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Frontend Tier                                      │
│   ┌─────────────────┐              ┌─────────────────┐                       │
│   │  ig-web-v1 (90%)│              │  ig-web-v2 (10%)│                       │
│   └─────────────────┘              └─────────────────┘                       │
└──────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Internal Application LB                                   │
│                                                                              │
│   /users/* → Backend Users                                                   │
│   /orders/* → Backend Orders                                                 │
│   /inventory/* → Backend Inventory                                           │
└──────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Internal Passthrough Network LB                           │
│                                                                              │
│   Database Cluster (PostgreSQL)                                              │
│   10.0.3.100:5432                                                            │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Script de déploiement

```bash
#!/bin/bash
# Architecture multi-tier complète

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE MULTI-TIER"
echo "=========================================="

# L'infrastructure a déjà été créée dans les labs précédents
# Ce script récapitule l'architecture complète

echo "
Architecture déployée:

1. GLOBAL EXTERNAL APPLICATION LB
   - Frontend: http://$LB_IP
   - Cloud Armor: Activé
   - Cloud CDN: Activé sur /static/*
   - Canary: 90% v1, 10% v2

2. INTERNAL APPLICATION LB
   - IP: 10.0.2.100
   - Services: /users, /orders, /inventory
   - Uniquement accessible depuis le VPC

3. INTERNAL NETWORK LB
   - IP: 10.0.3.100:5432
   - Backend: PostgreSQL cluster
   - Passthrough pour performance max

Composants:
- 2 Instance Groups frontend (v1, v2)
- 3 Instance Groups backend (users, orders, inventory)
- 2 Instance Groups database
- Cloud Storage pour contenu statique
- Health checks HTTP et TCP
"

# Vérifier les backends
echo "=== État des backends ==="
for BACKEND in backend-web backend-v1 backend-v2 backend-api; do
    echo "--- $BACKEND ---"
    gcloud compute backend-services get-health $BACKEND --global 2>/dev/null || echo "Non global"
done
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage Module 10

echo "=== Suppression des Forwarding Rules ==="
gcloud compute forwarding-rules delete fr-http-app --global --quiet 2>/dev/null
gcloud compute forwarding-rules delete fr-internal --region=europe-west1 --quiet 2>/dev/null
gcloud compute forwarding-rules delete fr-db --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des Target Proxies ==="
gcloud compute target-http-proxies delete proxy-http-app --quiet 2>/dev/null
gcloud compute target-http-proxies delete proxy-internal --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des URL Maps ==="
for URLMAP in urlmap-app urlmap-canary urlmap-header-routing urlmap-internal urlmap-hybrid; do
    gcloud compute url-maps delete $URLMAP --global --quiet 2>/dev/null
    gcloud compute url-maps delete $URLMAP --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des Backend Services ==="
for BACKEND in backend-web backend-api backend-v1 backend-v2 backend-users backend-orders backend-default backend-db backend-hybrid backend-cloudrun backend-external; do
    gcloud compute backend-services delete $BACKEND --global --quiet 2>/dev/null
    gcloud compute backend-services delete $BACKEND --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des Backend Buckets ==="
gcloud compute backend-buckets delete bucket-static --quiet 2>/dev/null

echo "=== Suppression des Health Checks ==="
for HC in hc-web hc-api hc-internal hc-tcp-db; do
    gcloud compute health-checks delete $HC --quiet 2>/dev/null
    gcloud compute health-checks delete $HC --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des NEGs ==="
gcloud compute network-endpoint-groups delete neg-onprem --zone=europe-west1-b --quiet 2>/dev/null
gcloud compute network-endpoint-groups delete neg-cloudrun --region=europe-west1 --quiet 2>/dev/null
gcloud compute network-endpoint-groups delete neg-external --global --quiet 2>/dev/null

echo "=== Suppression des Instance Groups ==="
for IG in ig-web ig-api ig-v1 ig-v2 ig-users ig-orders ig-default ig-db; do
    gcloud compute instance-groups managed delete $IG --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des Instance Templates ==="
for TEMPLATE in web-template api-template web-template-v1 web-template-v2 users-template orders-template default-template db-template; do
    gcloud compute instance-templates delete $TEMPLATE --quiet 2>/dev/null
done

echo "=== Suppression des VMs ==="
gcloud compute instances delete vm-client --zone=europe-west1-b --quiet 2>/dev/null

echo "=== Suppression des IP addresses ==="
gcloud compute addresses delete lb-ip-global --global --quiet 2>/dev/null

echo "=== Suppression du bucket ==="
gsutil rm -r gs://${PROJECT_ID}-static-content 2>/dev/null

echo "=== Suppression des Cloud Run services ==="
gcloud run services delete hello-service --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des règles de pare-feu ==="
for RULE in $(gcloud compute firewall-rules list --filter="network:vpc-lb-lab" --format="get(name)" 2>/dev/null); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
done

echo "=== Suppression des Cloud NAT ==="
gcloud compute routers nats delete nat-internal-lb --router=router-nat-lb --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des Cloud Routers ==="
gcloud compute routers delete router-nat-lb --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-web subnet-internal subnet-db subnet-proxy-only; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression du VPC ==="
gcloud compute networks delete vpc-lb-lab --quiet 2>/dev/null

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 10

### Application Load Balancer
```bash
# Backend service
gcloud compute backend-services create NAME --protocol=HTTP --health-checks=HC --global

# URL Map
gcloud compute url-maps create NAME --default-service=BACKEND

# Target proxy
gcloud compute target-http-proxies create NAME --url-map=URLMAP

# Forwarding rule
gcloud compute forwarding-rules create NAME --target-http-proxy=PROXY --ports=80 --global
```

### Traffic Splitting
```yaml
# Dans URL Map YAML
routeAction:
  weightedBackendServices:
  - backendService: backend-v1
    weight: 90
  - backendService: backend-v2
    weight: 10
```

### Cloud CDN
```bash
# Activer
gcloud compute backend-services update BACKEND --enable-cdn --global

# Invalider
gcloud compute url-maps invalidate-cdn-cache URLMAP --path="/path/*" --global
```
