#!/bin/bash
# Lab 11.3 - Exercice 11.3.3 : Identifier le trafic externe
# Objectif : Analyser le trafic vers des IPs externes

set -e

echo "=== Lab 11.3 - Exercice 3 : Identifier le trafic externe ==="
echo ""

echo "1. Trafic vers des IPs externes (non RFC1918)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
NOT jsonPayload.connection.dest_ip=~"^10\."
NOT jsonPayload.connection.dest_ip=~"^172\.(1[6-9]|2[0-9]|3[0-1])\."
NOT jsonPayload.connection.dest_ip=~"^192\.168\."
' --limit=50

echo ""
echo "=================================="
echo ""

echo "2. Trafic par pays de destination..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.dest_location.country!=""
' --limit=50 --format="table(
    jsonPayload.dest_location.country,
    jsonPayload.connection.dest_ip,
    jsonPayload.bytes_sent
)"

echo ""
echo "Note: Les informations de géolocalisation ne sont disponibles que pour les IPs externes."
