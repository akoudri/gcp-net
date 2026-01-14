#!/bin/bash
# Lab 5.5 - Exercice 5.5.5 : Créer une VM pour tester PSC
# Objectif : Déployer une VM dans le sous-réseau PSC

set -e

echo "=== Lab 5.5 - Exercice 5 : Créer une VM pour tester PSC ==="
echo ""

export VPC_NAME="vpc-private-access"
export ZONE="europe-west1-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# VM dans le sous-réseau PSC
echo "Création de la VM dans le sous-réseau PSC..."
gcloud compute instances create vm-psc \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-psc \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --scopes=storage-ro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils tcpdump'

echo ""
echo "=== VM PSC créée ! ==="
echo ""
echo "Nom : vm-psc"
echo "IP privée : 10.1.0.10"
echo "Sous-réseau : subnet-psc"
echo "IP externe : Aucune"
echo ""
echo "La VM est prête pour tester l'endpoint PSC."
echo "Attendez 1-2 minutes pour que les outils s'installent."
