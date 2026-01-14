#!/bin/bash
# Lab 8.2 - Exercice 8.2.6 : Ajouter des règles de blocage explicites
# Objectif : Bloquer les ports dangereux et contrôler le trafic sortant

set -e

echo "=== Lab 8.2 - Exercice 6 : Ajouter des règles de blocage ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# Bloquer les ports dangereux
echo ">>> Création de la règle : Bloquer les ports dangereux..."
gcloud compute firewall-rules create ${VPC_NAME}-deny-dangerous-ports \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:23,tcp:3389,tcp:445,tcp:135-139 \
    --source-ranges=0.0.0.0/0 \
    --priority=500 \
    --description="Bloquer Telnet, RDP, SMB"

echo ""
echo "Règle de blocage des ports dangereux créée !"
echo ""

# Bloquer tout trafic sortant sauf nécessaire
echo ">>> Création de la règle : Deny all egress..."
gcloud compute firewall-rules create ${VPC_NAME}-deny-all-egress \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=DENY \
    --rules=all \
    --destination-ranges=0.0.0.0/0 \
    --priority=65000 \
    --description="Deny all egress par défaut"

echo ""

# Autoriser egress vers APIs Google
echo ">>> Création de la règle : Egress vers APIs Google..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=tcp:443 \
    --destination-ranges=199.36.153.8/30,199.36.153.4/30 \
    --priority=1000 \
    --description="Egress vers APIs Google"

echo ""

# Autoriser egress interne
echo ">>> Création de la règle : Egress interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-internal \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --action=ALLOW \
    --rules=all \
    --destination-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Egress interne"

echo ""
echo "Règles de blocage créées avec succès !"
echo ""

# Lister toutes les règles
echo "=== Toutes les règles de pare-feu ==="
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME" \
    --format="table(name,direction,priority,action,sourceRanges,destinationRanges,allowed,denied)" \
    --sort-by=priority

echo ""
echo "Questions à considérer :"
echo "1. Pourquoi utiliser des priorités différentes (500 vs 1000) ?"
echo "2. Que se passe-t-il si deux règles ont la même priorité mais des actions différentes ?"
echo "3. Comment la règle deny-all-egress améliore-t-elle la sécurité ?"
