#!/bin/bash
# Lab 6.7 - Exercice 6.7.3 : Consulter les logs DNS
# Objectif : Analyser les logs DNS dans Cloud Logging

set -e

echo "=== Lab 6.7 - Exercice 3 : Consulter les logs DNS ==="
echo ""

echo "Attente de quelques secondes pour la propagation des logs..."
sleep 5
echo ""

# Consulter les logs DNS récents
echo "=== Logs DNS récents ==="
gcloud logging read 'resource.type="dns_query"' \
    --limit=20 \
    --format="table(timestamp,jsonPayload.queryName,jsonPayload.queryType,jsonPayload.responseCode)"
echo ""

# Filtrer par nom de domaine spécifique
echo "=== Logs filtrés pour lab.internal ==="
gcloud logging read 'resource.type="dns_query" AND jsonPayload.queryName:"lab.internal"' \
    --limit=10
echo ""

# Voir les requêtes avec erreurs
echo "=== Requêtes avec erreurs (NXDOMAIN, SERVFAIL, etc.) ==="
gcloud logging read 'resource.type="dns_query" AND jsonPayload.responseCode!="NOERROR"' \
    --limit=10
