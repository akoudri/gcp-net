#!/bin/bash
# Lab 8.6 - Exercice 8.6.5 : Créer des requêtes d'analyse avancées
# Objectif : Analyser les logs de pare-feu pour détecter les anomalies

set -e

echo "=== Lab 8.6 - Exercice 5 : Analyse avancée des logs ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

# Top 10 des IPs sources bloquées
echo ">>> Top 10 des IPs sources bloquées..."
echo ""
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=1000 --format="value(jsonPayload.connection.src_ip)" 2>/dev/null | \
    sort | uniq -c | sort -rn | head -10 || echo "Aucune donnée disponible"

echo ""
echo ">>> Ports les plus sollicités (bloqués)..."
echo ""
gcloud logging read '
    resource.type="gce_subnetwork" AND
    jsonPayload.disposition="DENIED"
' --limit=1000 --format="value(jsonPayload.connection.dest_port)" 2>/dev/null | \
    sort | uniq -c | sort -rn | head -10 || echo "Aucune donnée disponible"

echo ""
echo ">>> Création d'une métrique basée sur les logs..."
echo ""

# Créer une métrique pour compter les connexions bloquées
gcloud logging metrics create firewall-denied-count \
    --description="Nombre de connexions bloquées par le pare-feu" \
    --log-filter='resource.type="gce_subnetwork" AND jsonPayload.disposition="DENIED"' \
    2>/dev/null || echo "Métrique déjà existante ou erreur lors de la création"

echo ""
echo "Métrique 'firewall-denied-count' créée !"
echo ""

echo "=== Utilisation de la métrique ==="
echo ""
echo "Vous pouvez maintenant :"
echo "1. Créer des alertes basées sur cette métrique"
echo "2. Visualiser les tendances dans Cloud Monitoring"
echo "3. Corréler avec d'autres métriques système"
echo ""

echo "Commandes utiles pour l'analyse :"
echo ""
echo "# Logs par VM"
echo "gcloud logging read 'jsonPayload.instance.vm_name=\"vm-web-sa\"' --limit=20"
echo ""
echo "# Logs pour un port spécifique"
echo "gcloud logging read 'jsonPayload.connection.dest_port=22' --limit=20"
echo ""
echo "# Exporter vers BigQuery pour analyse approfondie"
echo "gcloud logging sinks create firewall-logs-bq \\"
echo "    bigquery.googleapis.com/projects/\$PROJECT_ID/datasets/firewall_logs \\"
echo "    --log-filter='resource.type=\"gce_subnetwork\"'"
echo ""

echo "Questions à considérer :"
echo "1. Comment identifier une attaque en cours avec ces logs ?"
echo "2. Quels patterns de trafic sont normaux vs suspects ?"
echo "3. Comment automatiser la détection d'anomalies ?"
