#!/bin/bash
# Lab 5.3 - Exercice 5.3.6 : Configurer Cloud NAT pour l'accès Internet sortant
# Objectif : Permettre aux VMs sans IP externe d'accéder à Internet

set -e

echo "=== Lab 5.3 - Exercice 6 : Configurer Cloud NAT ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-psa \
    --network=$VPC_NAME \
    --region=$REGION

echo ""
echo "Cloud Router créé !"
echo ""

# Configurer Cloud NAT
echo "Configuration de Cloud NAT..."
gcloud compute routers nats create nat-psa-config \
    --router=router-nat-psa \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration Cloud NAT ==="
gcloud compute routers nats describe nat-psa-config \
    --router=router-nat-psa \
    --region=$REGION

echo ""
echo "=== Cloud NAT configuré ! ==="
echo ""
echo "Questions à considérer :"
echo ""
echo "1. Pourquoi configurer Cloud NAT avant de créer la VM cliente ?"
echo "   → Pour permettre à la VM d'installer des paquets (apt-get)"
echo "     même sans IP externe."
echo ""
echo "2. Cloud NAT permet-il aux VMs de recevoir du trafic entrant depuis Internet ?"
echo "   → Non, Cloud NAT est uniquement pour le trafic SORTANT."
echo ""
echo "3. Comment Cloud NAT se combine-t-il avec Private Google Access ?"
echo "   → Cloud NAT: accès Internet général (apt, github, etc.)"
echo "   → PGA: accès aux APIs Google (storage.googleapis.com, etc.)"
echo "   → Les deux sont complémentaires."
