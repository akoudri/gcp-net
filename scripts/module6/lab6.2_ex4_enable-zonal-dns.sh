#!/bin/bash
# Lab 6.2 - Exercice 6.2.4 : Activer le DNS zonal
# Objectif : Configurer le DNS zonal au niveau du projet

set -e

echo "=== Lab 6.2 - Exercice 4 : Activer le DNS zonal ==="
echo ""

echo "Configuration actuelle :"
gcloud compute project-info describe \
    --format="get(vmDnsSetting)"
echo ""

# Activer le DNS zonal pour le projet
echo "Activation du DNS zonal pour le projet..."
gcloud compute project-info update \
    --default-vm-dns-setting=ZONAL_ONLY
echo ""

# Vérifier
echo "Nouvelle configuration :"
gcloud compute project-info describe \
    --format="get(vmDnsSetting)"
echo ""

echo "DNS zonal activé avec succès !"
echo ""
echo "Note: Les VMs existantes peuvent nécessiter un redémarrage"
echo "pour prendre en compte le changement."
