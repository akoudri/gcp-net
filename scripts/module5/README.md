# Module 5 - Options de Connexion Privée

Scripts bash pour les travaux pratiques du Module 5 (Private Connectivity).

## Vue d'ensemble

Ce module couvre trois solutions de connectivité privée dans Google Cloud :
- **Private Google Access (PGA)** : Accès aux APIs Google sans IP externe
- **Private Services Access (PSA)** : Services managés (Cloud SQL, Redis) avec IP privée
- **Private Service Connect (PSC)** : Connectivité avancée producteur/consommateur

## Structure des Labs

### Lab 5.1 - Private Google Access (6 exercices)
Configuration et test de PGA pour accéder aux APIs Google sans IP externe.

```bash
./lab5.1_ex1_create-infrastructure.sh    # Créer le VPC et infrastructure
./lab5.1_ex2_create-vm.sh                # Créer VM sans IP externe
./lab5.1_ex3_test-before-pga.sh          # Tester AVANT PGA
./lab5.1_ex4_enable-pga.sh               # Activer PGA
./lab5.1_ex5_test-after-pga.sh           # Tester APRÈS PGA
./lab5.1_ex6_view-routes.sh              # Observer les routes
```

### Lab 5.2 - Configuration DNS avancée PGA (6 exercices)
Configuration DNS pour forcer l'utilisation de PGA avec private.googleapis.com.

```bash
./lab5.2_ex1_verify-dns.sh               # Vérifier résolution DNS par défaut
./lab5.2_ex2_create-dns-zone.sh          # Créer zone DNS privée
./lab5.2_ex3_add-dns-records.sh          # Ajouter enregistrements DNS
./lab5.2_ex4_test-new-dns.sh             # Tester nouvelle résolution
./lab5.2_ex5_understand-restricted.sh    # Comprendre restricted.googleapis.com
./lab5.2_ex6_configure-restricted.sh     # Config restricted (optionnel)
```

### Lab 5.3 - Private Services Access - Cloud SQL (8 exercices)
Déploiement de Cloud SQL avec PSA et IP privée uniquement.

```bash
./lab5.3_ex1_enable-service-networking.sh # Activer API Service Networking
./lab5.3_ex2_reserve-ip-range.sh          # Réserver plage IP pour PSA
./lab5.3_ex3_create-psa-connection.sh     # Créer connexion PSA
./lab5.3_ex4_create-cloud-sql.sh          # Créer Cloud SQL
./lab5.3_ex5_configure-sql-user.sh        # Configurer utilisateur/DB
./lab5.3_ex6_configure-cloud-nat.sh       # Configurer Cloud NAT
./lab5.3_ex7_create-client-vm.sh          # Créer VM cliente
./lab5.3_ex8_test-sql-connection.sh       # Tester connexion SQL
```

### Lab 5.4 - PSA - Memorystore Redis (4 exercices)
Déploiement de Redis avec PSA (partage la même connexion que Cloud SQL).

```bash
./lab5.4_ex1_enable-redis-api.sh          # Activer API Redis
./lab5.4_ex2_create-redis.sh              # Créer instance Redis
./lab5.4_ex3_test-redis.sh                # Tester connexion Redis
./lab5.4_ex4_view-psa-resources.sh        # Observer ressources PSA
```

### Lab 5.5 - Private Service Connect - APIs Google (7 exercices)
Configuration PSC pour accéder aux APIs Google avec une IP dans votre VPC.

```bash
./lab5.5_ex1_create-psc-subnet.sh         # Créer sous-réseau PSC
./lab5.5_ex2_reserve-psc-ip.sh            # Réserver IP endpoint
./lab5.5_ex3_create-psc-endpoint.sh       # Créer endpoint PSC
./lab5.5_ex4_configure-psc-dns.sh         # Configurer DNS pour PSC
./lab5.5_ex5_create-psc-vm.sh             # Créer VM de test
./lab5.5_ex6_test-psc-endpoint.sh         # Tester endpoint PSC
./lab5.5_ex7_compare-psc-pga.sh           # Comparer PSC vs PGA
```

### Lab 5.6 - PSC Producteur (4 exercices)
Publier un service via Private Service Connect (côté producteur).

```bash
./lab5.6_ex1_create-producer-vpc.sh       # Créer VPC producteur
./lab5.6_ex2_deploy-backend.sh            # Déployer backend (nginx)
./lab5.6_ex3_create-internal-lb.sh        # Créer Internal LB
./lab5.6_ex4_create-service-attachment.sh # Créer Service Attachment
```

### Lab 5.7 - PSC Consommateur (6 exercices)
Consommer un service PSC depuis un VPC différent.

```bash
./lab5.7_ex1_create-consumer-vpc.sh       # Créer VPC consommateur
./lab5.7_ex2_reserve-consumer-ip.sh       # Réserver IP endpoint
./lab5.7_ex3_create-consumer-endpoint.sh  # Créer endpoint consommateur
./lab5.7_ex4_create-consumer-vm.sh        # Créer VM consommateur
./lab5.7_ex5_test-psc-connectivity.sh     # Tester connectivité PSC
./lab5.7_ex6_configure-dns-optional.sh    # Configurer DNS (optionnel)
```

### Lab 5.9 - Architecture Hybride Sécurisée (2 scripts)
Déploiement complet combinant PGA, PSA et PSC.

```bash
./lab5.9_deploy-hybrid-architecture.sh    # Déployer l'architecture complète
./lab5.9_test-hybrid-architecture.sh      # Tester l'architecture
```

