#!/bin/bash
# Lab 2.5 - Exercice 2.5.2 : Créer une VM avec Premium Tier
# Objectif : Déployer une VM utilisant le Premium Network Tier

set -e

echo "=== Lab 2.5 - Exercice 2 : Créer une VM avec Premium Tier ==="
echo ""

# VM avec Premium Tier (défaut)
echo "Création de la VM avec Premium Tier..."
gcloud compute instances create vm-premium \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=tier-test-vpc \
    --subnet=tier-test-subnet \
    --network-tier=PREMIUM \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server

echo ""

# Récupérer l'IP externe
export IP_PREMIUM=$(gcloud compute instances describe vm-premium \
    --zone=europe-west1-b \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

echo "VM Premium Tier créée avec succès !"
echo "IP Premium : $IP_PREMIUM"
echo ""

echo "Sauvegardez cette IP pour les tests de performance."
