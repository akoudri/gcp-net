#!/bin/bash
# Lab 7.8 - Exercice 7.8.3 : Établir les VPN vers chaque site
# Objectif : Créer les Cloud Routers et passerelles VPN pour chaque site

set -e

echo "=== Lab 7.8 - Exercice 3 : Établir les VPN vers chaque site ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

cat << 'INFO'
Cette partie est simplifiée - en production, chaque site aurait
son propre équipement VPN.

Création des Cloud Routers et passerelles VPN pour chaque site...

INFO

# Créer les Cloud Routers pour le hub
echo ">>> Création des Cloud Routers et passerelles VPN..."
for SITE in paris lyon berlin; do
    case $SITE in
        paris)  ASN=65011 ;;
        lyon)   ASN=65012 ;;
        berlin) ASN=65013 ;;
    esac

    echo "  - Configuration site $SITE (ASN: $ASN)"

    gcloud compute routers create router-hub-${SITE} \
        --network=vpc-hub-ncc \
        --region=$REGION \
        --asn=$ASN

    gcloud compute vpn-gateways create vpn-gw-hub-${SITE} \
        --network=vpc-hub-ncc \
        --region=$REGION

    gcloud compute routers create router-site-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --asn=$((ASN + 10))

    gcloud compute vpn-gateways create vpn-gw-site-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION
done

echo ""
echo "=== Cloud Routers et passerelles VPN créés ==="
echo ""
echo "Routers créés :"
gcloud compute routers list --filter="region:$REGION"
echo ""
echo "Passerelles VPN créées :"
gcloud compute vpn-gateways list --filter="region:$REGION"

echo ""
echo "NOTE: La création des tunnels VPN complets suivrait le même pattern"
echo "que dans le Lab 7.1, répété pour chaque site."
