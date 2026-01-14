#!/bin/bash
# Lab 5.9 : Scénario intégrateur - Architecture hybride sécurisée
# Objectif : Déployer une architecture complète combinant PGA, PSA et PSC

set -e

echo "=========================================="
echo " Lab 5.9 : Architecture Hybride Sécurisée"
echo "=========================================="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export VPC_HUB="vpc-hub-secure"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_HUB"
echo "Région : $REGION"
echo ""
echo "⚠️  Ce déploiement peut prendre 15-20 minutes."
echo ""
read -p "Continuer ? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Déploiement annulé."
    exit 0
fi

echo ""
echo "=== 1. Création du VPC Hub ==="
gcloud compute networks create $VPC_HUB \
    --subnet-mode=custom \
    --description="VPC Hub avec connectivité privée complète"

echo ""
echo "=== 2. Création des sous-réseaux ==="
# Sous-réseau pour PSC
echo "- subnet-psc (10.0.1.0/24)"
gcloud compute networks subnets create subnet-psc \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access

# Sous-réseau pour les applications
echo "- subnet-app (10.0.2.0/24)"
gcloud compute networks subnets create subnet-app \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access

# Sous-réseau pour les données (utilisé par PSA)
echo "- subnet-data (10.0.3.0/24)"
gcloud compute networks subnets create subnet-data \
    --network=$VPC_HUB \
    --region=$REGION \
    --range=10.0.3.0/24 \
    --enable-private-ip-google-access

echo ""
echo "=== 3. Configuration PSA ==="
# Activer les APIs
echo "Activation des APIs nécessaires..."
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com

# Réserver une plage pour PSA
echo "Réservation de la plage IP pour PSA..."
gcloud compute addresses create psa-range \
    --global \
    --purpose=VPC_PEERING \
    --addresses=10.100.0.0 \
    --prefix-length=20 \
    --network=$VPC_HUB

# Créer la connexion PSA
echo "Création de la connexion PSA..."
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=psa-range \
    --network=$VPC_HUB

echo ""
echo "=== 4. Configuration PSC pour APIs Google ==="
# Réserver IP pour endpoint PSC
echo "Réservation de l'IP pour l'endpoint PSC..."
gcloud compute addresses create psc-apis \
    --region=$REGION \
    --subnet=subnet-psc \
    --addresses=10.0.1.100

# Créer endpoint PSC
echo "Création de l'endpoint PSC pour les APIs Google..."
gcloud compute forwarding-rules create psc-googleapis \
    --region=$REGION \
    --network=$VPC_HUB \
    --address=psc-apis \
    --target-google-apis-bundle=all-apis

echo ""
echo "=== 5. Configuration DNS ==="
# Zone DNS pour googleapis.com
echo "Création de la zone DNS privée..."
gcloud dns managed-zones create googleapis-hub \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_HUB

# Enregistrements DNS vers PSC
echo "Ajout des enregistrements DNS..."
for API in storage www bigquery pubsub; do
    echo "  - ${API}.googleapis.com → 10.0.1.100"
    gcloud dns record-sets create "${API}.googleapis.com." \
        --zone=googleapis-hub \
        --type=A \
        --ttl=300 \
        --rrdatas="10.0.1.100"
done

echo ""
echo "=== 6. Règles de pare-feu sécurisées ==="
# Bloquer tout trafic sortant par défaut
echo "Configuration d'une politique de pare-feu restrictive..."
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

echo ""
echo "=== 7. Déploiement des VMs ==="
# VM applicative
echo "Création de la VM applicative..."
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

echo ""
echo "=== 8. (Optionnel) Cloud SQL avec PSA ==="
echo "Création de Cloud SQL (cela prend 5-10 minutes)..."
gcloud sql instances create sql-secure \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=$REGION \
    --network=$VPC_HUB \
    --no-assign-ip

echo ""
echo "=========================================="
echo " Déploiement terminé !"
echo "=========================================="
echo ""
echo "Architecture déployée :"
echo "- VPC: $VPC_HUB"
echo "- PSC Endpoint: 10.0.1.100 (APIs Google)"
echo "- PSA Range: 10.100.0.0/20 (Services managés)"
echo "- Egress: Restreint aux services autorisés uniquement"
echo ""
echo "Sous-réseaux :"
echo "- subnet-psc: 10.0.1.0/24 (PSC endpoint)"
echo "- subnet-app: 10.0.2.0/24 (Applications)"
echo "- subnet-data: 10.0.3.0/24 (Données)"
echo ""
echo "Ressources :"
echo "- app-vm: VM applicative dans subnet-app"
echo "- sql-secure: Instance Cloud SQL avec IP privée"
echo ""
echo "Tests de validation :"
echo "Pour tester l'architecture, exécutez :"
echo "./lab5.9_test-hybrid-architecture.sh"
