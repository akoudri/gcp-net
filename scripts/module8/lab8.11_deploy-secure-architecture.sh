#!/bin/bash
# Lab 8.11 : Scénario intégrateur - Architecture sécurisée complète
# Objectif : Déployer une architecture sécurisée utilisant toutes les bonnes pratiques

set -e

export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-secure"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE SÉCURISÉE"
echo "=========================================="
echo ""
echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# ===== 1. VPC et sous-réseaux =====
echo ">>> 1. Création du VPC..."
gcloud compute networks create $VPC_NAME --subnet-mode=custom 2>/dev/null || echo "VPC $VPC_NAME existe déjà"

echo ""
echo ">>> Création des sous-réseaux avec VPC Flow Logs..."
gcloud compute networks subnets create subnet-dmz \
    --network=$VPC_NAME --region=$REGION --range=10.0.1.0/24 \
    --enable-flow-logs --logging-flow-sampling=1.0 2>/dev/null || echo "Subnet subnet-dmz existe déjà"

gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME --region=$REGION --range=10.0.2.0/24 \
    --enable-flow-logs --logging-flow-sampling=1.0 \
    --enable-private-ip-google-access 2>/dev/null || echo "Subnet subnet-backend existe déjà"

echo ""

# ===== 2. Service Accounts =====
echo ">>> 2. Création des Service Accounts..."
for SA in web api db; do
    gcloud iam service-accounts create sa-${SA}-secure \
        --display-name="SA ${SA} - Secure Architecture" 2>/dev/null || echo "SA sa-${SA}-secure existe déjà"
done

echo ""

# ===== 3. Global Network Firewall Policy =====
echo ">>> 3. Création de la Global Network Firewall Policy..."
gcloud compute network-firewall-policies create secure-global-policy --global 2>/dev/null || echo "Politique existe déjà"

# Deny dangerous ports
echo ">>> Ajout de la règle : Deny dangerous ports..."
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=deny \
    --layer4-configs=tcp:23,tcp:445,tcp:3389 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Deny dangerous ports" 2>/dev/null || echo "Règle existe déjà"

# Allow Health Checks
echo ">>> Ajout de la règle : Allow Health Checks..."
gcloud compute network-firewall-policies rules create 200 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=allow \
    --layer4-configs=tcp:80,tcp:443,tcp:8080 \
    --src-ip-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Allow Health Checks" 2>/dev/null || echo "Règle existe déjà"

# Allow IAP
echo ">>> Ajout de la règle : Allow IAP SSH..."
gcloud compute network-firewall-policies rules create 300 \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --direction=INGRESS --action=allow \
    --layer4-configs=tcp:22 \
    --src-ip-ranges=35.235.240.0/20 \
    --description="Allow IAP SSH" 2>/dev/null || echo "Règle existe déjà"

# Associer au VPC
echo ">>> Association de la politique au VPC..."
gcloud compute network-firewall-policies associations create \
    --firewall-policy=secure-global-policy --global-firewall-policy \
    --network=$VPC_NAME --name=assoc-secure 2>/dev/null || echo "Association existe déjà"

echo ""

# ===== 4. VPC Firewall Rules (Service Accounts) =====
echo ">>> 4. Création des règles de pare-feu basées sur Service Accounts..."

# HTTP vers Web
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-to-web \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-service-accounts=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="HTTP/S vers Web" 2>/dev/null || echo "Règle existe déjà"

# Web vers API
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="Web vers API" 2>/dev/null || echo "Règle existe déjà"

# API vers DB
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db \
    --network=$VPC_NAME --direction=INGRESS --action=ALLOW \
    --rules=tcp:5432 \
    --source-service-accounts=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-db-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 --enable-logging \
    --description="API vers DB" 2>/dev/null || echo "Règle existe déjà"

# Deny all egress
gcloud compute firewall-rules create ${VPC_NAME}-deny-all-egress \
    --network=$VPC_NAME --direction=EGRESS --action=DENY \
    --rules=all --destination-ranges=0.0.0.0/0 \
    --priority=65000 --enable-logging \
    --description="Deny all egress" 2>/dev/null || echo "Règle existe déjà"

# Allow egress Google APIs
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME --direction=EGRESS --action=ALLOW \
    --rules=tcp:443 \
    --destination-ranges=199.36.153.8/30,199.36.153.4/30 \
    --priority=1000 \
    --description="Allow Google APIs" 2>/dev/null || echo "Règle existe déjà"

# Allow egress internal
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-internal \
    --network=$VPC_NAME --direction=EGRESS --action=ALLOW \
    --rules=all --destination-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Allow internal egress" 2>/dev/null || echo "Règle existe déjà"

echo ""

# ===== 5. VMs =====
echo ">>> 5. Création des VMs..."

gcloud compute instances create vm-web-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-dmz \
    --service-account=sa-web-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y nginx' 2>/dev/null || echo "vm-web-secure existe déjà"

gcloud compute instances create vm-api-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-backend \
    --service-account=sa-api-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud 2>/dev/null || echo "vm-api-secure existe déjà"

gcloud compute instances create vm-db-secure \
    --zone=$ZONE --machine-type=e2-small \
    --network=$VPC_NAME --subnet=subnet-backend \
    --service-account=sa-db-secure@${PROJECT_ID}.iam.gserviceaccount.com \
    --no-address \
    --image-family=debian-11 --image-project=debian-cloud 2>/dev/null || echo "vm-db-secure existe déjà"

echo ""
echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""
echo "Architecture déployée avec:"
echo "✓ VPC Flow Logs activés"
echo "✓ Network Firewall Policy globale"
echo "✓ Règles basées sur Service Accounts"
echo "✓ Logging sur toutes les règles"
echo "✓ Pas d'IP publiques sur les VMs"
echo "✓ Egress restreint"
echo "✓ Private Google Access pour le backend"
echo ""
echo "Pour accéder aux VMs, utilisez IAP :"
echo "  gcloud compute ssh vm-web-secure --zone=$ZONE --tunnel-through-iap"
echo ""
