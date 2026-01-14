# Module 10 - Load Balancing Scripts

Scripts bash pour les travaux pratiques du Module 10 sur l'équilibrage de charge GCP.

## Structure des Labs

### Lab 10.2 : Global External Application LB - Configuration complète
- `lab10.2_ex1_create-base-infrastructure.sh` - Créer le VPC et les règles de pare-feu
- `lab10.2_ex2_create-instance-templates-groups.sh` - Créer les templates et instance groups
- `lab10.2_ex3_create-health-checks.sh` - Créer les health checks
- `lab10.2_ex4_create-backend-services.sh` - Créer les backend services
- `lab10.2_ex5_create-backend-bucket.sh` - Créer le bucket pour contenu statique
- `lab10.2_ex6_create-url-map.sh` - Créer l'URL Map avec routage
- `lab10.2_ex7_create-frontend-http.sh` - Créer le frontend HTTP
- `lab10.2_ex8_test-load-balancer.sh` - Tester le Load Balancer

### Lab 10.3 : URL Maps et routage avancé
- `lab10.3_ex1_routing-by-host.sh` - Routage par hostname
- `lab10.3_ex2_routing-by-path-advanced.sh` - Routage par path avec plusieurs règles
- `lab10.3_ex3_advanced-yaml-config.sh` - Configuration YAML avancée

### Lab 10.4 : Gestion du trafic - Canary et Blue-Green
- `lab10.4_ex1_create-backends-v1-v2.sh` - Créer deux versions de backends
- `lab10.4_ex2_configure-canary-traffic-splitting.sh` - Configurer le traffic splitting 90/10
- `lab10.4_ex3_test-traffic-splitting.sh` - Tester la distribution du trafic
- `lab10.4_ex4_progressive-canary-rollout.sh` - Rollout progressif du canary
- `lab10.4_ex5_blue-green-deployment.sh` - Déploiement Blue-Green
- `lab10.4_ex6_header-based-routing.sh` - Routage basé sur les headers HTTP

### Lab 10.5 : Session Affinity et persistance
- `lab10.5_ex2_configure-cookie-affinity.sh` - Configurer l'affinité par cookie
- `lab10.5_ex3_test-session-affinity.sh` - Tester l'affinité de session
- `lab10.5_ex4_header-affinity-api.sh` - Affinité par header pour APIs

### Lab 10.6 : Internal Application Load Balancer
- `lab10.6_ex1_create-ilb-subnet.sh` - Créer les sous-réseaux pour l'ILB
- `lab10.6_ex2_configure-cloud-nat.sh` - Configurer Cloud NAT
- `lab10.6_ex3_create-internal-backends.sh` - Créer les backends internes
- `lab10.6_ex4_create-internal-alb.sh` - Créer l'Internal Application LB
- `lab10.6_ex5_test-internal-lb.sh` - Tester l'Internal LB

### Lab 10.7 : Network Load Balancer (L4)
- `lab10.7_ex1_create-internal-nlb.sh` - Créer un Internal Passthrough Network LB

### Lab 10.8 : Équilibrage hybride avec Hybrid NEG
- `lab10.8_ex2_create-hybrid-neg.sh` - Créer un Hybrid NEG
- `lab10.8_ex3_create-hybrid-backend.sh` - Créer le backend service hybride
- `lab10.8_ex4_configure-hybrid-failover.sh` - Configurer le failover GCP/On-premise

### Lab 10.9 : Network Endpoint Groups (NEGs)
- `lab10.9_ex2_create-serverless-neg.sh` - Créer un Serverless NEG (Cloud Run)
- `lab10.9_ex3_create-internet-neg.sh` - Créer un Internet NEG

### Lab 10.10 : Cloud CDN - Configuration et optimisation
- `lab10.10_ex1_enable-cloud-cdn.sh` - Activer Cloud CDN
- `lab10.10_ex2_configure-cache-modes.sh` - Configurer les modes de cache
- `lab10.10_ex3_configure-cache-keys.sh` - Configurer les cache keys
- `lab10.10_ex4_test-cdn-cache.sh` - Tester le cache CDN
- `lab10.10_ex5_invalidate-cache.sh` - Invalider le cache

