#!/bin/bash
# Lab 9.4 - Exercice 9.4.2 : Bloquer des plages IP malveillantes
# Objectif : Bloquer plusieurs plages IP (exemple avec IPs de test RFC 5737)

set -e

echo "=== Lab 9.4 - Exercice 2 : Bloquer des plages IP malveillantes ==="
echo ""

# Bloquer plusieurs plages IP (exemple avec IPs de test RFC 5737)
echo "Création d'une règle pour bloquer des plages IP malveillantes..."
gcloud compute security-policies rules create 100 \
    --security-policy=policy-web-app \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24,192.0.2.0/24" \
    --action=deny-403 \
    --description="Bloquer IPs malveillantes connues (RFC 5737)"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier la règle
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 100 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Les plages IP utilisées (198.51.100.0/24, 203.0.113.0/24, 192.0.2.0/24)"
echo "sont des plages de test définies dans RFC 5737 et ne sont pas routées sur Internet."
