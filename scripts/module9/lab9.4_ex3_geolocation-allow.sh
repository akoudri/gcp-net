#!/bin/bash
# Lab 9.4 - Exercice 9.4.3 : Filtrage par géolocalisation
# Objectif : Autoriser uniquement certains pays (FR, BE, CH, CA)

set -e

echo "=== Lab 9.4 - Exercice 3 : Filtrage par géolocalisation ==="
echo ""

# Autoriser uniquement certains pays (FR, BE, CH, CA)
echo "Création d'une règle pour autoriser uniquement FR, BE, CH, CA..."
gcloud compute security-policies rules create 200 \
    --security-policy=policy-web-app \
    --expression="origin.region_code != 'FR' && origin.region_code != 'BE' && origin.region_code != 'CH' && origin.region_code != 'CA'" \
    --action=deny-403 \
    --description="Autoriser uniquement FR, BE, CH, CA"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 200 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle bloque tout le trafic qui ne provient PAS de FR, BE, CH ou CA."
echo "Si votre IP est dans un autre pays, vous serez bloqué."
