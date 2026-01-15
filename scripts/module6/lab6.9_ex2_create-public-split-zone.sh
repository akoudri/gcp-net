#!/bin/bash
# Lab 6.9 - Exercice 6.9.2 : Zone publique (vue Internet)
# Objectif : Créer la zone publique pour le split-horizon

set -e

echo "=== Lab 6.9 - Exercice 2 : Zone publique (vue Internet) ==="
echo ""

export SPLIT_DOMAIN="api-split.example.com"
export ZONE="europe-west1-b"

echo "Domaine : $SPLIT_DOMAIN"
echo ""

# Récupérer l'IP publique
export PUBLIC_IP=$(gcloud compute instances describe vm-api \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

if [ -z "$PUBLIC_IP" ]; then
    echo "⚠️  Impossible de récupérer l'IP publique. Vérifiez que vm-api existe."
    exit 1
fi

echo "IP Publique : $PUBLIC_IP"
echo ""

# Créer/mettre à jour la zone publique
echo "Création de la zone publique pour split-horizon..."
if ! gcloud dns managed-zones describe zone-split-public &>/dev/null; then
    # Utiliser la zone publique existante (zone-public-lab) au lieu de créer une nouvelle
    echo "Note: Utilisation de la zone publique existante 'zone-public-lab'"
    ZONE_NAME="zone-public-lab"
else
    echo "Zone publique zone-split-public existe déjà"
    ZONE_NAME="zone-split-public"
fi
echo ""

# Enregistrement public
echo "Création de l'enregistrement public avec l'IP publique..."
gcloud dns record-sets create "api-split.example.com." \
    --zone=$ZONE_NAME \
    --type=A \
    --ttl=300 \
    --rrdatas="$PUBLIC_IP" 2>/dev/null || \
gcloud dns record-sets update "api-split.example.com." \
    --zone=$ZONE_NAME \
    --type=A \
    --ttl=300 \
    --rrdatas="$PUBLIC_IP"
echo ""

echo "Zone publique configurée avec succès !"
echo ""

# Vérifier
echo "=== Enregistrement public ==="
gcloud dns record-sets list --zone=$ZONE_NAME \
    --filter="name:api-split"
