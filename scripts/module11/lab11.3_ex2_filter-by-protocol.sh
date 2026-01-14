#!/bin/bash
# Lab 11.3 - Exercice 11.3.2 : Filtrer par protocole et port
# Objectif : Analyser le trafic par protocole et port

set -e

echo "=== Lab 11.3 - Exercice 2 : Filtrer par protocole et port ==="
echo ""

echo "1. Trafic SSH (port 22)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.dest_port=22
' --limit=20

echo ""
echo "=================================="
echo ""

echo "2. Trafic HTTP/HTTPS..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
(jsonPayload.connection.dest_port=80 OR jsonPayload.connection.dest_port=443)
' --limit=20

echo ""
echo "=================================="
echo ""

echo "3. Trafic TCP uniquement (protocole 6)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.protocol=6
' --limit=20

echo ""
echo "=================================="
echo ""

echo "4. Trafic ICMP (protocole 1)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.protocol=1
' --limit=20

echo ""
echo "Protocoles réseau :"
echo "  1 = ICMP (ping)"
echo "  6 = TCP"
echo "  17 = UDP"
