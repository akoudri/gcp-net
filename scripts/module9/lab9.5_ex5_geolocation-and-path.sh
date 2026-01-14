#!/bin/bash
# Lab 9.5 - Exercice 9.5.5 : Combinaison géolocalisation + path
# Objectif : Accès /admin uniquement depuis la France

set -e

echo "=== Lab 9.5 - Exercice 5 : Combinaison géolocalisation + path ==="
echo ""

# Accès /admin uniquement depuis la France
echo "Mise à jour de la règle 300 pour /admin uniquement depuis FR..."
gcloud compute security-policies rules update 300 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/admin') && origin.region_code != 'FR'" \
    --description="Admin uniquement depuis FR"

echo ""
echo "Règle mise à jour avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 300 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Maintenant, /admin est bloqué uniquement pour les IPs hors France."
echo "Les requêtes depuis la France vers /admin sont autorisées."
