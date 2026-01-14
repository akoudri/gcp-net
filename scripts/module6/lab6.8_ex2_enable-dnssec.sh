#!/bin/bash
# Lab 6.8 - Exercice 6.8.2 : Activer DNSSEC sur la zone publique
# Objectif : Activer DNSSEC sur une zone DNS publique

set -e

echo "=== Lab 6.8 - Exercice 2 : Activer DNSSEC sur la zone publique ==="
echo ""

# Vérifier que la zone publique existe
if ! gcloud dns managed-zones describe zone-public-lab &>/dev/null; then
    echo "⚠️  La zone publique zone-public-lab n'existe pas."
    echo "Exécutez d'abord le script lab6.3_ex1_create-public-zone.sh"
    exit 1
fi

# Activer DNSSEC (sur la zone publique créée précédemment)
echo "Activation de DNSSEC..."
gcloud dns managed-zones update zone-public-lab \
    --dnssec-state=on
echo ""

echo "DNSSEC activé avec succès !"
echo ""

# Vérifier l'état DNSSEC
echo "=== Configuration DNSSEC ==="
gcloud dns managed-zones describe zone-public-lab \
    --format="yaml(dnsSecConfig)"
