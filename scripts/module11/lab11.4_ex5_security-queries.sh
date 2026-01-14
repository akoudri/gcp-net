#!/bin/bash
# Lab 11.4 - Exercice 11.4.5 : Requêtes de sécurité avancées
# Objectif : Détecter des comportements anormaux avec SQL

set -e

echo "=== Lab 11.4 - Exercice 5 : Requêtes de sécurité avancées ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Détection de port scan
echo "1. Détection de port scan (IPs connectées à >50 ports différents)..."
echo ""
bq query --use_legacy_sql=false '
SELECT
    jsonPayload.connection.src_ip AS source_ip,
    COUNT(DISTINCT jsonPayload.connection.dest_port) AS unique_ports,
    COUNT(*) AS connection_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY source_ip
HAVING unique_ports > 50
ORDER BY unique_ports DESC
'

echo ""
echo "=================================="
echo ""

# VMs avec trafic sortant anormal
echo "2. VMs avec trafic sortant anormal (>1GB/heure)..."
echo ""
bq query --use_legacy_sql=false '
SELECT
    jsonPayload.src_instance.vm_name AS vm_name,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    ROUND(SUM(CAST(jsonPayload.bytes_sent AS INT64)) / 1073741824, 2) AS gb_sent,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
    AND jsonPayload.reporter = "SRC"
    AND jsonPayload.dest_location.country IS NOT NULL
GROUP BY vm_name
HAVING total_bytes > 1073741824
ORDER BY total_bytes DESC
'

echo ""
echo "=================================="
echo ""

# Trafic vers des pays inhabituels
echo "3. Trafic vers des pays inhabituels..."
echo ""
bq query --use_legacy_sql=false '
SELECT
    jsonPayload.dest_location.country AS country,
    jsonPayload.connection.dest_ip AS dest_ip,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    AND jsonPayload.dest_location.country NOT IN ("FR", "DE", "US", "GB", "NL", "BE")
    AND jsonPayload.dest_location.country IS NOT NULL
GROUP BY country, dest_ip
ORDER BY total_bytes DESC
LIMIT 20
'

echo ""
echo "Note: Adaptez la liste des pays autorisés selon votre contexte."
