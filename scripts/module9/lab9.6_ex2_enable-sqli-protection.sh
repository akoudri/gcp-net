#!/bin/bash
# Lab 9.6 - Exercice 9.6.2 : Activer la protection SQL Injection
# Objectif : Activer SQLi en mode Preview

set -e

echo "=== Lab 9.6 - Exercice 2 : Activer la protection SQL Injection ==="
echo ""

# Activer SQLi en mode Preview d'abord
echo "Création d'une règle WAF pour SQL Injection (mode Preview)..."
gcloud compute security-policies rules create 1000 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: Protection SQL Injection (preview)"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 1000 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : La règle est en mode PREVIEW."
echo "Les requêtes ne seront pas bloquées, mais seront loggées pour analyse."
