#!/bin/bash
# Lab 11.3 - Exercice 11.3.5 : Requêtes de sécurité
# Objectif : Détecter des comportements suspects

set -e

echo "=== Lab 11.3 - Exercice 5 : Requêtes de sécurité ==="
echo ""

echo "1. Détection de port scan (IPs se connectant à de nombreux ports)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
timestamp>="'$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ')'"
' --limit=5000 --format="value(jsonPayload.connection.src_ip,jsonPayload.connection.dest_port)" \
| sort | uniq | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10

echo ""
echo "Note: Un nombre élevé de ports distincts depuis une même IP peut indiquer un scan."
echo ""
echo "=================================="
echo ""

echo "2. Trafic sur des ports non standards (>1024)..."
echo ""
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.dest_port>1024
jsonPayload.connection.dest_port!=3306
jsonPayload.connection.dest_port!=5432
jsonPayload.connection.dest_port!=6379
jsonPayload.connection.dest_port!=8080
jsonPayload.connection.dest_port!=8443
' --limit=50

echo ""
echo "Note: Exclure les ports applicatifs connus (MySQL, PostgreSQL, Redis, etc.)"
