#!/bin/bash
# Lab 8.3 - Exercice 8.3.5 : Créer des règles basées sur Service Accounts
# Objectif : Configurer des règles de pare-feu utilisant les Service Accounts

set -e

echo "=== Lab 8.3 - Exercice 5 : Règles basées sur Service Accounts ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-security-lab"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo ""

# Règle: web → api
echo ">>> Création de la règle : Web vers API (Service Accounts)..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-web-to-api-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-service-accounts=sa-web@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-api@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="Web vers API (Service Accounts)"

echo ""

# Règle: api → db
echo ">>> Création de la règle : API vers Database (Service Accounts)..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-api-to-db-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:5432 \
    --source-service-accounts=sa-api@${PROJECT_ID}.iam.gserviceaccount.com \
    --target-service-accounts=sa-db@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="API vers Database (Service Accounts)"

echo ""

# Règle: HTTP vers web
echo ">>> Création de la règle : HTTP vers Web (Service Account)..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-http-web-sa \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-service-accounts=sa-web@${PROJECT_ID}.iam.gserviceaccount.com \
    --priority=1000 \
    --description="HTTP/HTTPS vers web (Service Account)"

echo ""
echo "Règles créées avec succès !"
echo ""

# Lister les règles
echo "=== Règles de pare-feu basées sur Service Accounts ==="
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND name~'-sa$'" \
    --format="table(name,direction,priority,sourceServiceAccounts,targetServiceAccounts,allowed)"

echo ""
echo "Questions à considérer :"
echo "1. Comment ces règles diffèrent-elles des règles basées sur les tags ?"
echo "2. Que se passe-t-il si on essaie de modifier le Service Account d'une VM ?"
echo "3. Comment débugger une connexion refusée avec des règles basées sur SA ?"
