#!/bin/bash
# Lab 2.2 - Exercice 2.2.3 : Créer les règles de pare-feu
# Objectif : Configurer des règles de pare-feu sécurisées

set -e

echo "=== Lab 2.2 - Exercice 3 : Créer les règles de pare-feu ==="
echo ""

# Variables
export VPC_NAME="production-vpc"

# Règle pour autoriser SSH depuis votre IP uniquement
export MY_IP=$(curl -s ifconfig.me)
echo "Votre IP publique : $MY_IP"
echo ""

echo "Création de la règle SSH restreinte..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=$MY_IP/32 \
    --target-tags=allow-ssh \
    --description="SSH depuis IP admin uniquement"

echo ""

# Règle pour autoriser ICMP interne (ping entre VMs)
echo "Création de la règle ICMP interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal-icmp \
    --network=$VPC_NAME \
    --allow=icmp \
    --source-ranges=10.1.0.0/24,10.2.0.0/24 \
    --description="ICMP entre sous-réseaux internes"

echo ""

# Règle pour autoriser tout le trafic interne
echo "Création de la règle trafic interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8 \
    --description="Trafic interne RFC1918"

echo ""
echo "Règles de pare-feu créées avec succès !"
echo ""

# Lister les règles créées
echo "=== Règles de pare-feu du VPC ==="
gcloud compute firewall-rules list --filter="network=$VPC_NAME"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi utilise-t-on des tags (--target-tags) pour la règle SSH ?"
echo "2. Est-il préférable d'utiliser 10.0.0.0/8 ou les plages exactes pour source-ranges ?"
