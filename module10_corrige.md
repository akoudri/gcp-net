# Module 10 - Équilibrage de Charge et Gestion du Trafic
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 10.1 : Vue d'ensemble des Load Balancers

### Choisir le bon Load Balancer

**Q : Comment choisir le bon type de Load Balancer ?**

> Le choix dépend de plusieurs critères :
>
> | Critère | Options |
> |---------|---------|
> | **Protocole** | HTTP/HTTPS → Application LB (L7) <br> TCP/UDP → Network LB (L4) |
> | **Audience** | Internet → External LB <br> VPC interne → Internal LB |
> | **Portée** | Mondiale → Global LB <br> Régionale → Regional LB |
> | **Performance** | Fonctionnalités → Proxy LB <br> Latence min → Passthrough LB |
>
> Décision rapide :
> - **Web app mondiale** → Global External Application LB
> - **API interne** → Internal Application LB
> - **Jeux/VoIP** → Regional Passthrough Network LB
> - **Base de données** → Internal Passthrough Network LB

---

## Lab 10.2 : Global External Application LB

### Composants du Load Balancer

**Q : Quels sont les composants d'un Application Load Balancer ?**

> Les composants sont (dans l'ordre du flux) :
>
> ```
> 1. Forwarding Rule
>    └── Point d'entrée (IP + port)
>    
> 2. Target Proxy
>    └── Terminaison TLS, routage vers URL Map
>    
> 3. URL Map
>    └── Routage basé sur host/path
>    
> 4. Backend Service
>    └── Configuration backend (health check, session, CDN)
>    
> 5. Backend Group
>    └── Instance Group, NEG, ou Backend Bucket
>    
> 6. Health Check
>    └── Vérification de la santé des backends
> ```
>
> Chaque composant a un rôle spécifique et peut être réutilisé.

---

## Lab 10.3 : URL Maps et routage avancé

### Types de routage

**Q : Quels critères de routage sont disponibles dans les URL Maps ?**

> Les URL Maps supportent plusieurs critères de routage :
>
> | Critère | Exemple | Usage |
> |---------|---------|-------|
> | **Host** | api.example.com vs www.example.com | Multi-domaines |
> | **Path** | /api/*, /static/*, /v2/* | Microservices |
> | **Headers** | X-Version: v2 | Feature flags, canary |
> | **Query params** | ?version=beta | Tests A/B |
> | **Méthode HTTP** | GET, POST, PUT | Sécurité |
>
> Les critères peuvent être combinés dans des `routeRules` avec priorités.

---

## Lab 10.4 : Gestion du trafic - Canary et Blue-Green

### Différence Canary vs Blue-Green

**Q : Quelle est la différence entre un déploiement Canary et Blue-Green ?**

> | Aspect | Canary | Blue-Green |
> |--------|--------|------------|
> | **Principe** | Rollout progressif (1%→10%→50%→100%) | Switch instantané (0%→100%) |
> | **Risque** | Limité (peu d'utilisateurs affectés) | Plus élevé (tous les utilisateurs) |
> | **Rollback** | Réduire le pourcentage | Switch inverse |
> | **Durée** | Progressive (heures/jours) | Instantanée |
> | **Observation** | Métriques en temps réel | Validation avant switch |
>
> **Canary** :
> ```
> Jour 1: 100% v1, 0% v2
> Jour 2: 90% v1, 10% v2 (observer)
> Jour 3: 50% v1, 50% v2 (valider)
> Jour 4: 0% v1, 100% v2 (complet)
> ```
>
> **Blue-Green** :
> ```
> État initial: 100% Blue (v1)
> Préparation: Green (v2) prêt en standby
> Switch: 100% Green (v2)
> Rollback si problème: 100% Blue (v1)
> ```

---

## Lab 10.5 : Session Affinity

### Types de session affinity

**Q : Quand utiliser quel type de session affinity ?**

> | Type | Mécanisme | Cas d'usage |
> |------|-----------|-------------|
> | **NONE** | Pas d'affinité | Apps stateless (recommandé) |
> | **CLIENT_IP** | Hash IP client | Apps simples, pas de proxy devant |
> | **GENERATED_COOKIE** | Cookie LB | Sessions web, shopping cart |
> | **HEADER_FIELD** | Hash d'un header | APIs avec tokens |
> | **HTTP_COOKIE** | Cookie applicatif | Sessions déjà gérées par l'app |
>
> ⚠️ **Important** :
> - L'affinité n'est PAS garantie si le backend devient unhealthy
> - Préférer des applications **stateless** avec cache externe (Redis)
> - L'affinité ne survit pas aux changements de pool de backends

---

## Lab 10.7 : Network Load Balancer (L4)

### Proxy vs Passthrough

**Q : Quelle est la différence entre un LB Proxy et Passthrough ?**

> | Aspect | Proxy | Passthrough |
> |--------|-------|-------------|
> | **Terminaison connexion** | Oui (au LB) | Non |
> | **IP client préservée** | Non (X-Forwarded-For) | Oui |
> | **Latence** | Plus élevée | Minimale |
> | **Fonctionnalités L7** | Oui | Non |
> | **TLS termination** | Oui | Non |
> | **Cloud Armor** | Oui | Non |
> | **CDN** | Oui | Non |
>
> **Passthrough** utilise DSR (Direct Server Return) :
> - Le client envoie au LB
> - Le LB transfère au backend
> - Le backend répond **directement** au client
> - Performance maximale pour TCP/UDP brut

---

## Lab 10.10 : Cloud CDN

### Modes de cache

**Q : Comment choisir le mode de cache CDN ?**

> | Mode | Comportement | Usage |
> |------|--------------|-------|
> | **CACHE_ALL_STATIC** | Cache automatique du contenu statique | Sites web standards |
> | **USE_ORIGIN_HEADERS** | Respecte Cache-Control de l'origin | Contrôle fin côté app |
> | **FORCE_CACHE_ALL** | Cache TOUT (ignore headers) | CDN origin 100% statique |
>
> Recommandations :
> - **CACHE_ALL_STATIC** : Bon pour commencer, simple
> - **USE_ORIGIN_HEADERS** : Plus de contrôle, nécessite configuration app
> - **FORCE_CACHE_ALL** : Attention aux données dynamiques!
>
> Paramètres TTL :
> - `default-ttl` : TTL si pas de header (défaut: 3600s)
> - `max-ttl` : Cap les valeurs trop longues
> - `client-ttl` : TTL envoyé au navigateur

---

# Corrigé du Quizz du Module 10

**1. Quel type de Load Balancer utiliser pour une application web globale ?**

> **b. Global external Application LB** ✅
>
> Raisons :
> - **Global** : IP Anycast, routage vers le backend le plus proche
> - **External** : Accessible depuis Internet
> - **Application (L7)** : Routage HTTP/HTTPS, TLS termination
>
> Fonctionnalités incluses :
> - Cloud CDN pour le cache
> - Cloud Armor pour la sécurité
> - Routage par URL/headers
> - Certificats SSL managés

---

**2. Quels sont les composants d'un Application Load Balancer ?**

> Les 6 composants principaux sont :
>
> 1. **Forwarding Rule** - Point d'entrée (IP + port)
> 2. **Target Proxy** - Terminaison TLS, liaison avec URL Map
> 3. **URL Map** - Routage basé sur host/path/headers
> 4. **Backend Service** - Configuration du backend
> 5. **Backend Group** - Instance Group, NEG, ou Bucket
> 6. **Health Check** - Vérification de la santé
>
> Flux :
> ```
> Client → Forwarding Rule → Target Proxy → URL Map → Backend Service → Backend
> ```

---

**3. Quelle est la différence entre un LB proxy et passthrough ?**

> | Proxy | Passthrough |
> |-------|-------------|
> | Termine la connexion client | Transmet sans modification |
> | Crée nouvelle connexion vers backend | Connexion directe |
> | IP client via X-Forwarded-For | IP client préservée |
> | Fonctionnalités L7 (routage, TLS) | Performance maximale |
> | Cloud Armor, CDN supportés | Pas de fonctionnalités avancées |
>
> Proxy = Fonctionnalités
> Passthrough = Performance

---

**4. Comment faire un déploiement canary avec 10% du trafic ?**

> Utiliser le **traffic splitting** dans l'URL Map :
>
> ```yaml
> routeRules:
> - priority: 1
>   matchRules:
>   - prefixMatch: /
>   routeAction:
>     weightedBackendServices:
>     - backendService: backend-v1
>       weight: 90
>     - backendService: backend-v2
>       weight: 10
> ```
>
> Ou via gcloud (import YAML) :
> ```bash
> gcloud compute url-maps import urlmap-canary \
>     --source=urlmap-canary.yaml --global
> ```
>
> Progression typique : 10% → 25% → 50% → 100%

---

**5. Quel type de NEG permet d'inclure des backends on-premise ?**

> Le **Hybrid NEG** (type `NON_GCP_PRIVATE_IP_PORT`) permet d'inclure des backends on-premise.
>
> ```bash
> gcloud compute network-endpoint-groups create neg-onprem \
>     --network-endpoint-type=NON_GCP_PRIVATE_IP_PORT \
>     --zone=europe-west1-b \
>     --network=mon-vpc
>
> gcloud compute network-endpoint-groups update neg-onprem \
>     --add-endpoint="ip=192.168.1.10,port=80"
> ```
>
> Prérequis :
> - Connectivité via VPN ou Interconnect
> - IPs privées routables depuis GCP
> - Health checks accessibles

---

**6. Que signifie un cache hit ratio de 85% ?**

> Un cache hit ratio de 85% signifie que **85% des requêtes sont servies depuis le cache CDN** et seulement 15% nécessitent un accès à l'origin.
>
> Calcul :
> ```
> cache_hit_ratio = cache_hits / (cache_hits + cache_misses)
> 85% = 850 hits / (850 hits + 150 misses)
> ```
>
> Interprétation :
> - **> 80%** : Excellent, cache bien configuré
> - **50-80%** : Correct, potentiel d'amélioration
> - **< 50%** : Problème de configuration ou contenu non-cacheable
>
> Pour améliorer :
> - Augmenter les TTL
> - Utiliser CACHE_ALL_STATIC
> - Réduire les query strings dans la cache key

---

**7. Comment forcer l'invalidation du cache CDN ?**

> Utiliser la commande `invalidate-cdn-cache` :
>
> ```bash
> # Invalider un fichier spécifique
> gcloud compute url-maps invalidate-cdn-cache urlmap-web \
>     --path="/static/style.css" \
>     --global
>
> # Invalider un préfixe
> gcloud compute url-maps invalidate-cdn-cache urlmap-web \
>     --path="/images/*" \
>     --global
>
> # Invalider tout le cache
> gcloud compute url-maps invalidate-cdn-cache urlmap-web \
>     --path="/*" \
>     --global
> ```
>
> ⚠️ Notes :
> - L'invalidation peut prendre quelques minutes à se propager
> - Limiter les invalidations fréquentes (coût et délai)
> - Utiliser le versioning dans les URLs plutôt que l'invalidation

---

**8. Quel mode de session affinity utilise un cookie généré par le LB ?**

> Le mode **GENERATED_COOKIE** utilise un cookie généré par le Load Balancer.
>
> ```bash
> gcloud compute backend-services update backend-web \
>     --session-affinity=GENERATED_COOKIE \
>     --affinity-cookie-ttl=3600 \
>     --global
> ```
>
> Le LB génère automatiquement un cookie (ex: `GCLB`) qui maintient l'utilisateur sur le même backend.
>
> Différence avec HTTP_COOKIE :
> - **GENERATED_COOKIE** : Le LB crée et gère le cookie
> - **HTTP_COOKIE** : L'application crée le cookie, le LB l'utilise

---

# Questions de réflexion supplémentaires

**Q1 : Comment concevoir une architecture haute disponibilité avec les Load Balancers GCP ?**

> Architecture HA multi-région :
>
> ```
> ┌────────────────────────────────────────────────────────────────────┐
> │                  Global External Application LB                    │
> │                  (IP Anycast, routage automatique)                 │
> └─────────────────────────────┬──────────────────────────────────────┘
>                               │
>          ┌────────────────────┼────────────────────┐
>          │                    │                    │
>          ▼                    ▼                    ▼
>    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
>    │  europe-west1│    │   us-east1   │    │ asia-east1   │
>    │  (Backend)   │    │  (Backend)   │    │  (Backend)   │
>    └──────────────┘    └──────────────┘    └──────────────┘
> ```
>
> Bonnes pratiques :
> - **Multi-région** : Backends dans au moins 2 régions
> - **Autoscaling** : Absorber les pics de charge
> - **Health checks** : Détection rapide des pannes
> - **Failover automatique** : Le LB global route vers les backends healthy
> - **Cloud CDN** : Cache pour réduire la charge origin

---

**Q2 : Comment optimiser les performances d'un Application LB ?**

> Optimisations recommandées :
>
> 1. **Cloud CDN** :
>    - Activer pour le contenu statique
>    - Objectif: cache hit ratio > 80%
>
> 2. **Health checks** :
>    - Intervalle court (5-10s) pour détection rapide
>    - Endpoint léger (/health) qui vérifie les dépendances critiques
>
> 3. **Backend configuration** :
>    - `balancing-mode=UTILIZATION` avec `max-utilization=0.8`
>    - Autoscaling basé sur CPU ou requêtes
>
> 4. **Connection draining** :
>    - Activer pour graceful shutdown
>    - Timeout adapté au temps de traitement
>
> 5. **HTTP/2** :
>    - Activer entre le LB et les backends si supporté
>    - Multiplexing des requêtes
>
> 6. **Compression** :
>    - Activer gzip au niveau du backend
>    - Ou configurer Cloud CDN pour compresser

---

**Q3 : Comment sécuriser un Application Load Balancer ?**

> Mesures de sécurité :
>
> 1. **Cloud Armor** :
>    - WAF (OWASP rules)
>    - Rate limiting
>    - Blocage IP/géo
>
> 2. **HTTPS obligatoire** :
>    - Certificats managés
>    - Redirection HTTP→HTTPS
>    - TLS 1.2+ minimum
>
> 3. **IAP (Identity-Aware Proxy)** :
>    - Authentification Google
>    - Pour les applications internes
>
> 4. **Signed URLs** :
>    - Contenu premium/payant
>    - Accès temporaire
>
> 5. **Logging** :
>    - Activer les logs HTTP
>    - Exporter vers BigQuery pour analyse
>
> 6. **Headers de sécurité** :
>    - HSTS, CSP, X-Frame-Options
>    - Via custom response headers

---

**Q4 : Comment débugger un problème de Load Balancer ?**

> Checklist de debugging :
>
> 1. **Health checks** :
>    ```bash
>    gcloud compute backend-services get-health BACKEND --global
>    ```
>    - Tous les backends doivent être HEALTHY
>
> 2. **Logs HTTP** :
>    ```bash
>    gcloud logging read 'resource.type="http_load_balancer"' --limit=50
>    ```
>    - Chercher les erreurs 5xx
>
> 3. **Métriques** :
>    - Latence backend vs total
>    - Taux d'erreur par backend
>
> 4. **Configuration** :
>    - URL Map correct ?
>    - Port name correspond au named port ?
>    - Firewall rules pour health checks ?
>
> 5. **Backend** :
>    - Application démarre correctement ?
>    - Endpoint /health accessible ?
>    - Logs applicatifs ?

---

**Q5 : Quelle est la tarification des Load Balancers GCP ?**

> Composants de coût :
>
> | Composant | Coût approximatif |
> |-----------|------------------|
> | Forwarding Rule | ~$18/mois |
> | Traitement données (ingress) | Gratuit |
> | Traitement données (egress) | ~$0.008-0.012/GB |
> | Cloud Armor | ~$5/règle/mois + $0.75/M requêtes |
> | Cloud CDN | ~$0.02-0.08/GB (selon région) |
>
> Optimisations :
> - Utiliser Cloud CDN pour réduire l'egress
> - Combiner plusieurs services sur un seul LB
> - Choisir le bon tier (Standard vs Premium)
>
> Premium Network Tier :
> - Routage via le réseau Google
> - Meilleure performance
> - Plus cher que Standard