### Lab 10.11 : Cloud CDN - Signed URLs et contenu protégé
- `lab10.11_ex2_create-signing-key.sh` - Créer une clé de signature
- `lab10.11_ex3_create-signed-url-script.sh` - Script Python pour générer des signed URLs
- `lab10.11_ex4_test-signed-urls.sh` - Tester les signed URLs
- `lab10.11_ex5_rotate-signing-keys.sh` - Rotation des clés

### Lab 10.12 : Scénario intégrateur - Architecture multi-tier
- `lab10.12_deploy-multitier-architecture.sh` - Récapitulatif de l'architecture complète

## Nettoyage

- `cleanup-module10.sh` - Supprime toutes les ressources créées dans le Module 10

## Ordre d'exécution recommandé

Pour déployer une architecture complète de Load Balancing :

1. **Infrastructure de base (Lab 10.2)**
   ```bash
   ./lab10.2_ex1_create-base-infrastructure.sh
   ./lab10.2_ex2_create-instance-templates-groups.sh
   ./lab10.2_ex3_create-health-checks.sh
   ./lab10.2_ex4_create-backend-services.sh
   ./lab10.2_ex5_create-backend-bucket.sh
   ./lab10.2_ex6_create-url-map.sh
   ./lab10.2_ex7_create-frontend-http.sh
   ./lab10.2_ex8_test-load-balancer.sh
   ```

2. **Routage avancé (Lab 10.3)** - Optionnel
   ```bash
   ./lab10.3_ex1_routing-by-host.sh
   ./lab10.3_ex2_routing-by-path-advanced.sh
   ```

3. **Déploiement Canary (Lab 10.4)** - Optionnel
   ```bash
   ./lab10.4_ex1_create-backends-v1-v2.sh
   ./lab10.4_ex2_configure-canary-traffic-splitting.sh
   ./lab10.4_ex3_test-traffic-splitting.sh
   ```

4. **Session Affinity (Lab 10.5)** - Optionnel
   ```bash
   ./lab10.5_ex2_configure-cookie-affinity.sh
   ./lab10.5_ex3_test-session-affinity.sh
   ```

5. **Internal Load Balancer (Lab 10.6)**
   ```bash
   ./lab10.6_ex1_create-ilb-subnet.sh
   ./lab10.6_ex2_configure-cloud-nat.sh
   ./lab10.6_ex3_create-internal-backends.sh
   ./lab10.6_ex4_create-internal-alb.sh
   ./lab10.6_ex5_test-internal-lb.sh
   ```

6. **Cloud CDN (Lab 10.10)**
   ```bash
   ./lab10.10_ex1_enable-cloud-cdn.sh
   ./lab10.10_ex4_test-cdn-cache.sh
   ```

7. **Vérification finale**
   ```bash
   ./lab10.12_deploy-multitier-architecture.sh
   ```

8. **Nettoyage**
   ```bash
   ./cleanup-module10.sh
   ```

## Variables d'environnement

Les scripts utilisent les variables suivantes :
- `PROJECT_ID` - Automatiquement récupéré via gcloud config
- `REGION` - Par défaut : `europe-west1`
- `ZONE` - Par défaut : `europe-west1-b`

## Prérequis

- gcloud CLI configuré avec un projet GCP
- Droits nécessaires :
  - `roles/compute.loadBalancerAdmin`
  - `roles/compute.networkAdmin`
  - `roles/storage.admin` (pour Cloud Storage)
  - `roles/run.admin` (pour Cloud Run, Lab 10.9)
- APIs activées :
  - Compute Engine API
  - Cloud Run API (pour Lab 10.9)

## Notes importantes

- Attendez que les instances démarrent complètement avant de tester (2-3 minutes)
- Les Load Balancers peuvent prendre 5-10 minutes pour être opérationnels
- Cloud CDN peut prendre plusieurs minutes pour propager le cache globalement
- Les signed URLs nécessitent Python 3

## Coûts estimés

Les ressources créées génèrent des coûts :
- Load Balancers : ~$18-25/mois par LB
- VMs e2-small : ~$12-15/mois par instance
- Cloud CDN : Variable selon l'utilisation
- Cloud Storage : Variable selon le stockage et le trafic

Pensez à exécuter le script de nettoyage après les labs !

## Support

Pour toute question, consultez :
- [Documentation GCP Load Balancing](https://cloud.google.com/load-balancing/docs)
- [Documentation Cloud CDN](https://cloud.google.com/cdn/docs)
- Le fichier `module10_labs.md` pour les explications détaillées
