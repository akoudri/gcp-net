#!/bin/bash
# Lab 11.6 - Exercice 11.6.4 : Créer la politique de Packet Mirroring
# Objectif : Configurer le mirroring des packets

set -e

echo "=== Lab 11.6 - Exercice 4 : Créer la politique de Packet Mirroring ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Créer la politique de mirroring
echo "Création de la politique de packet mirroring..."
gcloud compute packet-mirrorings create mirror-policy-prod \
    --region=$REGION \
    --network=vpc-observability \
    --collector-ilb=collector-ilb \
    --mirrored-subnets=subnet-monitored \
    --filter-cidr-ranges=0.0.0.0/0 \
    --filter-protocols=tcp,udp,icmp \
    --filter-direction=BOTH

echo ""
echo "Politique de mirroring créée avec succès !"
echo ""

# Vérifier la politique
echo "=== Détails de la politique ==="
gcloud compute packet-mirrorings describe mirror-policy-prod \
    --region=$REGION

echo ""
echo "=================================="
echo ""

# Lister les politiques
echo "=== Toutes les politiques de mirroring ==="
gcloud compute packet-mirrorings list --region=$REGION

echo ""
echo "Le packet mirroring est maintenant actif."
echo "Tous les packets du sous-réseau 'subnet-monitored' seront copiés vers le collecteur."
