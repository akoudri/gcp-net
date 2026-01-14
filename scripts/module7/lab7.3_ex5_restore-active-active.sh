#!/bin/bash
# Lab 7.3 - Exercice 7.3.5 : Revenir au mode Actif/Actif
# Objectif : Restaurer le mode Actif/Actif (ECMP)

set -e

echo "=== Lab 7.3 - Exercice 5 : Revenir au mode Actif/Actif ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Réinitialiser les priorités MED à la même valeur
echo ">>> Réinitialisation des priorités MED à 100 pour tous les tunnels..."

gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --region=$REGION \
    --advertised-route-priority=100

echo ""
echo "=== Mode Actif/Actif restauré ==="