### Cleanup
```bash
./cleanup-module5.sh                      # Nettoyer toutes les ressources
```

## Usage

### Exécution séquentielle (recommandée)
Les exercices doivent être exécutés dans l'ordre pour chaque lab :

```bash
cd /home/ali/Training/gcp-net/scripts/module5

# Lab 5.1 complet
./lab5.1_ex1_create-infrastructure.sh
./lab5.1_ex2_create-vm.sh
./lab5.1_ex3_test-before-pga.sh
./lab5.1_ex4_enable-pga.sh
./lab5.1_ex5_test-after-pga.sh
./lab5.1_ex6_view-routes.sh

# Lab 5.2 complet (nécessite Lab 5.1)
./lab5.2_ex1_verify-dns.sh
# ... etc
```

### Déploiement rapide
Pour tester rapidement l'architecture complète :

```bash
./lab5.9_deploy-hybrid-architecture.sh
./lab5.9_test-hybrid-architecture.sh
```

### Nettoyage
Après avoir terminé tous les labs :

```bash
./cleanup-module5.sh
```

**⚠️ ATTENTION** : Le script de nettoyage supprime TOUTES les ressources créées dans les labs du Module 5.

## Prérequis

- Projet GCP avec facturation activée
- APIs activées : Compute Engine, Cloud DNS, Service Networking
- Droits IAM nécessaires :
  - `roles/compute.networkAdmin`
  - `roles/dns.admin`
  - `roles/servicenetworking.networksAdmin`
  - `roles/cloudsql.admin`
  - `roles/redis.admin`

## Ressources créées

### VPCs et Sous-réseaux
- `vpc-private-access` : VPC principal pour PGA et PSA
  - `subnet-pga` (10.0.0.0/24)
  - `subnet-app` (10.0.1.0/24)
  - `subnet-psc` (10.1.0.0/24)
- `vpc-producer` : VPC producteur PSC
  - `subnet-producer` (10.50.0.0/24)
  - `subnet-psc-nat` (10.50.1.0/24)
- `vpc-consumer` : VPC consommateur PSC
  - `subnet-consumer` (10.60.0.0/24)
- `vpc-hub-secure` : Architecture hybride complète
  - `subnet-psc` (10.0.1.0/24)
  - `subnet-app` (10.0.2.0/24)
  - `subnet-data` (10.0.3.0/24)

### Services managés
- Cloud SQL PostgreSQL (IP privée via PSA)
- Memorystore Redis (IP privée via PSA)
- Plage PSA réservée : 10.100.0.0/20-24

### Connectivité
- Private Google Access (PGA) activé sur sous-réseaux
- Private Services Access (PSA) avec VPC Peering
- Private Service Connect (PSC) avec endpoints
- Zones DNS privées pour googleapis.com

### VMs
- `vm-pga` : Test PGA
- `vm-psc` : Test PSC
- `vm-sql-client` : Client pour Cloud SQL/Redis
- `backend-vm` : Backend producteur PSC
- `consumer-vm` : Consommateur PSC
- `app-vm` : VM applicative architecture hybride

## Concepts clés

### Private Google Access (PGA)
- Permet aux VMs sans IP externe d'accéder aux APIs Google
- Utilise les IPs VIP privées : 199.36.153.8/30
- Configuration par sous-réseau
- Gratuit et simple

### Private Services Access (PSA)
- Pour Cloud SQL, Memorystore, etc.
- Nécessite une plage IP réservée (VPC_PEERING)
- VPC Peering automatique avec Google
- Partage la connexion entre plusieurs services

### Private Service Connect (PSC)
- Endpoint dans VOTRE espace d'adressage
- Producteur/Consommateur model
- Isolation complète (pas de VPC Peering)
- Routable depuis on-premise
- Utilisé pour APIs Google et services tiers

## Comparaison

| Critère | PGA | PSA | PSC |
|---------|-----|-----|-----|
| Cible | APIs Google | Services managés | APIs + Services tiers |
| IP | 199.36.153.x | Plage PSA | Votre VPC |
| Config | Par subnet | Par VPC | Par endpoint |
| On-prem | Via routes | Export routes | Natif |
| Complexité | Simple | Moyenne | Avancée |
| Coût | Gratuit | Selon service | Faible |

## Temps estimé

- Lab 5.1 : 15 minutes
- Lab 5.2 : 10 minutes
- Lab 5.3 : 20 minutes (dont 10 min pour Cloud SQL)
- Lab 5.4 : 15 minutes (dont 10 min pour Redis)
- Lab 5.5 : 15 minutes
- Lab 5.6 : 20 minutes
- Lab 5.7 : 15 minutes
- Lab 5.9 : 25 minutes (dont 15 min pour Cloud SQL)

**Total : ~2h15**

## Troubleshooting

### Cloud SQL prend trop de temps
Cloud SQL peut prendre 5-10 minutes à créer. C'est normal.

### DNS ne se propage pas
Attendez 2-3 minutes après la création des enregistrements DNS.

### Connexion PSA échoue
Vérifiez que :
- L'API Service Networking est activée
- La plage PSA ne chevauche pas vos sous-réseaux
- Le VPC Peering est établi (`gcloud compute networks peerings list`)

### PSC endpoint ne fonctionne pas
Vérifiez que :
- L'adresse IP est réservée
- La forwarding rule est créée
- Le DNS pointe vers l'endpoint

## Support

Pour plus d'informations, consultez :
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
- [Private Services Access](https://cloud.google.com/vpc/docs/private-services-access)
- [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect)

## Auteur

Scripts générés pour le programme de formation GCP Networking.
