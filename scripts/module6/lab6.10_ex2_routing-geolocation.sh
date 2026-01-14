#!/bin/bash
# Lab 6.10 - Exercice 6.10.2 : Routing Geolocation
# Objectif : Configurer le routage géographique

set -e

echo "=== Lab 6.10 - Exercice 2 : Routing Geolocation ==="
echo ""

echo "Note : Les routing policies nécessitent une zone publique."
echo ""

# Vérifier que la zone publique existe
if ! gcloud dns managed-zones describe zone-public-lab &>/dev/null; then
    echo "⚠️  La zone publique zone-public-lab n'existe pas."
    echo "Exécutez d'abord le script lab6.3_ex1_create-public-zone.sh"
    exit 1
fi

# Créer des enregistrements avec politique de géolocalisation
echo "Création d'un enregistrement avec politique de géolocalisation..."
echo "Les clients seront dirigés vers le serveur le plus proche."
echo ""

gcloud dns record-sets create "geo.example-lab.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --routing-policy-type=GEO \
    --routing-policy-data="europe-west1=10.0.0.100;us-central1=10.1.0.100;asia-east1=10.2.0.100"
echo ""

echo "Enregistrement géographique créé avec succès !"
echo ""

# Vérifier
echo "=== Configuration de l'enregistrement ==="
gcloud dns record-sets describe "geo.example-lab.com." \
    --zone=zone-public-lab \
    --type=A
echo ""

echo "Configuration :"
echo "- Clients depuis Europe → 10.0.0.100"
echo "- Clients depuis US → 10.1.0.100"
echo "- Clients depuis Asie → 10.2.0.100"
