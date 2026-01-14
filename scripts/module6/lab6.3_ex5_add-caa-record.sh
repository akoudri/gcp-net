#!/bin/bash
# Lab 6.3 - Exercice 6.3.5 : Enregistrement CAA
# Objectif : Créer un enregistrement CAA pour contrôler les autorités de certification

set -e

echo "=== Lab 6.3 - Exercice 5 : Enregistrement CAA ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""

# CAA (Certificate Authority Authorization)
# Spécifie quelles CA peuvent émettre des certificats pour ce domaine
echo "Création de l'enregistrement CAA..."
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CAA \
    --ttl=300 \
    --rrdatas='0 issue "letsencrypt.org"','0 issue "pki.goog"','0 iodef "mailto:security@'"${DOMAIN}"'"'
echo ""

echo "Enregistrement CAA créé avec succès !"
echo ""
echo "Cet enregistrement spécifie que seuls Let's Encrypt et Google PKI"
echo "peuvent émettre des certificats pour ce domaine."
