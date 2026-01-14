#!/bin/bash
# Lab 8.4 - Exercice 8.4.2 : Créer une Global Network Firewall Policy
# Objectif : Créer une politique de pare-feu réutilisable au niveau global

set -e

echo "=== Lab 8.4 - Exercice 2 : Créer une Global Network Firewall Policy ==="
echo ""

# Créer la politique globale
echo ">>> Création de la politique globale..."
gcloud compute network-firewall-policies create global-security-policy \
    --global \
    --description="Politique de sécurité globale"

echo ""
echo "Politique créée avec succès !"
echo ""

# Ajouter une règle pour bloquer les ports dangereux
echo ">>> Ajout de la règle : Bloquer ports dangereux..."
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=deny \
    --layer4-configs=tcp:23,tcp:3389,tcp:445 \
    --src-ip-ranges=0.0.0.0/0 \
    --description="Bloquer Telnet, RDP, SMB globalement"

echo ""

# Ajouter une règle pour autoriser les health checks Google
echo ">>> Ajout de la règle : Autoriser Health Checks Google..."
gcloud compute network-firewall-policies rules create 200 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:80,tcp:443 \
    --src-ip-ranges=35.191.0.0/16,130.211.0.0/22 \
    --description="Autoriser Health Checks Google"

echo ""

# Ajouter une règle pour autoriser IAP
echo ">>> Ajout de la règle : Autoriser IAP..."
gcloud compute network-firewall-policies rules create 300 \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:22,tcp:3389 \
    --src-ip-ranges=35.235.240.0/20 \
    --description="Autoriser SSH/RDP via IAP"

echo ""
echo "Toutes les règles ajoutées avec succès !"
echo ""

# Lister les règles
echo "=== Règles de la politique globale ==="
gcloud compute network-firewall-policies rules list \
    --firewall-policy=global-security-policy \
    --global-firewall-policy

echo ""
echo "Questions à considérer :"
echo "1. Quelle est la différence entre une Network Firewall Policy et une VPC Firewall Rule ?"
echo "2. Pourquoi utiliser une priorité de 100 pour les règles de deny ?"
echo "3. Comment cette politique peut-elle être réutilisée sur plusieurs VPCs ?"
