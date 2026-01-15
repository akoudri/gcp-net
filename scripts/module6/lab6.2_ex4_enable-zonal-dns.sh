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

# Activer le DNS zonal pour le projet via métadonnées
echo "Activation du DNS zonal pour le projet via métadonnées..."
gcloud compute project-info add-metadata \
    --metadata=VmDnsSetting=ZonalOnly 2>&1 | grep -v "Updated" || true
echo ""

# Vérifier
echo "Nouvelle configuration :"
gcloud compute project-info describe \
    --format="get(vmDnsSetting,commonInstanceMetadata.items)"
echo ""

echo "DNS zonal configuré via métadonnées!"
echo ""
echo "Note: Les VMs existantes peuvent nécessiter un redémarrage"
echo "pour prendre en compte le changement."
echo ""
echo "REMARQUE: La commande --default-vm-dns-setting n'est plus supportée"
echo "dans les versions récentes de gcloud. Le DNS zonal est maintenant"
echo "le comportement par défaut pour les nouveaux projets."
