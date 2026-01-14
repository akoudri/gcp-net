#!/bin/bash
# Lab 6.4 - Exercice 6.4.5 : Créer la zone de forwarding
# Objectif : Configurer le forwarding DNS vers le serveur on-premise

set -e

echo "=== Lab 6.4 - Exercice 5 : Créer la zone de forwarding ==="
echo ""

export VPC_NAME="vpc-dns-lab"

echo "VPC : $VPC_NAME"
echo ""

# Créer la zone de forwarding vers le serveur DNS "on-premise"
echo "Création de la zone de forwarding..."
gcloud dns managed-zones create zone-forward-corp \
    --dns-name="corp.local." \
    --description="Forwarding vers DNS on-premise simulé" \
    --visibility=private \
    --networks=$VPC_NAME \
    --forwarding-targets="10.0.1.53"
echo ""

echo "Zone de forwarding créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la zone de forwarding ==="
gcloud dns managed-zones describe zone-forward-corp
