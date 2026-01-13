# Module 9 - Protection DDoS et Cloud Armor
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Comprendre les types d'attaques DDoS et les couches de protection GCP
- Créer et configurer des politiques Cloud Armor
- Implémenter des règles de filtrage (IP, géolocalisation, expressions CEL)
- Configurer les règles WAF préconfigurées (OWASP)
- Mettre en place le rate limiting et le throttling
- Utiliser le mode Preview pour tester les règles
- Comprendre Adaptive Protection et Bot Management
- Configurer les Edge Security Policies

### Prérequis
- Modules 1 à 8 complétés
- Projet GCP avec facturation activée
- Droits : roles/compute.securityAdmin, roles/compute.loadBalancerAdmin
- Un domaine (optionnel, pour les certificats HTTPS)

### Note importante
⚠️ Cloud Armor nécessite un Load Balancer Application (L7). Les labs incluent la création de l'infrastructure LB.

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 9.1 | Comprendre les attaques DDoS et les protections GCP | ⭐ |
| 9.2 | Déployer un Application Load Balancer | ⭐⭐ |
| 9.3 | Créer une politique Cloud Armor de base | ⭐⭐ |
| 9.4 | Filtrage par IP et géolocalisation | ⭐⭐ |
| 9.5 | Expressions CEL avancées | ⭐⭐⭐ |
| 9.6 | Règles WAF préconfigurées (OWASP) | ⭐⭐ |
| 9.7 | Rate Limiting et Throttling | ⭐⭐ |
| 9.8 | Mode Preview et analyse des logs | ⭐⭐ |
| 9.9 | Named IP Lists et Threat Intelligence | ⭐⭐ |
| 9.10 | Edge Security Policies | ⭐⭐ |
| 9.11 | Scénario intégrateur - Protection complète | ⭐⭐⭐ |

---

## Lab 9.1 : Comprendre les attaques DDoS et les protections GCP
**Difficulté : ⭐**

### Objectifs
- Comprendre les différents types d'attaques DDoS
- Identifier les 4 couches de protection Google Cloud
- Connaître les fonctionnalités de Cloud Armor

### Exercices

#### Exercice 9.1.1 : Types d'attaques DDoS

```bash
cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════════╗
║                          TYPES D'ATTAQUES DDoS                                 ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║  COUCHE 3/4 - VOLUMÉTRIQUES                                                   ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │ Objectif: Saturer la bande passante                                     │  ║
║  │                                                                         │  ║
║  │ • UDP Flood: Inondation de paquets UDP                                  │  ║
║  │ • SYN Flood: Épuisement des connexions TCP (half-open)                  │  ║
║  │ • ICMP Flood: Ping of death, smurf attack                               │  ║
║  │ • Amplification: DNS, NTP, memcached (facteur x50-x1000)                │  ║
║  │                                                                         │  ║
║  │ Volume: Jusqu'à plusieurs Tbps                                          │  ║
║  │ Protection GCP: Automatique (infrastructure + edge)                     │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                ║
║  COUCHE 4 - PROTOCOLE                                                         ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │ Objectif: Épuiser les tables d'état                                     │  ║
║  │                                                                         │  ║
║  │ • TCP State Exhaustion: Connexions zombie                               │  ║
║  │ • Fragmentation: Paquets fragmentés malformés                           │  ║
║  │                                                                         │  ║
║  │ Protection GCP: Automatique (Load Balancer proxy)                       │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                ║
║  COUCHE 7 - APPLICATIVES                                                      ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │ Objectif: Épuiser les ressources applicatives                           │  ║
║  │                                                                         │  ║
║  │ • HTTP Flood: Requêtes HTTP légitimes en masse                          │  ║
║  │ • Slowloris: Connexions lentes gardées ouvertes                         │  ║
║  │ • API Abuse: Appels API coûteux en masse                                │  ║
║  │ • Scraping: Extraction massive de contenu                               │  ║
║  │                                                                         │  ║
║  │ Volume: Record Google 2023 = 46 millions RPS                            │  ║
║  │ Protection GCP: Cloud Armor (à configurer)                              │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
```

#### Exercice 9.1.2 : Les 4 couches de protection Google Cloud

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    4 COUCHES DE PROTECTION DDoS GCP
═══════════════════════════════════════════════════════════════════════════════

                            Internet
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  COUCHE 1: INFRASTRUCTURE GOOGLE                              [AUTOMATIQUE]  │
│  ─────────────────────────────────────────────────────────────────────────── │
│  • 200+ points de présence (PoP) mondiaux                                    │
│  • Capacité de plusieurs Petabits/seconde                                    │
│  • Câbles sous-marins privés                                                 │
│  • Absorption des attaques volumétriques massives                            │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  COUCHE 2: EDGE NETWORK                                       [AUTOMATIQUE]  │
│  ─────────────────────────────────────────────────────────────────────────── │
│  • Filtrage du trafic malveillant connu                                      │
│  • Anti-spoofing (vérification IP source)                                    │
│  • Rate limiting infrastructure                                              │
│  • Validation des protocoles                                                 │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  COUCHE 3: LOAD BALANCING                                     [AUTOMATIQUE]  │
│  ─────────────────────────────────────────────────────────────────────────── │
│  • Distribution du trafic                                                    │
│  • Terminaison TLS (offload)                                                 │
│  • Protection contre les attaques TCP state                                  │
│  • IP Anycast (répartition géographique)                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  COUCHE 4: CLOUD ARMOR                                      [À CONFIGURER]   │
│  ─────────────────────────────────────────────────────────────────────────── │
│  • WAF (règles OWASP)                                                        │
│  • Filtrage IP, géolocalisation                                              │
│  • Rate limiting personnalisé                                                │
│  • Adaptive Protection (ML)                                                  │
│  • Bot Management                                                            │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
                         Backend Services
EOF
```

#### Exercice 9.1.3 : Fonctionnalités Cloud Armor par tier

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                     CLOUD ARMOR - TIERS DE SERVICE
═══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                           STANDARD (Gratuit*)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ Règles de sécurité personnalisées                                        │
│ ✅ Règles WAF préconfigurées (OWASP)                                        │
│ ✅ Rate limiting                                                            │
│ ✅ Filtrage IP et géolocalisation                                           │
│ ✅ Mode Preview                                                             │
│ ❌ Adaptive Protection                                                      │
│ ❌ Bot Management                                                           │
│ ❌ Threat Intelligence complet                                              │
│ ❌ DDoS Response Team                                                       │
│                                                                             │
│ Tarification: Par règle (~$5/mois) + requêtes (~$0.75/million)             │
│ Recommandé pour: PME, applications non critiques                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                      MANAGED PROTECTION PLUS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ Tout ce qui est inclus dans Standard                                     │
│ ✅ Adaptive Protection (Machine Learning)                                   │
│ ✅ Bot Management avancé                                                    │
│ ✅ Threat Intelligence complet                                              │
│ ✅ DDoS Response Team Google                                                │
│ ✅ Garantie facture DDoS (protection financière)                            │
│                                                                             │
│ Tarification: ~$3000/mois par organisation (abonnement)                     │
│ Recommandé pour: E-commerce, finance, santé, apps critiques                 │
└─────────────────────────────────────────────────────────────────────────────┘

* Les coûts de Load Balancer sont séparés
EOF
```

