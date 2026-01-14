#!/bin/bash
# Lab 11.4 - Exercice 11.4.4 : Requêtes SQL d'analyse
# Objectif : Analyser les Flow Logs avec SQL dans BigQuery

set -e

echo "=== Lab 11.4 - Exercice 4 : Requêtes SQL d'analyse ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Vérifier que les données sont arrivées
echo "1. Vérification du nombre total de flows..."
echo ""
bq query --use_legacy_sql=false '
SELECT COUNT(*) as total_flows
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE TIMESTAMP_TRUNC(_PARTITIONTIME, DAY) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
'

echo ""
echo "=================================="
echo ""

# Top 10 destinations par volume
echo "2. Top 10 destinations par volume de données..."
echo ""
bq query --use_legacy_sql=false '
SELECT
    jsonPayload.connection.dest_ip AS dest_ip,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE TIMESTAMP_TRUNC(_PARTITIONTIME, DAY) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
GROUP BY dest_ip
ORDER BY total_bytes DESC
LIMIT 10
'

echo ""
echo "Note: Si aucune donnée n'apparaît, attendez quelques minutes supplémentaires."
