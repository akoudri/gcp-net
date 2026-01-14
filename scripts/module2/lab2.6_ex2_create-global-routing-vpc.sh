#!/bin/bash
# Lab 2.6 - Exercice 2.6.2 : Créer un VPC avec routage global
# Objectif : Comprendre le mode de routage global

set -e

echo "=== Lab 2.6 - Exercice 2 : VPC avec routage global ==="
echo ""

# VPC avec routage global
echo "Création du VPC avec routage global..."
gcloud compute networks create vpc-global \
    --subnet-mode=custom \
    --bgp-routing-mode=global

echo ""

# Sous-réseaux dans deux régions
echo "Création du sous-réseau Europe..."
gcloud compute networks subnets create subnet-eu-global \
    --network=vpc-global \
    --region=europe-west1 \
    --range=10.70.0.0/24

echo ""

echo "Création du sous-réseau US..."
gcloud compute networks subnets create subnet-us-global \
    --network=vpc-global \
    --region=us-central1 \
    --range=10.71.0.0/24

echo ""

# Vérifier le mode de routage
echo "=== Mode de routage configuré ==="
gcloud compute networks describe vpc-global \
    --format="get(routingConfig.routingMode)"

echo ""
echo "VPC avec routage global créé avec succès !"
echo ""

cat << 'EOF'
Différence entre routage régional et global :

Mode Régional :
- Les routes dynamiques (BGP) apprises dans une région sont visibles
  UNIQUEMENT par les VMs de cette région
- Cas d'usage : VPN ou Interconnect avec connectivité régionale

Mode Global :
- Les routes dynamiques sont propagées à TOUTES les régions du VPC
- Les VMs de toutes les régions peuvent atteindre les destinations
  apprises via BGP
- Le trafic traverse le backbone Google entre régions
- Cas d'usage : VPN ou Interconnect avec connectivité globale

Exemple :
  VPN en Europe apprend 192.168.0.0/16
  - Régional : Seules les VMs européennes peuvent l'atteindre
  - Global : Toutes les VMs (EU + US) peuvent l'atteindre
EOF