#### Exercice 9.1.4 : Load Balancers compatibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                   CLOUD ARMOR - LOAD BALANCERS COMPATIBLES
═══════════════════════════════════════════════════════════════════════════════

Type de Load Balancer                           │ Cloud Armor │ Raison
────────────────────────────────────────────────┼─────────────┼─────────────────
Global external Application LB                  │     ✅      │ Proxy L7
Regional external Application LB                │     ✅      │ Proxy L7
Classic Application LB                          │     ✅      │ Proxy L7
Global external proxy Network LB                │     ✅      │ Proxy L4
────────────────────────────────────────────────┼─────────────┼─────────────────
Regional external passthrough Network LB        │     ❌      │ Passthrough
Regional internal passthrough Network LB        │     ❌      │ Passthrough
Internal Application LB                         │     ❌      │ Interne seulement
Internal proxy Network LB                       │     ❌      │ Interne seulement

🔑 Cloud Armor fonctionne UNIQUEMENT avec les Load Balancers de type PROXY
   qui terminent les connexions (pas les passthrough).
EOF
```

---

## Lab 9.2 : Déployer un Application Load Balancer
**Difficulté : ⭐⭐**

### Objectifs
- Créer l'infrastructure nécessaire pour Cloud Armor
- Déployer un Application Load Balancer global
- Configurer les backends et health checks

### Architecture cible

```
                            Internet
                               │
                               ▼
                    ┌─────────────────────┐
                    │  Forwarding Rule    │
                    │  (IP externe)       │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Target Proxy      │
                    │   (HTTPS)           │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │     URL Map         │
                    │                     │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│Backend Service│      │Backend Service│      │Backend Service│
│   (default)   │      │    (api)      │      │   (static)    │
└───────┬───────┘      └───────┬───────┘      └───────┬───────┘
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│Instance Group │      │Instance Group │      │ Cloud Storage │
│   (web-ig)    │      │   (api-ig)    │      │   (bucket)    │
└───────────────┘      └───────────────┘      └───────────────┘
```

### Exercices

#### Exercice 9.2.1 : Créer l'infrastructure de base

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC
gcloud compute networks create vpc-armor-lab \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-web \
    --network=vpc-armor-lab \
    --region=$REGION \
    --range=10.0.1.0/24

# Règles de pare-feu
# Autoriser les health checks Google
gcloud compute firewall-rules create vpc-armor-lab-allow-health-check \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:443,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=web-server

# Autoriser le trafic du Load Balancer
gcloud compute firewall-rules create vpc-armor-lab-allow-lb \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# Autoriser SSH via IAP
gcloud compute firewall-rules create vpc-armor-lab-allow-iap \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20
```

#### Exercice 9.2.2 : Créer le template d'instance et le groupe

```bash
# Template d'instance avec serveur web
gcloud compute instance-templates create web-template \
    --machine-type=e2-small \
    --network=vpc-armor-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx

# Page personnalisée avec infos
cat > /var/www/html/index.html << HTMLEOF
<!DOCTYPE html>
<html>
<head><title>Cloud Armor Lab</title></head>
<body>
<h1>Cloud Armor Lab</h1>
<p>Hostname: $(hostname)</p>
<p>Zone: ${ZONE}</p>
<p>Internal IP: $(hostname -I | awk "{print \$1}")</p>
<p>Date: $(date)</p>
</body>
</html>
HTMLEOF

# Endpoint de health check
mkdir -p /var/www/html/health
echo "OK" > /var/www/html/health/index.html

systemctl restart nginx'

# Groupe d'instances managé
gcloud compute instance-groups managed create web-ig \
    --template=web-template \
    --size=2 \
    --zone=$ZONE

# Configurer l'autoscaling (optionnel)
gcloud compute instance-groups managed set-autoscaling web-ig \
    --zone=$ZONE \
    --min-num-replicas=2 \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.7

# Configurer le named port
gcloud compute instance-groups managed set-named-ports web-ig \
    --zone=$ZONE \
    --named-ports=http:80
```

#### Exercice 9.2.3 : Créer le Health Check et le Backend Service

```bash
# Health check HTTP
gcloud compute health-checks create http hc-http-80 \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

# Backend service
gcloud compute backend-services create backend-web \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-http-80 \
    --global

# Ajouter le groupe d'instances au backend
gcloud compute backend-services add-backend backend-web \
    --instance-group=web-ig \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global
```

#### Exercice 9.2.4 : Créer l'URL Map et le Frontend

```bash
# URL Map
gcloud compute url-maps create urlmap-web \
    --default-service=backend-web

# Réserver une IP externe
gcloud compute addresses create lb-ip \
    --ip-version=IPV4 \
    --global

# Récupérer l'IP
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"

# Target HTTP Proxy (HTTP simple pour le lab)
gcloud compute target-http-proxies create proxy-http \
    --url-map=urlmap-web

# Forwarding Rule
gcloud compute forwarding-rules create fr-http \
    --address=lb-ip \
    --target-http-proxy=proxy-http \
    --ports=80 \
    --global

echo "Load Balancer accessible sur: http://$LB_IP"
```

#### Exercice 9.2.5 : Tester le Load Balancer

```bash
# Attendre que les backends soient healthy
echo "Attente de la mise en service des backends..."
sleep 60

# Vérifier le statut des backends
gcloud compute backend-services get-health backend-web --global

# Tester l'accès
curl -s http://$LB_IP

# Tester plusieurs fois pour voir la répartition
for i in {1..5}; do
    echo "=== Requête $i ==="
    curl -s http://$LB_IP | grep Hostname
done
```

---

## Lab 9.3 : Créer une politique Cloud Armor de base
**Difficulté : ⭐⭐**

### Objectifs
- Créer une politique de sécurité Cloud Armor
- Configurer la règle par défaut
- Attacher la politique au backend service

### Exercices

#### Exercice 9.3.1 : Créer la politique de sécurité

