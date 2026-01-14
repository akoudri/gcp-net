#!/bin/bash
# Lab 7.3 - Exercice 7.3.3 : Configurer le mode Actif/Passif avec MED
# Objectif : Configurer le mode Actif/Passif en utilisant les priorités MED

set -e

echo "=== Lab 7.3 - Exercice 3 : Configurer le mode Actif/Passif ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

cat << 'INFO'
Configuration du mode Actif/Passif avec MED (Multi-Exit Discriminator)
MED plus basse = priorité plus haute
- Tunnel 0: MED 100 (préféré)
- Tunnel 1: MED 200 (backup)

INFO

# Configurer le peer BGP du tunnel 0 avec MED basse (préféré)
echo ">>> Configuration tunnel 0 comme actif (MED=100)..."
gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --region=$REGION \
    --advertised-route-priority=100

# Configurer le peer BGP du tunnel 1 avec MED haute (backup)
echo ">>> Configuration tunnel 1 comme passif (MED=200)..."
gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --region=$REGION \
    --advertised-route-priority=200

# Faire de même côté On-premise
echo ">>> Configuration côté On-premise..."
gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --region=$REGION \
    --advertised-route-priority=200

echo ""
echo "=== Mode Actif/Passif configuré ==="
