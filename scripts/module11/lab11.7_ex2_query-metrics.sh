#!/bin/bash
# Lab 11.7 - Exercice 11.7.2 : Requêtes de métriques via CLI
# Objectif : Interroger les métriques réseau

set -e

echo "=== Lab 11.7 - Exercice 2 : Requêtes de métriques via CLI ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Récupérer l'ID de l'instance
echo "Récupération de l'ID de vm-source..."
INSTANCE_ID=$(gcloud compute instances describe vm-source --zone=$ZONE --format="get(id)")
echo "Instance ID: $INSTANCE_ID"
echo ""

# Bytes envoyés par la VM
echo "1. Bytes envoyés par vm-source (dernière heure)..."
echo ""
gcloud monitoring time-series list \
    --filter='metric.type="compute.googleapis.com/instance/network/sent_bytes_count" AND resource.labels.instance_id="'$INSTANCE_ID'"' \
    --start-time=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo ""
echo "=================================="
echo ""

# Bytes reçus par la VM
echo "2. Bytes reçus par vm-source (dernière heure)..."
echo ""
gcloud monitoring time-series list \
    --filter='metric.type="compute.googleapis.com/instance/network/received_bytes_count" AND resource.labels.instance_id="'$INSTANCE_ID'"' \
    --start-time=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo ""
echo "Note: Si aucune donnée n'apparaît, générez plus de trafic et réessayez."