```bash
# Créer la politique
gcloud compute security-policies create policy-web-app \
    --description="Politique de sécurité pour l'application web"

# Vérifier la création
gcloud compute security-policies describe policy-web-app

# Lister les règles (une seule règle par défaut)
gcloud compute security-policies rules list --security-policy=policy-web-app
```

#### Exercice 9.3.2 : Configurer la règle par défaut

```bash
# Par défaut, la règle autorise tout (action=allow, priority=2147483647)
# Garder ce comportement pour le lab

# Alternative: Configurer en mode "deny by default" (plus sécurisé)
# gcloud compute security-policies rules update 2147483647 \
#     --security-policy=policy-web-app \
#     --action=deny-403

# Vérifier la règle par défaut
gcloud compute security-policies rules describe 2147483647 \
    --security-policy=policy-web-app
```

#### Exercice 9.3.3 : Attacher la politique au backend service

```bash
# Attacher la politique
gcloud compute backend-services update backend-web \
    --security-policy=policy-web-app \
    --global

# Vérifier l'attachement
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(securityPolicy)"
```

#### Exercice 9.3.4 : Comprendre la structure des politiques

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    STRUCTURE D'UNE POLITIQUE CLOUD ARMOR
═══════════════════════════════════════════════════════════════════════════════

Policy: policy-web-app
│
├── Rule Priority: 100
│   ├── Match: src-ip-ranges=198.51.100.0/24
│   ├── Action: deny-403
│   └── Preview: false
│
├── Rule Priority: 200
│   ├── Match: expression="origin.region_code != 'FR'"
│   ├── Action: deny-403
│   └── Preview: true
│
├── Rule Priority: 1000
│   ├── Match: expression="evaluatePreconfiguredWaf('sqli-v33-stable')"
│   ├── Action: deny-403
│   └── Preview: false
│
└── Rule Priority: 2147483647 (DEFAULT)
    ├── Match: * (toutes les requêtes)
    ├── Action: allow (ou deny selon configuration)
    └── Preview: false

Évaluation:
1. Les règles sont évaluées par priorité croissante (100 avant 200 avant 1000)
2. La première règle qui matche est appliquée
3. Si aucune règle ne matche, la règle par défaut s'applique
EOF
```

#### Exercice 9.3.5 : Tester que la politique est active

```bash
# La politique est attachée mais autorise tout (par défaut)
# Tester l'accès
curl -s -o /dev/null -w "%{http_code}" http://$LB_IP
# Devrait retourner 200

# Les logs Cloud Armor sont générés même sans blocage
# Voir dans Cloud Console > Network Security > Cloud Armor > Logs
```

---

## Lab 9.4 : Filtrage par IP et géolocalisation
**Difficulté : ⭐⭐**

### Objectifs
- Bloquer des plages IP spécifiques
- Filtrer par pays (géolocalisation)
- Tester les règles de blocage

### Exercices

#### Exercice 9.4.1 : Bloquer une plage IP

```bash
# Récupérer votre IP publique
MY_IP=$(curl -s ifconfig.me)
echo "Votre IP: $MY_IP"

# Créer une règle pour bloquer votre IP (pour test)
gcloud compute security-policies rules create 100 \
    --security-policy=policy-web-app \
    --src-ip-ranges="$MY_IP/32" \
    --action=deny-403 \
    --description="Bloquer mon IP pour test"

# Tester - devrait retourner 403
curl -s -o /dev/null -w "%{http_code}\n" http://$LB_IP

# Supprimer la règle après le test
gcloud compute security-policies rules delete 100 \
    --security-policy=policy-web-app --quiet
```

#### Exercice 9.4.2 : Bloquer des plages IP malveillantes

```bash
# Bloquer plusieurs plages IP (exemple)
gcloud compute security-policies rules create 100 \
    --security-policy=policy-web-app \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24,192.0.2.0/24" \
    --action=deny-403 \
    --description="Bloquer IPs malveillantes connues (RFC 5737)"

# Vérifier la règle
gcloud compute security-policies rules describe 100 \
    --security-policy=policy-web-app
```

#### Exercice 9.4.3 : Filtrage par géolocalisation

```bash
# Autoriser uniquement certains pays (FR, BE, CH, CA)
gcloud compute security-policies rules create 200 \
    --security-policy=policy-web-app \
    --expression="origin.region_code != 'FR' && origin.region_code != 'BE' && origin.region_code != 'CH' && origin.region_code != 'CA'" \
    --action=deny-403 \
    --description="Autoriser uniquement FR, BE, CH, CA"

# Vérifier
gcloud compute security-policies rules describe 200 \
    --security-policy=policy-web-app
```

#### Exercice 9.4.4 : Filtrage géographique inversé (bloquer certains pays)

```bash
# Bloquer des pays spécifiques (exemple)
# Supprimer d'abord la règle précédente si elle existe
gcloud compute security-policies rules delete 200 \
    --security-policy=policy-web-app --quiet 2>/dev/null

# Bloquer certains pays
gcloud compute security-policies rules create 200 \
    --security-policy=policy-web-app \
    --expression="origin.region_code == 'XX' || origin.region_code == 'YY'" \
    --action=deny-403 \
    --description="Bloquer pays XX et YY (exemple)"
```

#### Exercice 9.4.5 : Actions disponibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                        ACTIONS CLOUD ARMOR
═══════════════════════════════════════════════════════════════════════════════

Action          │ Code HTTP │ Comportement
────────────────┼───────────┼────────────────────────────────────────────────
allow           │ -         │ Autorise la requête (passe au backend)
deny-403        │ 403       │ Bloque avec "Forbidden"
deny-404        │ 404       │ Bloque avec "Not Found" (masque l'existence)
deny-502        │ 502       │ Bloque avec "Bad Gateway"
redirect        │ 302       │ Redirige vers une URL spécifiée
throttle        │ 429       │ Limite le débit (rate limiting)
rate_based_ban  │ 403       │ Ban temporaire si seuil dépassé

Recommandations:
- deny-403: Pour les blocages explicites (IPs blacklistées)
- deny-404: Pour cacher l'existence d'un endpoint
- deny-502: Pour simuler une erreur backend
- redirect: Pour les migrations ou pages de maintenance
EOF
```

---

## Lab 9.5 : Expressions CEL avancées
**Difficulté : ⭐⭐⭐**

### Objectifs
- Maîtriser le Common Expression Language (CEL)
- Créer des règles basées sur les headers, path, query
- Combiner plusieurs conditions

### Exercices

#### Exercice 9.5.1 : Attributs disponibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    ATTRIBUTS CEL DISPONIBLES
═══════════════════════════════════════════════════════════════════════════════

