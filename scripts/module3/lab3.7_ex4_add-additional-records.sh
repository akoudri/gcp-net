#!/bin/bash
# Lab 3.7 - Exercice 3.7.4 : Ajouter des enregistrements supplémentaires
# Objectif : Ajouter des enregistrements MX et TXT

set -e

echo "=== Lab 3.7 - Exercice 4 : Ajouter des enregistrements supplémentaires ==="
echo ""

echo "Ajout d'un enregistrement MX..."
# Ajouter un enregistrement MX
gcloud dns record-sets transaction start --zone=internal-zone

gcloud dns record-sets transaction add "10 mail.internal.lab." \
    --name="internal.lab." \
    --ttl=300 \
    --type=MX \
    --zone=internal-zone

gcloud dns record-sets transaction execute --zone=internal-zone

echo ""
echo "Ajout d'un enregistrement TXT..."
# Ajouter un enregistrement TXT
gcloud dns record-sets create "internal.lab." \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"v=spf1 include:_spf.google.com ~all"' \
    --zone=internal-zone

echo ""
echo "Enregistrements supplémentaires ajoutés avec succès !"
echo ""

# Vérifier
echo "=== Tous les enregistrements ==="
gcloud dns record-sets list --zone=internal-zone \
    --format="table(name,type,ttl,rrdatas)"
echo ""
