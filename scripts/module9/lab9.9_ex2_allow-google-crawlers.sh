#!/bin/bash
# Lab 9.9 - Exercice 9.9.2 : Autoriser les crawlers Google
# Objectif : Autoriser Googlebot avec priorité haute

set -e

echo "=== Lab 9.9 - Exercice 2 : Autoriser les crawlers Google ==="
echo ""

# Autoriser Googlebot (priorité haute pour ne pas bloquer par d'autres règles)
echo "Création d'une règle pour autoriser Googlebot..."
gcloud compute security-policies rules create 10 \
    --security-policy=policy-web-app \
    --expression="origin.ip.matches(getNamedIpList('sourceiplist-google-crawlers'))" \
    --action=allow \
    --description="Autoriser Googlebot"

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