ORIGINE
────────────────────────────────────────────────────────────────────────────────
origin.ip                  │ IP source (string)
origin.region_code         │ Code pays ISO 3166-1 alpha-2 (FR, US, DE...)
origin.asn                 │ Numéro d'Autonomous System

REQUÊTE
────────────────────────────────────────────────────────────────────────────────
request.method             │ Méthode HTTP (GET, POST, PUT, DELETE...)
request.path               │ Chemin de la requête (/api/users)
request.query              │ Query string (?page=1&sort=name)
request.headers['name']    │ Valeur d'un header HTTP
request.scheme             │ Protocole (http, https)

MÉTHODES STRING
────────────────────────────────────────────────────────────────────────────────
.matches('regex')          │ Match regex
.contains('substr')        │ Contient substring
.startsWith('prefix')      │ Commence par
.endsWith('suffix')        │ Finit par
.lower()                   │ Convertit en minuscules
.upper()                   │ Convertit en majuscules

OPÉRATEURS
────────────────────────────────────────────────────────────────────────────────
==, !=                     │ Égalité
&&, ||                     │ ET, OU logique
!                          │ Négation
EOF
```

#### Exercice 9.5.2 : Filtrage par chemin (path)

```bash
# Bloquer l'accès à /admin depuis l'extérieur
gcloud compute security-policies rules create 300 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/admin')" \
    --action=deny-403 \
    --description="Bloquer /admin"

# Tester
curl -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/admin
# Devrait retourner 403

curl -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/
# Devrait retourner 200
```

#### Exercice 9.5.3 : Filtrage par méthode HTTP

```bash
# Bloquer les méthodes DELETE et PUT sur /api
gcloud compute security-policies rules create 310 \
    --security-policy=policy-web-app \
    --expression="(request.method == 'DELETE' || request.method == 'PUT') && request.path.startsWith('/api')" \
    --action=deny-403 \
    --description="Bloquer DELETE/PUT sur /api"

# Tester
curl -X DELETE -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/api/test
# Devrait retourner 403

curl -X GET -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/api/test
# Devrait retourner 200 ou 404 (mais pas 403)
```

#### Exercice 9.5.4 : Filtrage par header

```bash
# Bloquer les requêtes sans User-Agent valide
gcloud compute security-policies rules create 320 \
    --security-policy=policy-web-app \
    --expression="!request.headers['user-agent'].matches('Mozilla.*|Chrome.*|Safari.*|curl.*')" \
    --action=deny-403 \
    --description="Bloquer User-Agents invalides"

# Exiger un header API key pour /api
gcloud compute security-policies rules create 330 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/api') && !request.headers['x-api-key'].matches('.+')" \
    --action=deny-403 \
    --description="API key requise pour /api"

# Tester
curl -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/api/test
# 403 (pas de header)

curl -H "x-api-key: test123" -s -o /dev/null -w "%{http_code}\n" http://$LB_IP/api/test
# 200 ou 404 (header présent)
```

#### Exercice 9.5.5 : Combinaison géolocalisation + path

```bash
# Accès /admin uniquement depuis la France
gcloud compute security-policies rules update 300 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/admin') && origin.region_code != 'FR'" \
    --description="Admin uniquement depuis FR"
```

#### Exercice 9.5.6 : Filtrage par query string

```bash
# Bloquer les requêtes avec des paramètres suspects
gcloud compute security-policies rules create 340 \
    --security-policy=policy-web-app \
    --expression="request.query.matches('.*(<script>|SELECT|UNION|DROP).*')" \
    --action=deny-403 \
    --description="Bloquer query strings suspectes"

# Tester
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?id=1%20OR%201=1"
# 403 (si le pattern matche)
```

---

## Lab 9.6 : Règles WAF préconfigurées (OWASP)
**Difficulté : ⭐⭐**

### Objectifs
- Activer les règles WAF préconfigurées
- Configurer les niveaux de sensibilité
- Tester la détection des attaques OWASP

### Exercices

#### Exercice 9.6.1 : Règles WAF disponibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    RÈGLES WAF PRÉCONFIGURÉES (OWASP CRS)
═══════════════════════════════════════════════════════════════════════════════

Règle                    │ Protection contre
─────────────────────────┼──────────────────────────────────────────────────────
sqli-v33-stable          │ Injection SQL
sqli-v33-canary          │ Injection SQL (règles expérimentales)
xss-v33-stable           │ Cross-Site Scripting (XSS)
xss-v33-canary           │ XSS (expérimental)
lfi-v33-stable           │ Local File Inclusion
rfi-v33-stable           │ Remote File Inclusion
rce-v33-stable           │ Remote Code Execution
scanner-detection-v33-stable │ Scanners de vulnérabilités
protocol-attack-v33-stable   │ Attaques protocolaires
php-v33-stable           │ Attaques spécifiques PHP
session-fixation-v33-stable  │ Fixation de session
java-v33-stable          │ Attaques spécifiques Java
nodejs-v33-stable        │ Attaques spécifiques Node.js
cve-canary              │ CVE spécifiques (expérimental)

Niveaux de sensibilité: 0 (minimal) à 4 (paranoïaque)
- 0-1: Peu de faux positifs, couverture basique
- 2: Équilibré (recommandé pour commencer)
- 3-4: Plus de faux positifs, couverture maximale
EOF
```

#### Exercice 9.6.2 : Activer la protection SQL Injection

```bash
# Activer SQLi en mode Preview d'abord
gcloud compute security-policies rules create 1000 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: Protection SQL Injection (preview)"

# Vérifier
gcloud compute security-policies rules describe 1000 \
    --security-policy=policy-web-app
```

#### Exercice 9.6.3 : Activer la protection XSS

```bash
# Activer XSS en mode Preview
gcloud compute security-policies rules create 1100 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('xss-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: Protection XSS (preview)"
```

#### Exercice 9.6.4 : Tester les règles WAF

```bash
# Test SQL Injection (devrait être détecté)
echo "=== Test SQL Injection ==="
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?id=1%20OR%201=1"
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?user=admin'--"
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?search=test%20UNION%20SELECT%20*%20FROM%20users"

# Test XSS (devrait être détecté)
echo "=== Test XSS ==="
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?name=<script>alert(1)</script>"
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?redirect=javascript:alert(1)"

# En mode Preview, le code sera 200 mais les logs montreront la détection
```

#### Exercice 9.6.5 : Ajuster la sensibilité et exclure des règles

```bash
# Supprimer la règle existante
gcloud compute security-policies rules delete 1000 \
    --security-policy=policy-web-app --quiet

# Recréer avec sensibilité ajustée et exclusions
gcloud compute security-policies rules create 1000 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2, 'opt_out_rule_ids': ['owasp-crs-v030301-id942260-sqli', 'owasp-crs-v030301-id942430-sqli']})" \
    --action=deny-403 \
    --preview \
    --description="WAF: SQLi sensibilité 2, règles bruyantes exclues"
```

