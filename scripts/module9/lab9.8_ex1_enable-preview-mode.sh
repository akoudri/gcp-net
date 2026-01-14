#!/bin/bash
# Lab 9.8 - Exercice 9.8.1 : Activer le mode Preview
# Objectif : Mettre des règles en mode Preview et créer une nouvelle règle LFI

set -e

echo "=== Lab 9.8 - Exercice 1 : Activer le mode Preview ==="
echo ""

# Mettre une règle existante en Preview
echo "Mise en mode Preview de la règle 1000 (SQLi)..."
gcloud compute security-policies rules update 1000 \
    --security-policy=policy-web-app \
    --preview

echo ""
# Créer une nouvelle règle en mode Preview
echo "Création d'une règle WAF pour LFI (mode Preview)..."
gcloud compute security-policies rules create 1200 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('lfi-v33-stable')" \
    --action=deny-403 \
    --preview \
    --description="WAF: LFI (preview)"

echo ""
echo "Règles configurées en mode Preview avec succès !"
echo ""

# Vérifier
echo "=== Règles en mode Preview ==="
gcloud compute security-policies rules list --security-policy=policy-web-app \
    | grep -i preview

echo ""
echo "REMARQUE : En mode Preview, les règles détectent mais ne bloquent pas."
echo "Utilisez ce mode pour valider les règles avant de les activer."
