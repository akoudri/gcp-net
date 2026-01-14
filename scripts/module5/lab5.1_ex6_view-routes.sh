#!/bin/bash
# Lab 5.1 - Exercice 5.1.6 : Observer les routes utilisées par PGA
# Objectif : Comprendre comment PGA route le trafic

set -e

echo "=== Lab 5.1 - Exercice 6 : Observer les routes utilisées par PGA ==="
echo ""

export VPC_NAME="vpc-private-access"

echo "VPC : $VPC_NAME"
echo ""

# Voir les routes du VPC
echo "=== Routes du VPC $VPC_NAME ==="
gcloud compute routes list --filter="network:$VPC_NAME" --format="table(name,destRange,nextHopGateway,priority)"

echo ""
echo "=== Explications ==="
echo ""
echo "La route par défaut (0.0.0.0/0) vers default-internet-gateway est utilisée"
echo "pour router le trafic vers les IPs Google."
echo ""
echo "PGA 'intercepte' ce trafic pour les APIs Google en:"
echo "1. Utilisant les routes par défaut existantes"
echo "2. Routant vers les IPs VIP privées de Google (199.36.153.8/30)"
echo "3. Ne nécessitant aucune route personnalisée"
echo ""
echo "Ranges IP couverts par PGA :"
echo "- private.googleapis.com: 199.36.153.8/30"
echo "- restricted.googleapis.com: 199.36.153.4/30 (pour VPC Service Controls)"