#### Exercice 9.6.6 : Activer les règles en mode Enforce

```bash
# Une fois validé que pas trop de faux positifs, passer en Enforce
gcloud compute security-policies rules update 1000 \
    --security-policy=policy-web-app \
    --no-preview

gcloud compute security-policies rules update 1100 \
    --security-policy=policy-web-app \
    --no-preview

echo "Règles WAF activées en mode Enforce"

# Tester à nouveau
curl -s -o /dev/null -w "%{http_code}\n" "http://$LB_IP/?id=1%20OR%201=1"
# Devrait maintenant retourner 403
```

---

## Lab 9.7 : Rate Limiting et Throttling
**Difficulté : ⭐⭐**

### Objectifs
- Configurer le throttling (limitation de débit)
- Mettre en place le rate-based ban
- Comprendre les clés de regroupement

### Exercices

#### Exercice 9.7.1 : Comprendre les types de rate limiting

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                        TYPES DE RATE LIMITING
═══════════════════════════════════════════════════════════════════════════════

THROTTLE
────────────────────────────────────────────────────────────────────────────────
• Limite le débit de requêtes
• Requêtes excédentaires: rejetées avec 429 (ou code configuré)
• Pas de ban, juste limitation instantanée

Exemple: Max 100 requêtes/minute par IP
         → La 101e requête reçoit 429
         → Après 1 minute, le compteur se réinitialise

RATE-BASED BAN
────────────────────────────────────────────────────────────────────────────────
• Si le seuil est dépassé, l'IP est bannie temporairement
• Pendant la durée du ban, toutes les requêtes sont rejetées
• Plus agressif que le throttle

Exemple: Si >500 req/min, ban pendant 10 minutes
         → L'IP est complètement bloquée pendant 10 min
         → Même les requêtes légitimes sont refusées

CLÉS DE REGROUPEMENT (enforce-on-key)
────────────────────────────────────────────────────────────────────────────────
IP             │ Par adresse IP source (le plus courant)
ALL            │ Global (toutes requêtes confondues)
HTTP_HEADER    │ Par valeur d'un header (ex: Authorization)
XFF_IP         │ Par IP dans X-Forwarded-For
HTTP_COOKIE    │ Par valeur d'un cookie
HTTP_PATH      │ Par chemin de requête
REGION_CODE    │ Par pays d'origine
EOF
```

#### Exercice 9.7.2 : Configurer le Throttling

```bash
# Limiter à 60 requêtes par minute par IP
gcloud compute security-policies rules create 500 \
    --security-policy=policy-web-app \
    --src-ip-ranges="0.0.0.0/0" \
    --action=throttle \
    --rate-limit-threshold-count=60 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Throttle: max 60 req/min par IP"

# Vérifier
gcloud compute security-policies rules describe 500 \
    --security-policy=policy-web-app
```

#### Exercice 9.7.3 : Tester le Throttling

```bash
# Script de test avec curl en boucle
echo "Test du throttling (65 requêtes rapides)..."

SUCCESS=0
THROTTLED=0

for i in {1..65}; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP/)
    if [ "$CODE" == "200" ]; then
        ((SUCCESS++))
    elif [ "$CODE" == "429" ]; then
        ((THROTTLED++))
    fi
done

echo "Succès: $SUCCESS"
echo "Throttled (429): $THROTTLED"
```

#### Exercice 9.7.4 : Configurer le Rate-Based Ban

```bash
# Si plus de 100 req/min, bannir pendant 5 minutes
gcloud compute security-policies rules create 510 \
    --security-policy=policy-web-app \
    --src-ip-ranges="0.0.0.0/0" \
    --action=rate-based-ban \
    --rate-limit-threshold-count=100 \
    --rate-limit-threshold-interval-sec=60 \
    --ban-duration-sec=300 \
    --conform-action=allow \
    --exceed-action=deny-403 \
    --enforce-on-key=IP \
    --description="Ban 5min si >100 req/min"
```

#### Exercice 9.7.5 : Rate limiting par endpoint

```bash
# Limiter spécifiquement le endpoint /api/login
gcloud compute security-policies rules create 520 \
    --security-policy=policy-web-app \
    --expression="request.path == '/api/login'" \
    --action=throttle \
    --rate-limit-threshold-count=5 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Login: max 5 tentatives/min par IP"
```

#### Exercice 9.7.6 : Rate limiting par header (API)

```bash
# Limiter par clé API (header x-api-key)
gcloud compute security-policies rules create 530 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/api')" \
    --action=throttle \
    --rate-limit-threshold-count=1000 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=HTTP_HEADER \
    --enforce-on-key-name=x-api-key \
    --description="API: max 1000 req/min par API key"
```

---

## Lab 9.8 : Mode Preview et analyse des logs
**Difficulté : ⭐⭐**

### Objectifs
- Utiliser le mode Preview pour tester les règles
- Analyser les logs Cloud Armor
- Créer un workflow de validation

### Exercices

#### Exercice 9.8.1 : Activer le mode Preview

```bash
# Le mode Preview permet de voir ce qui serait bloqué sans bloquer
# Très utile pour éviter les faux positifs

# Mettre une règle existante en Preview
gcloud compute security-policies rules update 1000 \
    --security-policy=policy-web-app \
    --preview

