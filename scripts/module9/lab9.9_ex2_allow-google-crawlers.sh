#!/bin/bash
# Lab 9.9 - Exercice 9.9.2 : Autoriser les crawlers Google
# Objectif : Autoriser Googlebot avec priorité haute

set -e

echo "=== Lab 9.9 - Exercice 2 : Autoriser les crawlers Google ==="
echo ""

echo "⚠️  AVERTISSEMENT : Cette fonctionnalité nécessite Cloud Armor Plus (tier payant)."
echo "Les Named IP Lists ne sont pas disponibles dans le tier standard."
echo ""
echo "Pour activer Cloud Armor Plus:"
echo "gcloud compute security-policies update policy-web-app --tier=PLUS"
echo ""
echo "Tentative de création de la règle..."

# Autoriser Googlebot (priorité haute pour ne pas bloquer par d'autres règles)
echo "Création d'une règle pour autoriser Googlebot..."
gcloud compute security-policies rules create 10 \
    --security-policy=policy-web-app \
    --expression="origin.ip.matches(getNamedIpList('sourceiplist-google-crawlers'))" \
    --action=allow \
    --description="Autoriser Googlebot" 2>&1 || {
    echo ""
    echo "❌ ERREUR : Named IP Lists nécessitent Cloud Armor Plus tier."
    echo "Cette fonctionnalité n'est pas disponible avec le tier standard."
    echo ""
    echo "Alternative: Utiliser les plages IP Google publiquement documentées"
    echo "gcloud compute security-policies rules create 10 \\"
    echo "    --security-policy=policy-web-app \\"
    echo "    --src-ip-ranges=\"66.249.64.0/19,66.102.0.0/20\" \\"
    echo "    --action=allow \\"
    echo "    --description=\"Autoriser Googlebot (IPs statiques)\""
    exit 0
}

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 10 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle a une priorité haute (10) pour s'appliquer avant les autres."
echo "Elle autorise explicitement les crawlers Google (Googlebot)."
