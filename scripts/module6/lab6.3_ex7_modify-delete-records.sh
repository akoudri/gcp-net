#!/bin/bash
# Lab 6.3 - Exercice 6.3.7 : Modifier et supprimer des enregistrements
# Objectif : Apprendre à modifier et supprimer des enregistrements DNS

set -e

echo "=== Lab 6.3 - Exercice 7 : Modifier et supprimer des enregistrements ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""

# Pour modifier un enregistrement, il faut le supprimer puis le recréer

# Supprimer un enregistrement
echo "Suppression de l'enregistrement CNAME pour blog..."
gcloud dns record-sets delete "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CNAME
echo ""

# Recréer avec une nouvelle valeur
echo "Recréation de l'enregistrement blog en tant que A (au lieu de CNAME)..."
gcloud dns record-sets create "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.100"
echo ""

echo "Enregistrement modifié avec succès !"
echo ""

echo "=== Liste des enregistrements mise à jour ==="
gcloud dns record-sets list --zone=zone-public-lab --filter="name:blog"