# Créer une nouvelle règle en mode Preview
gcloud compute security-policies rules create 1200 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('lfi-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: LFI (preview)"
```

#### Exercice 9.8.2 : Générer du trafic de test

```bash
# Générer des requêtes qui déclenchent les règles en preview
echo "Génération de trafic de test..."

# Requêtes SQL injection
for i in {1..10}; do
    curl -s "http://$LB_IP/?id=$i%20OR%201=1" > /dev/null
done

# Requêtes LFI
for path in "../../../etc/passwd" "....//....//etc/passwd" "/etc/passwd"; do
    curl -s "http://$LB_IP/?file=$path" > /dev/null
done

echo "Trafic de test généré"
```

#### Exercice 9.8.3 : Analyser les logs Cloud Armor

```bash
# Logs des requêtes qui auraient été bloquées (preview)
gcloud logging read '
    resource.type="http_load_balancer" AND
    jsonPayload.enforcedSecurityPolicy.outcome="DENY" AND
    jsonPayload.enforcedSecurityPolicy.preview=true
' --limit=20 --format=json

# Logs des requêtes réellement bloquées
gcloud logging read '
    resource.type="http_load_balancer" AND
    jsonPayload.enforcedSecurityPolicy.outcome="DENY" AND
    jsonPayload.enforcedSecurityPolicy.preview=false
' --limit=20 --format=json

# Logs par politique spécifique
gcloud logging read "
    resource.type=\"http_load_balancer\" AND
    jsonPayload.enforcedSecurityPolicy.name=\"policy-web-app\"
" --limit=20 --format="table(
    timestamp,
    jsonPayload.enforcedSecurityPolicy.priority,
    jsonPayload.enforcedSecurityPolicy.configuredAction,
    jsonPayload.enforcedSecurityPolicy.outcome,
    jsonPayload.enforcedSecurityPolicy.preview
)"
```

#### Exercice 9.8.4 : Structure des logs

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    STRUCTURE DES LOGS CLOUD ARMOR
═══════════════════════════════════════════════════════════════════════════════

{
  "httpRequest": {
    "requestMethod": "GET",
    "requestUrl": "http://example.com/?id=1 OR 1=1",
    "remoteIp": "203.0.113.50",
    "userAgent": "curl/7.68.0"
  },
  "jsonPayload": {
    "enforcedSecurityPolicy": {
      "name": "policy-web-app",
      "priority": 1000,
      "configuredAction": "DENY",
      "outcome": "DENY",         // ACCEPT ou DENY
      "preview": false,          // true si mode preview
      "matchedFieldType": "ARGS", // Champ qui a matché
      "matchedFieldValue": "1 OR 1=1",
      "preconfiguredExprIds": [
        "owasp-crs-v030301-id942100-sqli"
      ]
    },
    "previewSecurityPolicy": {   // Si d'autres règles en preview auraient matché
      ...
    }
  }
}

Champs clés:
- outcome: Résultat final (ACCEPT/DENY)
- preview: true = règle en mode test
- preconfiguredExprIds: ID de la règle WAF qui a matché
- matchedFieldType: Où l'attaque a été détectée (ARGS, HEADERS, BODY...)
EOF
```

#### Exercice 9.8.5 : Workflow de validation

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    WORKFLOW DE VALIDATION DES RÈGLES
═══════════════════════════════════════════════════════════════════════════════

1. CRÉER LA RÈGLE EN MODE PREVIEW
   gcloud compute security-policies rules create PRIORITY \
       --security-policy=POLICY \
       --expression="..." \
       --action=deny-403 \
       --preview

2. OBSERVER LES LOGS (24-48h minimum)
   - Identifier les faux positifs
   - Vérifier que les vraies attaques sont détectées
   - Analyser les patterns

3. AJUSTER SI NÉCESSAIRE
   - Modifier la sensibilité WAF
   - Exclure des règles spécifiques (opt_out_rule_ids)
   - Affiner l'expression CEL

4. PASSER EN MODE ENFORCE
   gcloud compute security-policies rules update PRIORITY \
       --security-policy=POLICY \
       --no-preview

5. SURVEILLER EN PRODUCTION
   - Créer des alertes sur les blocages
   - Réviser régulièrement les logs
   - Ajuster si nouveaux faux positifs

⚠️ NE JAMAIS activer directement en Enforce sans période de Preview!
EOF
```

---

## Lab 9.9 : Named IP Lists et Threat Intelligence
**Difficulté : ⭐⭐**

### Objectifs
- Utiliser les Named IP Lists gérées par Google
- Configurer le Threat Intelligence
- Bloquer les sources malveillantes connues

### Exercices

#### Exercice 9.9.1 : Named IP Lists disponibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                        NAMED IP LISTS DISPONIBLES
═══════════════════════════════════════════════════════════════════════════════

LISTES DE SOURCES (pour autoriser des services légitimes)
────────────────────────────────────────────────────────────────────────────────
sourceiplist-fastly            │ IPs du CDN Fastly
sourceiplist-cloudflare        │ IPs Cloudflare
sourceiplist-imperva           │ IPs Imperva
sourceiplist-google-crawlers   │ Googlebot et crawlers Google
sourceiplist-public-clouds     │ Plages des cloud providers

LISTES DE THREAT INTELLIGENCE (pour bloquer)
────────────────────────────────────────────────────────────────────────────────
iplist-tor-exit-nodes          │ Nœuds de sortie Tor
iplist-known-malicious-ips     │ IPs malveillantes connues
iplist-search-engines-crawlers │ Tous les crawlers (moteurs de recherche)
iplist-public-clouds-aws       │ Plages AWS
iplist-public-clouds-azure     │ Plages Azure
iplist-public-clouds-gcp       │ Plages GCP
EOF
```

#### Exercice 9.9.2 : Autoriser les crawlers Google

```bash
# Autoriser Googlebot (priorité haute pour ne pas bloquer par d'autres règles)
gcloud compute security-policies rules create 10 \
    --security-policy=policy-web-app \
    --expression="origin.ip.matches(getNamedIpList('sourceiplist-google-crawlers'))" \
    --action=allow \
    --description="Autoriser Googlebot"
```

#### Exercice 9.9.3 : Bloquer les nœuds Tor

```bash
# Bloquer le trafic depuis les nœuds de sortie Tor
gcloud compute security-policies rules create 150 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-tor-exit-nodes')" \
    --action=deny-403 \
    --description="Bloquer Tor exit nodes"
```

#### Exercice 9.9.4 : Bloquer les IPs malveillantes connues

```bash
# Bloquer les IPs identifiées comme malveillantes par Google
gcloud compute security-policies rules create 160 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-known-malicious-ips')" \
    --action=deny-403 \
    --description="Bloquer IPs malveillantes"
```

#### Exercice 9.9.5 : Forcer le passage par un CDN

```bash
# Accepter uniquement le trafic venant de Cloudflare ou Fastly
# (utile si vous utilisez un CDN devant GCP)
gcloud compute security-policies rules create 20 \
    --security-policy=policy-web-app \
    --expression="!origin.ip.matches(getNamedIpList('sourceiplist-fastly')) && !origin.ip.matches(getNamedIpList('sourceiplist-cloudflare'))" \
    --action=deny-403 \
    --description="Trafic doit passer par CDN"

# Note: Désactiver si vous n'utilisez pas de CDN!
gcloud compute security-policies rules delete 20 \
    --security-policy=policy-web-app --quiet
```

---

## Lab 9.10 : Edge Security Policies
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre les Edge Security Policies
- Configurer une protection au niveau CDN
- Différencier Backend vs Edge policies

### Exercices

#### Exercice 9.10.1 : Edge vs Backend Security Policies

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                   EDGE vs BACKEND SECURITY POLICIES
═══════════════════════════════════════════════════════════════════════════════

                            Internet
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Google Edge       │
                    │   (Point of Presence)│
                    │                     │
                    │ ┌─────────────────┐ │
                    │ │ EDGE SECURITY   │ │ ◄── Filtrage très précoce
                    │ │ POLICY          │ │     (avant le cache CDN)
                    │ └─────────────────┘ │
                    │                     │
                    │ ┌─────────────────┐ │
                    │ │   Cloud CDN     │ │
                    │ │   (Cache)       │ │
                    │ └─────────────────┘ │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Load Balancer     │
                    │                     │
                    │ ┌─────────────────┐ │
                    │ │ BACKEND SECURITY│ │ ◄── Filtrage complet
                    │ │ POLICY          │ │     (WAF, expressions CEL)
                    │ └─────────────────┘ │
                    └──────────┬──────────┘
                               │
                               ▼
                         Backend Service

EDGE SECURITY POLICY:
✅ Filtrage au plus tôt (avant CDN)
✅ Réduit la charge sur les backends
✅ Protège le cache CDN
❌ Règles plus simples (pas de WAF)
❌ Pas de support complet CEL

BACKEND SECURITY POLICY:
✅ Fonctionnalités complètes (WAF, CEL)
✅ Expressions avancées
❌ Filtrage plus tardif
❌ Requête a déjà traversé le CDN
EOF
```

#### Exercice 9.10.2 : Créer une Edge Security Policy

```bash
# Créer une politique de type CLOUD_ARMOR_EDGE
gcloud compute security-policies create edge-policy \
    --type=CLOUD_ARMOR_EDGE \
    --description="Politique edge pour protection CDN"

# Ajouter une règle de blocage IP
gcloud compute security-policies rules create 100 \
    --security-policy=edge-policy \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24" \
    --action=deny-403 \
    --description="Bloquer IPs au edge"

# Ajouter une règle de géolocalisation
gcloud compute security-policies rules create 200 \
    --security-policy=edge-policy \
    --expression="origin.region_code == 'XX'" \
    --action=deny-403 \
    --description="Bloquer pays XX au edge"
```

#### Exercice 9.10.3 : Attacher l'Edge Policy (nécessite Cloud CDN)

```bash
# Note: Ceci nécessite que Cloud CDN soit activé sur le backend service

# Activer Cloud CDN sur le backend
gcloud compute backend-services update backend-web \
    --enable-cdn \
    --global

# Attacher l'edge security policy
gcloud compute backend-services update backend-web \
    --edge-security-policy=edge-policy \
    --global

# Vérifier
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(securityPolicy,edgeSecurityPolicy,enableCDN)"
```

#### Exercice 9.10.4 : Combiner Edge et Backend policies

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    STRATÉGIE RECOMMANDÉE
═══════════════════════════════════════════════════════════════════════════════

EDGE SECURITY POLICY (filtrage précoce):
- Blocage IP géographique
- Blocage de plages IP connues (blacklists)
- Rate limiting basique

BACKEND SECURITY POLICY (filtrage complet):
- WAF (OWASP)
- Expressions CEL avancées
- Rate limiting par endpoint
- Bot Management
- Adaptive Protection

Exemple de répartition:
┌───────────────────────────────────────────────────────────────────────────┐
│ EDGE POLICY                                                               │
├───────────────────────────────────────────────────────────────────────────┤
│ Priority 100: Bloquer IPs blacklistées                                    │
│ Priority 200: Bloquer pays non autorisés                                  │
│ Priority 500: Rate limit global (1000 req/min par IP)                     │
│ Default: ALLOW (passe au backend)                                         │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│ BACKEND POLICY                                                            │
├───────────────────────────────────────────────────────────────────────────┤
│ Priority 10: Autoriser Googlebot                                          │
│ Priority 50: Bloquer bots malveillants (Bot Management)                   │
│ Priority 1000: WAF SQLi                                                   │
│ Priority 1100: WAF XSS                                                    │
│ Priority 2000: Rate limit /api/login (5 req/min)                          │
│ Default: ALLOW                                                            │
└───────────────────────────────────────────────────────────────────────────┘
EOF
```

---

## Lab 9.11 : Scénario intégrateur - Protection complète
**Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer une politique de sécurité complète
- Combiner toutes les fonctionnalités
- Documenter la stratégie de protection

### Architecture de protection

```
                            Internet
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        COUCHE 1: INFRASTRUCTURE GOOGLE                       │
│                        (Protection automatique L3/L4)                        │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        COUCHE 2: EDGE SECURITY POLICY                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ P100: Bloquer IPs blacklistées                                          │ │
│  │ P150: Bloquer Tor exit nodes                                            │ │
│  │ P200: Bloquer pays non autorisés                                        │ │
│  │ P500: Rate limit global (1000/min)                                      │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        COUCHE 3: BACKEND SECURITY POLICY                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ P10: Autoriser Googlebot                                                │ │
│  │ P50: Bloquer bots malveillants                                          │ │
│  │ P100: Bloquer IPs malveillantes (Threat Intel)                          │ │
│  │ P300: Bloquer accès /admin                                              │ │
│  │ P500: Rate limit API (100/min par API key)                              │ │
│  │ P510: Rate limit login (5/min par IP)                                   │ │
│  │ P1000: WAF SQLi                                                         │ │
│  │ P1100: WAF XSS                                                          │ │
│  │ P1200: WAF LFI/RFI                                                      │ │
│  │ Default: ALLOW                                                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
                         Backend Services
```

### Script de déploiement complet

```bash
#!/bin/bash
# Politique de sécurité Cloud Armor complète

set -e

POLICY_NAME="policy-complete"

echo "=========================================="
echo "  DÉPLOIEMENT POLITIQUE CLOUD ARMOR"
echo "=========================================="

# ===== CRÉER LA POLITIQUE =====
echo ">>> Création de la politique..."
gcloud compute security-policies create $POLICY_NAME \
    --description="Politique de sécurité complète"

# ===== RÈGLES DE PRIORITÉ HAUTE (10-99): AUTORISATIONS EXPLICITES =====
echo ">>> Règles d'autorisation..."

# Autoriser Googlebot
gcloud compute security-policies rules create 10 \
    --security-policy=$POLICY_NAME \
    --expression="origin.ip.matches(getNamedIpList('sourceiplist-google-crawlers'))" \
    --action=allow \
    --description="Autoriser Googlebot"

# ===== RÈGLES DE BLOCAGE IP (100-199) =====
echo ">>> Règles de blocage IP..."

# Bloquer IPs blacklistées manuelles
gcloud compute security-policies rules create 100 \
    --security-policy=$POLICY_NAME \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24" \
    --action=deny-403 \
    --description="IPs blacklistées manuelles"

# Bloquer Tor
gcloud compute security-policies rules create 150 \
    --security-policy=$POLICY_NAME \
    --expression="evaluateThreatIntelligence('iplist-tor-exit-nodes')" \
    --action=deny-403 \
    --description="Bloquer Tor"

# Bloquer IPs malveillantes connues
gcloud compute security-policies rules create 160 \
    --security-policy=$POLICY_NAME \
    --expression="evaluateThreatIntelligence('iplist-known-malicious-ips')" \
    --action=deny-403 \
    --description="IPs malveillantes"

# ===== RÈGLES GÉOGRAPHIQUES (200-299) =====
echo ">>> Règles géographiques..."

# Exemple: Autoriser uniquement certains pays
# gcloud compute security-policies rules create 200 \
#     --security-policy=$POLICY_NAME \
#     --expression="origin.region_code != 'FR' && origin.region_code != 'BE'" \
#     --action=deny-403 \
#     --description="Autoriser FR, BE uniquement"

# ===== RÈGLES D'ACCÈS (300-399) =====
echo ">>> Règles d'accès..."

# Bloquer /admin
gcloud compute security-policies rules create 300 \
    --security-policy=$POLICY_NAME \
    --expression="request.path.startsWith('/admin')" \
    --action=deny-403 \
    --description="Bloquer /admin"

# ===== RATE LIMITING (500-599) =====
echo ">>> Règles de rate limiting..."

# Rate limit global
gcloud compute security-policies rules create 500 \
    --security-policy=$POLICY_NAME \
    --src-ip-ranges="0.0.0.0/0" \
    --action=throttle \
    --rate-limit-threshold-count=100 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Rate limit: 100 req/min par IP"

# Rate limit login
gcloud compute security-policies rules create 510 \
    --security-policy=$POLICY_NAME \
    --expression="request.path == '/api/login' || request.path == '/login'" \
    --action=rate-based-ban \
    --rate-limit-threshold-count=5 \
    --rate-limit-threshold-interval-sec=60 \
    --ban-duration-sec=300 \
    --conform-action=allow \
    --exceed-action=deny-403 \
    --enforce-on-key=IP \
    --description="Login: 5 tentatives/min, ban 5min"

# ===== WAF RULES (1000-1999) =====
echo ">>> Règles WAF..."

# SQLi
gcloud compute security-policies rules create 1000 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2})" \
    --action=deny-403 \
    --description="WAF: SQL Injection"

# XSS
gcloud compute security-policies rules create 1100 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 2})" \
    --action=deny-403 \
    --description="WAF: XSS"

# LFI
gcloud compute security-policies rules create 1200 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('lfi-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Local File Inclusion"

# RFI
gcloud compute security-policies rules create 1300 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('rfi-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Remote File Inclusion"

# RCE
gcloud compute security-policies rules create 1400 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('rce-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Remote Code Execution"

# Scanner detection
gcloud compute security-policies rules create 1500 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('scannerdetection-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Scanner Detection"

# ===== ATTACHER AU BACKEND =====
echo ">>> Attachement au backend..."
gcloud compute backend-services update backend-web \
    --security-policy=$POLICY_NAME \
    --global

echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="

# Afficher le récapitulatif
gcloud compute security-policies rules list \
    --security-policy=$POLICY_NAME \
    --format="table(priority,action,description)"
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage Module 9

echo "=== Suppression des politiques Cloud Armor ==="
for POLICY in policy-web-app policy-complete edge-policy; do
    # Détacher des backends
    for BACKEND in $(gcloud compute backend-services list --format="get(name)" 2>/dev/null); do
        gcloud compute backend-services update $BACKEND \
            --security-policy="" --global 2>/dev/null
        gcloud compute backend-services update $BACKEND \
            --edge-security-policy="" --global 2>/dev/null
    done
    # Supprimer la politique
    gcloud compute security-policies delete $POLICY --quiet 2>/dev/null
done

echo "=== Suppression du Load Balancer ==="
gcloud compute forwarding-rules delete fr-http --global --quiet 2>/dev/null
gcloud compute target-http-proxies delete proxy-http --quiet 2>/dev/null
gcloud compute url-maps delete urlmap-web --quiet 2>/dev/null
gcloud compute backend-services delete backend-web --global --quiet 2>/dev/null
gcloud compute health-checks delete hc-http-80 --quiet 2>/dev/null
gcloud compute addresses delete lb-ip --global --quiet 2>/dev/null

echo "=== Suppression des instances ==="
gcloud compute instance-groups managed delete web-ig --zone=europe-west1-b --quiet 2>/dev/null
gcloud compute instance-templates delete web-template --quiet 2>/dev/null

echo "=== Suppression du réseau ==="
gcloud compute firewall-rules delete vpc-armor-lab-allow-health-check --quiet 2>/dev/null
gcloud compute firewall-rules delete vpc-armor-lab-allow-lb --quiet 2>/dev/null
gcloud compute firewall-rules delete vpc-armor-lab-allow-iap --quiet 2>/dev/null
gcloud compute networks subnets delete subnet-web --region=europe-west1 --quiet 2>/dev/null
gcloud compute networks delete vpc-armor-lab --quiet 2>/dev/null

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 9

### Politiques Cloud Armor
```bash
# Créer
gcloud compute security-policies create NAME

# Ajouter une règle
gcloud compute security-policies rules create PRIORITY --security-policy=NAME \
    --src-ip-ranges=CIDR --action=ACTION

# Avec expression CEL
gcloud compute security-policies rules create PRIORITY --security-policy=NAME \
    --expression="EXPRESSION" --action=ACTION

# Mode Preview
gcloud compute security-policies rules create PRIORITY --security-policy=NAME \
    --expression="..." --action=deny-403 --preview

# Attacher au backend
gcloud compute backend-services update BACKEND --security-policy=NAME --global
```

### Règles WAF
```bash
# SQLi basique
--expression="evaluatePreconfiguredWaf('sqli-v33-stable')"

# Avec sensibilité
--expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2})"

# Avec exclusions
--expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'opt_out_rule_ids': ['rule-id-1', 'rule-id-2']})"
```

### Rate Limiting
```bash
# Throttle
--action=throttle \
--rate-limit-threshold-count=100 \
--rate-limit-threshold-interval-sec=60 \
--conform-action=allow \
--exceed-action=deny-429 \
--enforce-on-key=IP

# Rate-based ban
--action=rate-based-ban \
--rate-limit-threshold-count=100 \
--rate-limit-threshold-interval-sec=60 \
--ban-duration-sec=300 \
--conform-action=allow \
--exceed-action=deny-403 \
--enforce-on-key=IP
```
