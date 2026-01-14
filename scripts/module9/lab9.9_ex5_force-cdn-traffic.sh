#!/bin/bash
# Lab 9.9 - Exercice 9.9.5 : Forcer le passage par un CDN
# Objectif : Accepter uniquement le trafic venant de Cloudflare ou Fastly

set -e

echo "=== Lab 9.9 - Exercice 5 : Forcer le passage par un CDN ==="
echo ""

# Accepter uniquement le trafic venant de Cloudflare ou Fastly
echo "Création d'une règle pour forcer le passage par CDN..."
gcloud compute security-policies rules create 20 \
    --security-policy=policy-web-app \
    --expression="!origin.ip.matches(getNamedIpList('sourceiplist-fastly')) && !origin.ip.matches(getNamedIpList('sourceiplist-cloudflare'))" \
    --action=deny-403 \
    --description="Trafic doit passer par CDN"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 20 \
    --security-policy=policy-web-app

echo ""
echo "⚠️  ATTENTION : Cette règle bloque tout trafic qui ne vient PAS de Fastly ou Cloudflare."
echo "Si vous n'utilisez pas de CDN, cette règle va bloquer tout le trafic !"
echo ""

read -p "Voulez-vous supprimer cette règle ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Suppression de la règle..."
    gcloud compute security-policies rules delete 20 \
        --security-policy=policy-web-app --quiet
    echo "Règle supprimée !"
else
    echo "Règle conservée. Supprimez-la manuellement si nécessaire."
fi
