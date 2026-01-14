#!/bin/bash
# Lab 11.7 - Exercice 11.7.1 : Lister les métriques disponibles
# Objectif : Explorer les métriques réseau disponibles

set -e

echo "=== Lab 11.7 - Exercice 1 : Lister les métriques disponibles ==="
echo ""

echo "1. Métriques réseau des instances Compute..."
echo ""
gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com/instance/network"

echo ""
echo "=================================="
echo ""

echo "2. Métriques Load Balancer..."
echo ""
gcloud monitoring metrics list --filter="metric.type:loadbalancing.googleapis.com"

echo ""
echo "=================================="
echo ""

echo "3. Métriques VPN..."
echo ""
gcloud monitoring metrics list --filter="metric.type:vpn.googleapis.com"

echo ""
echo "=================================="
echo ""

echo "4. Métriques Cloud NAT..."
echo ""
gcloud monitoring metrics list --filter="metric.type:router.googleapis.com/nat"

echo ""
echo "Ces métriques peuvent être utilisées pour créer des dashboards et des alertes."
