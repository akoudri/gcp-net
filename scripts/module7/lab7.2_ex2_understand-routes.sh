#!/bin/bash
# Lab 7.2 - Exercice 7.2.2 : Comprendre les routes échangées
# Objectif : Observer les routes échangées via BGP

set -e

echo "=== Lab 7.2 - Exercice 2 : Comprendre les routes échangées ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

cat << 'INFO'
=== Fonctionnement de l'échange de routes BGP ===

Cloud Router annonce automatiquement:
- Les sous-réseaux du VPC auquel il est attaché
- Les plages personnalisées configurées (custom advertisements)

Ce qui est annoncé par router-gcp (ASN 65001):
- 10.0.0.0/24 (subnet-gcp)

Ce qui est annoncé par router-onprem (ASN 65002):
- 192.168.0.0/24 (subnet-onprem)

Après l'échange BGP:
- router-gcp apprend 192.168.0.0/24 de router-onprem
- router-onprem apprend 10.0.0.0/24 de router-gcp
- Les routes sont installées automatiquement dans les VPC

INFO

echo ""

# Voir les routes dans le VPC GCP
echo "=== Routes dans VPC GCP ==="
gcloud compute routes list --filter="network:vpc-gcp" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

echo ""

# Voir les routes dans le VPC On-premise
echo "=== Routes dans VPC On-premise ==="
gcloud compute routes list --filter="network:vpc-onprem" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

echo ""
echo "=== Analyse terminée ==="
