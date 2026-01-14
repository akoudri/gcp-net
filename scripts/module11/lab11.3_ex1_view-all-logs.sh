#!/bin/bash
# Lab 11.3 - Exercice 11.3.1 : Requêtes de base dans Cloud Logging
# Objectif : Visualiser les Flow Logs dans Cloud Logging

set -e

echo "=== Lab 11.3 - Exercice 1 : Requêtes de base ==="
echo ""

echo "1. Voir tous les Flow Logs (10 entrées)..."
echo ""
gcloud logging read 'resource.type="gce_subnetwork"' \
    --limit=10 \
    --format=json

echo ""
echo "=================================="
echo ""

echo "2. Trafic depuis vm-source..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.src_instance.vm_name="vm-source"
' --limit=20 --format="table(
    timestamp,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.bytes_sent
)"

echo ""
echo "=================================="
echo ""

echo "3. Trafic vers vm-dest..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.dest_instance.vm_name="vm-dest"
' --limit=20

echo ""
echo "Note: Si aucun log n'apparaît, attendez quelques minutes et générez plus de trafic."
