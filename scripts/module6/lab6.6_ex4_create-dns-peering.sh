#!/bin/bash
# Lab 6.6 - Exercice 6.6.4 : Créer le peering DNS
# Objectif : Configurer le peering DNS entre Spoke et Hub

set -e

echo "=== Lab 6.6 - Exercice 4 : Créer le peering DNS ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Zone de peering DNS dans le VPC Spoke vers le VPC Hub
echo "Création de la zone de peering DNS..."
gcloud dns managed-zones create peering-to-hub \
    --dns-name="services.internal." \
    --description="Peering DNS vers VPC Hub" \
    --visibility=private \
    --networks=vpc-spoke \
    --target-network=vpc-hub \
    --target-project=$PROJECT_ID
echo ""

echo "Peering DNS créé avec succès !"
echo ""

# Vérifier
echo "=== Détails du peering DNS ==="
gcloud dns managed-zones describe peering-to-hub
echo ""

echo "Important : Le peering DNS est différent du VPC Peering réseau."
echo "Il concerne uniquement la résolution DNS, pas la connectivité réseau."
