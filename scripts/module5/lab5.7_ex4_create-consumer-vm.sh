#!/bin/bash
# Lab 5.7 - Exercice 5.7.4 : Créer une VM consommateur et tester
# Objectif : Déployer une VM pour consommer le service

set -e

echo "=== Lab 5.7 - Exercice 4 : Créer une VM consommateur ==="
echo ""

export VPC_CONSUMER="vpc-consumer"
export ZONE="europe-west1-b"

echo "VPC : $VPC_CONSUMER"
echo "Zone : $ZONE"
echo ""

# VM consommateur
echo "Création de la VM consommateur..."
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

echo ""
echo "=== VM consommateur créée ! ==="
echo ""
echo "Nom : consumer-vm"
echo "IP privée : 10.60.0.10"
echo "Sous-réseau : subnet-consumer"
echo ""
echo "La VM est prête pour consommer le service via PSC."
