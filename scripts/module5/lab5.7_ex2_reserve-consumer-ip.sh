#!/bin/bash
# Lab 5.7 - Exercice 5.7.2 : Réserver une IP pour l'endpoint PSC
# Objectif : Réserver une IP pour l'endpoint consommateur

set -e

echo "=== Lab 5.7 - Exercice 2 : Réserver une IP pour l'endpoint ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Réserver une IP pour l'endpoint
echo "Réservation d'une IP pour l'endpoint PSC consommateur..."
gcloud compute addresses create psc-consumer-endpoint \
    --region=$REGION \
    --subnet=subnet-consumer \
    --addresses=10.60.0.100

echo ""
echo "IP réservée avec succès !"
echo ""

# Vérifier
echo "=== Détails de l'adresse réservée ==="
gcloud compute addresses describe psc-consumer-endpoint --region=$REGION

echo ""
echo "=== IP réservée ! ==="
echo ""
echo "Adresse : 10.60.0.100"
echo "Sous-réseau : subnet-consumer"
echo ""
echo "Cette IP sera l'endpoint local pour accéder au service du producteur."
