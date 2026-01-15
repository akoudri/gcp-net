#!/bin/bash
# Lab 9.9 - Exercice 9.9.4 : Bloquer les IPs malveillantes connues
# Objectif : Bloquer les IPs identifiées comme malveillantes par Google

set -e

echo "=== Lab 9.9 - Exercice 4 : Bloquer les IPs malveillantes connues ==="
echo ""

echo "⚠️  AVERTISSEMENT : Cette fonctionnalité nécessite Cloud Armor Plus (tier payant)."
echo "Threat Intelligence n'est pas disponible dans le tier standard."
echo ""
echo "Pour activer Cloud Armor Plus:"
echo "gcloud compute security-policies update policy-web-app --tier=PLUS"
echo ""
echo "Tentative de création de la règle..."

# Bloquer les IPs identifiées comme malveillantes par Google
echo "Création d'une règle pour bloquer les IPs malveillantes..."
gcloud compute security-policies rules create 160 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-known-malicious-ips')" \
    --action=deny-403 \
    --description="Bloquer IPs malveillantes" 2>&1 || {
    echo ""
    echo "❌ ERREUR : Threat Intelligence nécessite Cloud Armor Plus tier."
    echo "Cette fonctionnalité n'est pas disponible avec le tier standard."
    echo ""
    echo "La Threat Intelligence de Google détecte et bloque automatiquement"
    echo "les IPs malveillantes connues, mais nécessite un abonnement payant."
    exit 0
}

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
