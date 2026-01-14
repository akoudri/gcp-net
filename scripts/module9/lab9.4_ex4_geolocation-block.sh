#!/bin/bash
# Lab 9.4 - Exercice 9.4.4 : Filtrage géographique inversé (bloquer certains pays)
# Objectif : Bloquer des pays spécifiques

set -e

echo "=== Lab 9.4 - Exercice 4 : Filtrage géographique inversé ==="
echo ""

# Supprimer d'abord la règle précédente si elle existe
echo "Suppression de la règle 200 existante (si présente)..."
gcloud compute security-policies rules delete 200 \
    --security-policy=policy-web-app --quiet 2>/dev/null || true

echo ""
echo "Création d'une règle pour bloquer certains pays (exemple)..."
gcloud compute security-policies rules create 200 \
    --security-policy=policy-web-app \
    --expression="origin.region_code == 'XX' || origin.region_code == 'YY'" \
    --action=deny-403 \
    --description="Bloquer pays XX et YY (exemple)"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 200 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : 'XX' et 'YY' ne sont pas des codes pays valides."
echo "Pour bloquer des pays réels, utilisez les codes ISO 3166-1 alpha-2 (ex: 'CN', 'RU', 'KP')."
