#!/bin/bash
# Lab 5.5 - Exercice 5.5.2 : Réserver une adresse IP pour l'endpoint PSC
# Objectif : Réserver une IP interne pour l'endpoint PSC

set -e

echo "=== Lab 5.5 - Exercice 2 : Réserver une IP pour l'endpoint PSC ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Réserver une IP interne pour l'endpoint
echo "Réservation d'une IP interne pour l'endpoint PSC..."
gcloud compute addresses create psc-apis-endpoint \
    --region=$REGION \
    --subnet=subnet-psc \
    --addresses=10.1.0.100

echo ""
echo "IP réservée avec succès !"
echo ""

# Vérifier
echo "=== Détails de l'adresse réservée ==="
gcloud compute addresses describe psc-apis-endpoint --region=$REGION

echo ""
echo "=== IP réservée pour PSC ! ==="
echo ""
echo "Adresse : 10.1.0.100"
echo "Sous-réseau : subnet-psc"
echo ""
echo "Cette IP sera utilisée comme endpoint pour accéder aux APIs Google."
