#!/bin/bash
# Lab 11.5 - Exercice 11.5.1 : Activer le logging sur les règles existantes
# Objectif : Activer le Firewall Rules Logging

set -e

echo "=== Lab 11.5 - Exercice 1 : Activer le logging sur les règles existantes ==="
echo ""

# Lister les règles de pare-feu
echo "Règles de pare-feu existantes dans vpc-observability :"
echo ""
gcloud compute firewall-rules list \
    --filter="network:vpc-observability" \
    --format="table(name,direction,action,sourceRanges,allowed)"

echo ""
echo "=================================="
echo ""

# Activer le logging sur une règle ALLOW
echo "Activation du logging sur vpc-obs-allow-ssh..."
gcloud compute firewall-rules update vpc-obs-allow-ssh \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL

echo ""
echo "Activation du logging sur vpc-obs-allow-icmp..."
gcloud compute firewall-rules update vpc-obs-allow-icmp \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL

echo ""
echo "Logging activé sur les règles de pare-feu !"
echo ""

# Vérifier
echo "=== Vérification de la configuration ==="
gcloud compute firewall-rules describe vpc-obs-allow-ssh \
    --format="yaml(logConfig)"

echo ""
echo "Les logs de pare-feu seront maintenant disponibles dans Cloud Logging."
