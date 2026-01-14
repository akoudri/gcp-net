#!/bin/bash
# Lab 11.5 - Exercice 11.5.3 : Générer du trafic et analyser les logs
# Objectif : Tester les règles de pare-feu et analyser les logs

set -e

echo "=== Lab 11.5 - Exercice 3 : Générer du trafic et analyser les logs ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Générer du trafic qui sera logué
echo "Génération de trafic pour tester les règles de pare-feu..."
echo ""

gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "1. Trafic autorisé (ping - ALLOW)..."
ping -c 3 vm-dest

echo ""
echo "2. Trafic autorisé (HTTP - ALLOW)..."
curl -s http://vm-dest -o /dev/null && echo "HTTP OK"

echo ""
echo "3. Tentative de connexion Telnet (DENY)..."
timeout 2 nc -v vm-dest 23 2>&1 || echo "Connexion Telnet bloquée (comportement attendu)"

echo ""
echo "Trafic de test généré!"
EOF

echo ""
echo "Attendre 30 secondes pour que les logs soient disponibles..."
sleep 30
echo ""

# Voir les logs ALLOWED
echo "=== Logs des connexions AUTORISÉES ==="
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.disposition="ALLOWED"
' --limit=20 --format="table(
    timestamp,
    jsonPayload.rule_details.reference,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_port
)"

echo ""
echo "=================================="
echo ""

# Voir les logs DENIED
echo "=== Logs des connexions BLOQUÉES ==="
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.disposition="DENIED"
' --limit=20 --format=json

echo ""
echo "Analyse terminée. Les logs montrent les décisions du pare-feu (ALLOWED/DENIED)."
