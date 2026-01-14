#!/bin/bash
# Lab 9.3 - Exercice 9.3.3 : Attacher la politique au backend service
# Objectif : Associer la politique Cloud Armor au backend service

set -e

echo "=== Lab 9.3 - Exercice 3 : Attacher la politique au backend service ==="
echo ""

# Attacher la politique
echo "Attachement de la politique au backend service..."
gcloud compute backend-services update backend-web \
    --security-policy=policy-web-app \
    --global

echo ""
echo "Politique attachée avec succès !"
echo ""

# Vérifier l'attachement
echo "=== Vérification de l'attachement ==="
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(securityPolicy)"

echo ""
echo "La politique Cloud Armor est maintenant active sur le backend service."
