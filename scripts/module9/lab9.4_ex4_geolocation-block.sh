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
# Utilisation de pays fictifs mais valides pour l'exemple (AQ=Antarctique, BV=Bouvet Island)
gcloud compute security-policies rules create 200 \
    --security-policy=policy-web-app \
    --expression="origin.region_code == 'AQ' || origin.region_code == 'BV'" \
    --action=deny-403 \
    --description="Bloquer pays AQ et BV (exemple)"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 200 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : 'AQ' (Antarctique) et 'BV' (Bouvet Island) sont des codes pays valides mais peu utilisés."
echo "Pour bloquer des pays réels dans un contexte de production, utilisez les codes ISO 3166-1 alpha-2 appropriés (ex: 'CN', 'RU', 'KP')."
