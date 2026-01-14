#!/bin/bash
# Lab 8.3 - Exercice 8.3.4 : Créer de nouvelles VMs avec Service Accounts
# Objectif : Déployer des VMs utilisant des Service Accounts pour l'identité

set -e

echo "=== Lab 8.3 - Exercice 4 : Créer VMs avec Service Accounts ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# Supprimer les anciennes VMs
echo ">>> Suppression des anciennes VMs..."
for VM in vm-web vm-api vm-db; do
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""
echo "Anciennes VMs supprimées."
echo ""

# Créer vm-web-sa
echo ">>> Création de vm-web-sa avec Service Account..."
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

echo ""

# Créer vm-api-sa
echo ">>> Création de vm-api-sa avec Service Account..."
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

echo ""

# Créer vm-db-sa
echo ">>> Création de vm-db-sa avec Service Account..."
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

echo ""
echo "VMs créées avec succès !"
echo ""

# Lister les VMs
echo "=== VMs créées avec Service Accounts ==="
gcloud compute instances list --filter="name~'-sa$'" \
    --format="table(name,zone,machineType,networkInterfaces[0].networkIP,serviceAccounts[0].email)"

echo ""
echo "Questions à considérer :"
echo "1. Comment vérifier quel Service Account est associé à une VM ?"
echo "2. Peut-on changer le Service Account d'une VM existante ?"
echo "3. Quelles sont les implications de --scopes=cloud-platform ?"
