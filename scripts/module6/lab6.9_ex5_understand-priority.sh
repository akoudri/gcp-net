#!/bin/bash
# Lab 6.9 - Exercice 6.9.5 : Comprendre la priorité des zones
# Objectif : Expliquer la priorité de résolution DNS dans GCP

set -e

echo "=== Lab 6.9 - Exercice 5 : Comprendre la priorité des zones ==="
echo ""

cat << 'PRIORITY'
=== Priorité de résolution DNS dans GCP ===

Ordre de priorité (de la plus haute à la plus basse):

1. Zones privées attachées au VPC
   → Priorité absolue pour les VMs du VPC

2. Zones de peering DNS
   → Pour les noms délégués à un autre VPC

3. Zones de forwarding
   → Pour les noms transférés vers des serveurs externes

4. DNS interne automatique GCP
   → [VM].[ZONE].c.[PROJECT].internal

5. Zone publique / Internet
   → Résolution via les serveurs DNS publics

Conséquence pour le split-horizon:
- La zone privée "example.com" a priorité sur la zone publique
- Les VMs du VPC voient TOUJOURS l'IP privée
- Les clients externes voient l'IP publique

=== Vérification des zones ===
PRIORITY

echo ""
echo "Liste des zones DNS privées :"
gcloud dns managed-zones list --filter="visibility=private" \
    --format="table(name,dnsName,visibility)"
echo ""

echo "Liste des zones DNS publiques :"
gcloud dns managed-zones list --filter="visibility=public" \
    --format="table(name,dnsName,visibility)"
echo ""

echo "Vérification : Les VMs dans vpc-dns-lab verront api-split.example.com"
echo "résoudre vers l'IP privée (10.0.0.50) grâce à la zone privée."
