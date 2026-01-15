#!/bin/bash
# Lab 6.7 - Exercice 6.7.1 : Créer une politique DNS complète
# Objectif : Créer une politique DNS avec logging et inbound forwarding

set -e

echo "=== Lab 6.7 - Exercice 1 : Créer une politique DNS complète ==="
echo ""

export VPC_NAME="vpc-dns-lab"

echo "VPC : $VPC_NAME"
echo ""

# Supprimer les politiques existantes si présentes
echo "Suppression des politiques existantes (si présentes)..."
gcloud dns policies delete policy-inbound --quiet 2>/dev/null && echo "policy-inbound supprimée" || true
gcloud dns policies delete policy-dns-full --quiet 2>/dev/null && echo "policy-dns-full supprimée" || true
echo ""

# Créer une nouvelle politique DNS complète
echo "Création de la politique DNS complète..."
if gcloud dns policies describe policy-dns-full &>/dev/null; then
    echo "La politique policy-dns-full existe déjà"
else
    gcloud dns policies create policy-dns-full \
        --networks=$VPC_NAME \
        --enable-inbound-forwarding \
        --enable-logging \
        --description="Politique DNS complète avec logging"
fi
echo ""

echo "Politique DNS créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la politique DNS ==="
gcloud dns policies describe policy-dns-full
