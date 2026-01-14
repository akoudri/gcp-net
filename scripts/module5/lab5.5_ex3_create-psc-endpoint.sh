#!/bin/bash
# Lab 5.5 - Exercice 5.5.3 : Créer l'endpoint PSC pour les APIs Google
# Objectif : Créer un endpoint PSC vers toutes les APIs Google

set -e

echo "=== Lab 5.5 - Exercice 3 : Créer l'endpoint PSC pour les APIs Google ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer la forwarding rule PSC vers toutes les APIs Google
echo "Création de l'endpoint PSC vers toutes les APIs Google..."
gcloud compute forwarding-rules create psc-endpoint-all-apis \
    --region=$REGION \
    --network=$VPC_NAME \
    --address=psc-apis-endpoint \
    --target-google-apis-bundle=all-apis

echo ""
echo "Endpoint PSC créé avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de l'endpoint PSC ==="
gcloud compute forwarding-rules describe psc-endpoint-all-apis \
    --region=$REGION

echo ""

# Voir le statut
echo "=== Liste des endpoints PSC ==="
gcloud compute forwarding-rules list \
    --filter="name:psc-endpoint" \
    --format="table(name,IPAddress,target,region)"

echo ""
echo "=== Endpoint PSC créé ! ==="
echo ""
echo "Questions à considérer :"
echo ""
echo "1. Quelle est la différence entre 'all-apis' et 'vpc-sc' comme bundle ?"
echo "   → all-apis: Accès à toutes les APIs Google"
echo "   → vpc-sc: Uniquement les APIs compatibles VPC Service Controls"
echo ""
echo "2. L'endpoint PSC a-t-il une IP publique ou privée ?"
echo "   → IP privée (10.1.0.100) dans VOTRE VPC"
