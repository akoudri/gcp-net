#!/bin/bash
# Lab 6.3 - Exercice 6.3.3 : Enregistrements TXT (SPF, DKIM, vérification)
# Objectif : Créer des enregistrements TXT pour la validation email

set -e

echo "=== Lab 6.3 - Exercice 3 : Enregistrements TXT ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""

# SPF pour la validation email
echo "Création de l'enregistrement SPF..."
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"v=spf1 include:_spf.google.com ~all"'
echo ""

# Enregistrement de vérification Google
echo "Création de l'enregistrement de vérification Google..."
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"google-site-verification=XXXXXXXXXXXX"'
echo ""

echo "Enregistrements TXT créés avec succès !"
echo ""
echo "Note : Pour ajouter plusieurs TXT au même nom, utiliser une transaction"
echo "ou spécifier toutes les valeurs dans --rrdatas"
