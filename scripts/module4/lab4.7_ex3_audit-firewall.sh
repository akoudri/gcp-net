#!/bin/bash
# Lab 4.7 - Exercice 4.7.4 : Bonnes pratiques de pare-feu - Script d'audit
# Objectif : Créer un script pour auditer les règles de pare-feu

set -e

echo "=== Lab 4.7 - Exercice 4 : Audit des règles de pare-feu ==="
echo ""

VPC=$1
if [ -z "$VPC" ]; then
    echo "Usage: $0 <vpc-name>"
    echo ""
    echo "VPCs disponibles :"
    gcloud compute networks list --format="value(name)"
    exit 1
fi

echo "Audit des règles de pare-feu pour VPC: $VPC"
echo ""

echo "1. Règles avec source 0.0.0.0/0 (attention!):"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND sourceRanges=0.0.0.0/0" \
    --format="table(name,direction,allowed,targetTags)"

echo ""
echo "2. Règles autorisant tout le trafic (tcp,udp,icmp):"
gcloud compute firewall-rules list \
    --filter="network=$VPC" \
    --format="table(name,sourceRanges,allowed)" | grep -E "tcp.*udp.*icmp|icmp.*tcp.*udp" || echo "Aucune"

echo ""
echo "3. Règles sans tags cibles (s'appliquent à toutes les VMs):"
gcloud compute firewall-rules list \
    --filter="network=$VPC AND NOT targetTags:*" \
    --format="table(name,sourceRanges,allowed)"

echo ""
echo "4. Résumé par direction:"
echo -n "INGRESS: "
gcloud compute firewall-rules list \
    --filter="network=$VPC AND direction=INGRESS" \
    --format="value(name)" | wc -l
echo -n "EGRESS: "
gcloud compute firewall-rules list \
    --filter="network=$VPC AND direction=EGRESS" \
    --format="value(name)" | wc -l

echo ""
echo "Audit terminé."
