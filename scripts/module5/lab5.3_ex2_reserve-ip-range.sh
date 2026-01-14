#!/bin/bash
# Lab 5.3 - Exercice 5.3.2 : Réserver une plage d'adresses pour les services Google
# Objectif : Réserver une plage IP pour PSA

set -e

echo "=== Lab 5.3 - Exercice 2 : Réserver une plage IP pour PSA ==="
echo ""

export VPC_NAME="vpc-private-access"

echo "VPC : $VPC_NAME"
echo ""

# Réserver une plage IP pour les services managés Google
echo "Réservation d'une plage IP pour les services managés Google..."
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --addresses=10.100.0.0 \
    --prefix-length=24 \
    --network=$VPC_NAME \
    --description="Plage réservée pour les services managés Google"

echo ""
echo "Plage IP réservée avec succès !"
echo ""

# Vérifier la réservation
echo "=== Adresses réservées pour VPC Peering ==="
gcloud compute addresses list --global --filter="purpose=VPC_PEERING" --format="table(name,address,prefixLength,purpose)"

echo ""

# Voir les détails
echo "=== Détails de la réservation ==="
gcloud compute addresses describe google-managed-services --global

echo ""
echo "=== Questions à considérer ==="
echo ""
echo "1. Pourquoi réserver une plage /24 et non une seule IP ?"
echo "   → Les services managés (Cloud SQL, Redis) ont besoin de plusieurs IPs"
echo "     pour la haute disponibilité et les réplicas."
echo ""
echo "2. Cette plage peut-elle chevaucher vos sous-réseaux existants ?"
echo "   → Non ! La plage PSA ne doit PAS chevaucher les sous-réseaux"
echo "     existants dans votre VPC."
