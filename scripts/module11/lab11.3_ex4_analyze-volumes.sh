#!/bin/bash
# Lab 11.3 - Exercice 11.3.4 : Analyse de volumes
# Objectif : Identifier les plus gros consommateurs de bande passante

set -e

echo "=== Lab 11.3 - Exercice 4 : Analyse de volumes ==="
echo ""

echo "1. Top 10 destinations par bytes envoyés..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
' --limit=1000 --format="value(jsonPayload.connection.dest_ip,jsonPayload.bytes_sent)" \
| awk '{ip[$1]+=$2} END {for (i in ip) print ip[i], i}' \
| sort -rn \
| head -10

echo ""
echo "=================================="
echo ""

echo "2. Top 10 sources par nombre de connexions..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
' --limit=1000 --format="value(jsonPayload.connection.src_ip)" \
| sort | uniq -c | sort -rn | head -10

echo ""
echo "Note: Plus le nombre d'échantillons est élevé, plus les résultats sont précis."
echo "Augmentez la limite (--limit) pour une analyse plus complète."
