#!/bin/bash
# Lab 4.5 - Exercice 4.5.5 : Créer les règles de pare-feu centralisées
# Objectif : Configurer les règles de pare-feu dans le projet hôte

set -e

echo "=== Lab 4.5 - Exercice 5 : Créer les règles de pare-feu centralisées ==="
echo ""

# Variables
export HOST_PROJECT="${HOST_PROJECT:-network-host-YYYYMMDD}"

if [ "$HOST_PROJECT" = "network-host-YYYYMMDD" ]; then
    echo "❌ Veuillez définir la variable HOST_PROJECT"
    exit 1
fi

echo "Projet hôte : $HOST_PROJECT"
echo ""

# Règles de pare-feu dans le projet hôte
echo "Création de la règle allow-internal..."
gcloud compute firewall-rules create shared-vpc-allow-internal \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp,udp,icmp \
    --source-ranges=10.100.0.0/16 \
    --description="Autoriser trafic interne"

echo ""

echo "Création de la règle allow-ssh-iap..."
gcloud compute firewall-rules create shared-vpc-allow-ssh-iap \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH via IAP"

echo ""

echo "Création de la règle allow-health-checks..."
gcloud compute firewall-rules create shared-vpc-allow-health-checks \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --allow=tcp:80,tcp:443,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Health checks Google"

echo ""
echo "Règles de pare-feu créées avec succès !"
echo ""

# Afficher les règles
echo "=== Règles de pare-feu du VPC partagé ==="
gcloud compute firewall-rules list --project=$HOST_PROJECT --filter="network:shared-vpc"
