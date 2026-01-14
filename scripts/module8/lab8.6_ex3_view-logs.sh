#!/bin/bash
# Lab 8.6 - Exercice 8.6.3 : Consulter les logs de pare-feu
# Objectif : Analyser les logs de pare-feu dans Cloud Logging

set -e

echo "=== Lab 8.6 - Exercice 3 : Consulter les logs de pare-feu ==="
echo ""

# Logs de trafic autorisé
echo ">>> Logs de trafic AUTORISÉ (10 dernières entrées)..."
echo ""
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="ALLOWED"
' --limit=10 --format="table(
    timestamp,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.rule_details.reference
)" 2>/dev/null || echo "Aucun log trouvé. Générez du trafic avec lab8.6_ex2_generate-traffic.sh"

echo ""
echo ">>> Logs de trafic REFUSÉ (10 dernières entrées)..."
echo ""
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=10 --format="table(
    timestamp,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.rule_details.reference
)" 2>/dev/null || echo "Aucun log de trafic refusé trouvé."

echo ""
echo ">>> Logs pour le sous-réseau frontend..."
echo ""
gcloud logging read "
    resource.type=\"gce_subnetwork\" AND
    resource.labels.subnetwork_name=\"subnet-frontend\"
" --limit=5 --format=json 2>/dev/null | head -50 || echo "Aucun log trouvé pour subnet-frontend"

echo ""
echo "=== Structure des logs de pare-feu ==="
echo ""
echo "Champs importants :"
echo "  - jsonPayload.disposition: ALLOWED ou DENIED"
echo "  - jsonPayload.connection.*: Détails de la connexion (IPs, ports, protocole)"
echo "  - jsonPayload.rule_details.reference: Règle qui a été appliquée"
echo "  - jsonPayload.instance.vm_name: VM concernée"
echo ""

echo "Questions à considérer :"
echo "1. Comment identifier quelle règle a bloqué une connexion ?"
echo "2. Pourquoi certains logs ALLOWED peuvent-ils être volumineux ?"
echo "3. Comment filtrer les logs pour une VM spécifique ?"
