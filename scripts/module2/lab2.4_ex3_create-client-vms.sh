#!/bin/bash
# Lab 2.4 - Exercice 2.4.3 : Créer les VMs clientes
# Objectif : Déployer des VMs de test dans chaque VPC

set -e

echo "=== Lab 2.4 - Exercice 3 : Créer les VMs clientes ==="
echo ""

export ZONE="europe-west1-b"

# Client dans VPC-A
echo "Création de client-a dans VPC-A..."
gcloud compute instances create client-a \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-a \
    --subnet=subnet-a \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""

# Client dans VPC-B
echo "Création de client-b dans VPC-B..."
gcloud compute instances create client-b \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-b \
    --subnet=subnet-b \
    --private-network-ip=10.2.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VMs clientes créées avec succès !"
echo ""

# Résumé
echo "=== Résumé des VMs ==="
gcloud compute instances list \
    --filter="name:(client-a OR client-b OR appliance-vm)" \
    --format="table(name,zone,networkInterfaces[0].networkIP,networkInterfaces[1].networkIP)"
