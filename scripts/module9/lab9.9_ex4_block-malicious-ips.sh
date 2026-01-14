#!/bin/bash
# Lab 9.9 - Exercice 9.9.4 : Bloquer les IPs malveillantes connues
# Objectif : Bloquer les IPs identifiées comme malveillantes par Google

set -e

echo "=== Lab 9.9 - Exercice 4 : Bloquer les IPs malveillantes connues ==="
echo ""

# Bloquer les IPs identifiées comme malveillantes par Google
echo "Création d'une règle pour bloquer les IPs malveillantes..."
gcloud compute security-policies rules create 160 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-known-malicious-ips')" \
    --action=deny-403 \
    --description="Bloquer IPs malveillantes"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 160 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle utilise la Threat Intelligence de Google."
echo "Elle bloque automatiquement les IPs connues pour des activités malveillantes."
echo "La liste est mise à jour en continu par Google."
