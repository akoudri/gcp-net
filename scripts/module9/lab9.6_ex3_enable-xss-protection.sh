#!/bin/bash
# Lab 9.6 - Exercice 9.6.3 : Activer la protection XSS
# Objectif : Activer XSS en mode Preview

set -e

echo "=== Lab 9.6 - Exercice 3 : Activer la protection XSS ==="
echo ""

# Activer XSS en mode Preview
echo "Création d'une règle WAF pour XSS (mode Preview)..."
gcloud compute security-policies rules create 1100 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('xss-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: Protection XSS (preview)"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 1100 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : La règle est en mode PREVIEW."
echo "Les requêtes ne seront pas bloquées, mais seront loggées pour analyse."
