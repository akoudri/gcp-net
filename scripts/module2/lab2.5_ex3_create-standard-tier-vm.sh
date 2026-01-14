#!/bin/bash
# Lab 2.5 - Exercice 2.5.3 : Créer une VM avec Standard Tier
# Objectif : Déployer une VM utilisant le Standard Network Tier

set -e

echo "=== Lab 2.5 - Exercice 3 : Créer une VM avec Standard Tier ==="
echo ""

# D'abord, réserver une IP Standard Tier
echo "Réservation d'une IP Standard Tier..."
gcloud compute addresses create ip-standard \
    --region=europe-west1 \
    --network-tier=STANDARD

echo ""

# Récupérer l'IP réservée
export IP_STANDARD=$(gcloud compute addresses describe ip-standard \
    --region=europe-west1 \
    --format="get(address)")

echo "IP Standard réservée : $IP_STANDARD"
echo ""

# VM avec Standard Tier
echo "Création de la VM avec Standard Tier..."
gcloud compute instances create vm-standard \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=tier-test-vpc \
    --subnet=tier-test-subnet \
    --network-tier=STANDARD \
    --address=$IP_STANDARD \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server

echo ""
echo "VM Standard Tier créée avec succès !"
echo "IP Standard : $IP_STANDARD"
echo ""

echo "Sauvegardez cette IP pour les tests de performance."
