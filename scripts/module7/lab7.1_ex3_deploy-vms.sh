#!/bin/bash
# Lab 7.1 - Exercice 7.1.3 : Déployer les VMs de test
# Objectif : Créer des VMs dans chaque VPC pour tester la connectivité

set -e

echo "=== Lab 7.1 - Exercice 3 : Déployer les VMs de test ==="
echo ""

export ZONE="europe-west1-b"

echo "Zone : $ZONE"
echo ""

# VM dans le VPC GCP
echo ">>> Création de vm-gcp..."
gcloud compute instances create vm-gcp \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-gcp \
    --subnet=subnet-gcp \
    --private-network-ip=10.0.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils traceroute mtr'

echo ""

# VM dans le VPC On-premise
echo ">>> Création de vm-onprem..."
gcloud compute instances create vm-onprem \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-onprem \
    --subnet=subnet-onprem \
    --private-network-ip=192.168.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils traceroute mtr'

echo ""
echo "=== VMs créées avec succès ==="
echo ""
echo "VMs déployées :"
gcloud compute instances list --filter="name:(vm-gcp OR vm-onprem)"
