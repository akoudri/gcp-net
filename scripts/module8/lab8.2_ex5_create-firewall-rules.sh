#!/bin/bash
# Lab 8.2 - Exercice 8.2.5 : Créer les règles de pare-feu
# Objectif : Configurer des règles de pare-feu basées sur les tags

set -e

echo "=== Lab 8.2 - Exercice 5 : Créer les règles de pare-feu ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# 1. Autoriser SSH via IAP
echo ">>> Création de la règle : SSH via IAP..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap-ssh \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --priority=1000 \
    --description="SSH via IAP"

echo ""

# 2. Autoriser HTTP/HTTPS vers les serveurs web
echo ">>> Création de la règle : HTTP/HTTPS vers serveurs web..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-web \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web \
    --priority=1000 \
    --description="HTTP/HTTPS vers serveurs web"

echo ""

# 3. Autoriser web → api sur port 8080
echo ">>> Création de la règle : Web vers API..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-tags=web \
    --target-tags=api \
    --priority=1000 \
    --description="Web vers API"

echo ""

# 4. Autoriser api → db sur port 5432
echo ">>> Création de la règle : API vers Database..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:5432 \
    --source-tags=api \
    --target-tags=db \
    --priority=1000 \
    --description="API vers Database"

echo ""

# 5. Autoriser ICMP interne
echo ">>> Création de la règle : ICMP interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-icmp-internal \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="ICMP interne"

echo ""
echo "Toutes les règles créées avec succès !"
echo ""

# Lister les règles créées
echo "=== Règles de pare-feu créées ==="
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME" \
    --format="table(name,direction,priority,sourceRanges,sourceTags,targetTags,allowed)"

echo ""
echo "Questions à considérer :"
echo "1. Comment les priorités affectent-elles l'évaluation des règles ?"
echo "2. Pourquoi utiliser des tags plutôt que des plages IP ?"
echo "3. Quelle règle permet l'accès SSH aux VMs ?"
