#!/bin/bash
# Lab 10.6 - Exercice 10.6.5 : Tester l'Internal LB
# Objectif : Créer une VM client et tester l'Internal Load Balancer

set -e

echo "=== Lab 10.6 - Exercice 5 : Tester l'Internal LB ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Créer une VM client pour tester
echo "Création d'une VM client..."
gcloud compute instances create vm-client \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-lb-lab \
    --subnet=subnet-internal \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VM client créée !"
echo ""
echo "Attendez quelques secondes que la VM démarre..."
sleep 30

echo ""
echo "Test de l'Internal Load Balancer depuis la VM client..."
echo ""

# Tester depuis la VM client
gcloud compute ssh vm-client --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Internal LB ==="
echo ""

echo "Service Users :"
curl -s http://10.0.2.100/users/

echo ""
echo ""
echo "Service Orders :"
curl -s http://10.0.2.100/orders/

echo ""
echo ""
echo "Service Default :"
curl -s http://10.0.2.100/

echo ""
EOF

echo ""
echo "Tests terminés !"
echo ""
echo "=== Résumé ==="
echo "Internal Load Balancer : 10.0.2.100"
echo "VM Client : vm-client"
echo ""
echo "L'Internal LB n'est accessible que depuis le VPC."
echo ""
echo "Pour accéder à la VM client :"
echo "  gcloud compute ssh vm-client --zone=$ZONE --tunnel-through-iap"
