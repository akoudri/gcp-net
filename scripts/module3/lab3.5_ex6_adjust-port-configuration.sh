#!/bin/bash
# Lab 3.5 - Exercice 3.5.6 : Ajuster la configuration des ports
# Objectif : Configurer l'allocation dynamique des ports

set -e

echo "=== Lab 3.5 - Exercice 6 : Ajuster la configuration des ports ==="
echo ""

# Variables
export REGION_EU="europe-west1"

echo "Région : $REGION_EU"
echo ""

# Augmenter le nombre de ports par VM
echo "Mise à jour de la configuration des ports..."
gcloud compute routers nats update my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --min-ports-per-vm=256 \
    --max-ports-per-vm=4096 \
    --enable-dynamic-port-allocation

echo ""
echo "Configuration des ports mise à jour avec succès !"
echo ""

# Vérifier les changements
echo "=== Configuration des ports ==="
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --format="yaml(minPortsPerVm,maxPortsPerVm,enableDynamicPortAllocation)"
echo ""
