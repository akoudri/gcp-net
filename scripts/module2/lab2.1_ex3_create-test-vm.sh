#!/bin/bash
# Lab 2.1 - Exercice 2.1.3 : Créer une VM dans le VPC default
# Objectif : Démonstration des risques du VPC default

set -e

echo "=== Lab 2.1 - Exercice 3 : Créer une VM de test dans le VPC default ==="
echo ""

# Créer une VM de test
echo "Création de la VM test-default-vpc..."
gcloud compute instances create test-default-vpc \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=default \
    --subnet=default \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=test-vm

echo ""
echo "VM créée avec succès !"
echo ""

# Vérifier l'IP externe attribuée
echo "=== IP externe de la VM ==="
gcloud compute instances describe test-default-vpc \
    --zone=europe-west1-b \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
echo ""

echo "Questions à considérer :"
echo "1. La VM a-t-elle une IP externe ? Pourquoi est-ce un risque potentiel ?"
echo "2. Cette VM est-elle accessible en SSH depuis Internet ?"
