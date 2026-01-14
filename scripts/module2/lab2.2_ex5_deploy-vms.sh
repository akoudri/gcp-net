#!/bin/bash
# Lab 2.2 - Exercice 2.2.5 : Déployer les VMs dans chaque région
# Objectif : Créer des VMs de test dans les deux régions

set -e

echo "=== Lab 2.2 - Exercice 5 : Déployer les VMs ==="
echo ""

# Variables
export VPC_NAME="production-vpc"

# VM en Europe
echo "Création de la VM en Europe..."
gcloud compute instances create vm-eu \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --no-address \
    --tags=allow-ssh \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y traceroute mtr dnsutils'

echo ""

# VM aux US
echo "Création de la VM aux US..."
gcloud compute instances create vm-us \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --no-address \
    --tags=allow-ssh \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y traceroute mtr dnsutils'

echo ""
echo "VMs déployées avec succès !"
echo ""

# Récupérer les IPs internes
echo "=== Liste des VMs ==="
gcloud compute instances list --filter="network=$VPC_NAME" \
    --format="table(name,zone,networkInterfaces[0].networkIP)"
echo ""

echo "Attendez quelques minutes pour que le startup-script s'exécute."
echo "Ensuite, utilisez les scripts de test pour vérifier la connectivité."
