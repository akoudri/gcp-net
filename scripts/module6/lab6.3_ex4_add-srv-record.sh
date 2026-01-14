#!/bin/bash
# Lab 6.3 - Exercice 6.3.4 : Enregistrement SRV
# Objectif : Créer un enregistrement SRV pour un service

set -e

echo "=== Lab 6.3 - Exercice 4 : Enregistrement SRV ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""

# Enregistrement SRV pour un service SIP
# Format: priorité poids port cible
echo "Création de l'enregistrement SRV pour SIP..."
gcloud dns record-sets create "_sip._tcp.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=SRV \
    --ttl=300 \
    --rrdatas="10 5 5060 sip.${DOMAIN}."
echo ""

# Enregistrement A pour le serveur SIP
echo "Création de l'enregistrement A pour le serveur SIP..."
gcloud dns record-sets create "sip.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.50"
echo ""

echo "Enregistrement SRV créé avec succès !"
