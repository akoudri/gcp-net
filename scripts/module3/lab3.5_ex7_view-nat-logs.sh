#!/bin/bash
# Lab 3.5 - Exercice 3.5.7 : Consulter les logs NAT
# Objectif : Explorer les logs Cloud NAT dans Cloud Logging

set -e

echo "=== Lab 3.5 - Exercice 7 : Consulter les logs NAT ==="
echo ""

echo "Affichage des logs NAT..."
# Voir les logs NAT dans Cloud Logging
gcloud logging read 'resource.type="nat_gateway"' \
    --limit=20 \
    --format="table(timestamp,jsonPayload.connection.src_ip,jsonPayload.connection.dest_ip,jsonPayload.allocation_status)"
echo ""

echo "Affichage des erreurs NAT uniquement..."
# Filtrer les erreurs uniquement
gcloud logging read 'resource.type="nat_gateway" AND jsonPayload.allocation_status!="OK"' \
    --limit=10
echo ""

echo "Note : Les logs peuvent prendre quelques minutes pour apparaître après activation."
echo ""
