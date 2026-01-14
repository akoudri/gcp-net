#!/bin/bash
# Lab 10.6 - Exercice 10.6.2 : Configurer Cloud NAT pour l'accès sortant
# Objectif : Configurer Cloud NAT pour que les VMs sans IP externe puissent accéder à Internet

set -e

echo "=== Lab 10.6 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Cloud NAT est nécessaire pour que les VMs sans IP externe puissent :"
echo "  - Télécharger des paquets (apt-get install)"
echo "  - Accéder aux services Google APIs"
echo "  - Se connecter à Internet de manière sécurisée"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-lb \
    --network=vpc-lb-lab \
    --region=$REGION

echo ""
echo "Configuration de Cloud NAT..."

# Configurer Cloud NAT pour l'accès sortant
gcloud compute routers nats create nat-internal-lb \
    --router=router-nat-lb \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Vérification de la configuration..."

# Vérifier la configuration
gcloud compute routers nats list \
    --router=router-nat-lb \
    --region=$REGION

echo ""
gcloud compute routers describe router-nat-lb \
    --region=$REGION \
    --format="yaml(nats)"

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""
echo "=== Résumé ==="
echo "Cloud Router : router-nat-lb"
echo "Cloud NAT : nat-internal-lb"
echo "Région : $REGION"
echo ""
echo "Questions de réflexion :"
echo "1. Pourquoi utiliser Cloud NAT pour les microservices internes ?"
echo "2. Quel est l'impact sur la sécurité ?"
echo "3. Les VMs peuvent-elles recevoir du trafic entrant depuis Internet ?"
