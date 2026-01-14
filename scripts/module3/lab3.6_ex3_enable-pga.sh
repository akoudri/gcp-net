#!/bin/bash
# Lab 3.6 - Exercice 3.6.3 : Activer Private Google Access
# Objectif : Activer PGA sur le sous-réseau

set -e

echo "=== Lab 3.6 - Exercice 3 : Activer Private Google Access ==="
echo ""

# Variables
export REGION_EU="europe-west1"

echo "Région : $REGION_EU"
echo ""

# Activer PGA sur le sous-réseau
echo "Activation de Private Google Access sur subnet-isolated..."
gcloud compute networks subnets update subnet-isolated \
    --region=$REGION_EU \
    --enable-private-google-access

echo ""
echo "Private Google Access activé avec succès !"
echo ""

# Vérifier l'activation
echo "=== Vérification PGA ==="
PGA_STATUS=$(gcloud compute networks subnets describe subnet-isolated \
    --region=$REGION_EU \
    --format="get(privateIpGoogleAccess)")

echo "Private Google Access : $PGA_STATUS"
echo ""

if [ "$PGA_STATUS" = "True" ]; then
    echo "Private Google Access est bien activé."
else
    echo "Erreur : Private Google Access n'est pas activé."
fi
echo ""
