#!/bin/bash
# Lab 6.3 - Exercice 6.3.6 : Lister et vérifier les enregistrements
# Objectif : Exporter et visualiser les enregistrements DNS

set -e

echo "=== Lab 6.3 - Exercice 6 : Lister et vérifier les enregistrements ==="
echo ""

# Lister tous les enregistrements
echo "=== Liste des enregistrements ==="
gcloud dns record-sets list --zone=zone-public-lab \
    --format="table(name,type,ttl,rrdatas)"
echo ""

# Exporter en format BIND (pour backup)
echo "Exportation en format BIND..."
gcloud dns record-sets export zone-public-lab.zone \
    --zone=zone-public-lab \
    --zone-file-format
echo ""

echo "Zone exportée dans le fichier : zone-public-lab.zone"
echo ""

echo "=== Contenu du fichier exporté ==="
cat zone-public-lab.zone
