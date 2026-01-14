#!/bin/bash
# Lab 2.6 - Exercice 2.6.3 : Simuler des routes dynamiques (Cloud Router)
# Objectif : Créer des Cloud Routers et observer les routes

set -e

echo "=== Lab 2.6 - Exercice 3 : Simuler des routes dynamiques ==="
echo ""

# Créer un Cloud Router dans chaque VPC (Europe uniquement)
echo "Création du Cloud Router pour VPC régional..."
gcloud compute routers create router-regional \
    --network=vpc-regional \
    --region=europe-west1 \
    --asn=65001

echo ""

echo "Création du Cloud Router pour VPC global..."
gcloud compute routers create router-global \
    --network=vpc-global \
    --region=europe-west1 \
    --asn=65002

echo ""

# Afficher les routes dans chaque VPC
echo "=== Routes VPC Regional ==="
gcloud compute routes list --filter="network=vpc-regional"

echo ""

echo "=== Routes VPC Global ==="
gcloud compute routes list --filter="network=vpc-global"

echo ""
echo "Cloud Routers créés avec succès !"
echo ""
echo "Note : Les Cloud Routers sont nécessaires pour :"
echo "- Cloud VPN"
echo "- Cloud Interconnect"
echo "- Cloud NAT"
echo "- Routage dynamique BGP"
