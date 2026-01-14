#!/bin/bash
# Lab 6.6 - Exercice 6.6.6 : Comprendre les limites
# Objectif : Afficher les différences entre peering DNS et VPC peering

set -e

echo "=== Lab 6.6 - Exercice 6 : Comprendre les limites ==="
echo ""

cat << 'LIMITS'
=== Peering DNS vs VPC Peering ===

┌────────────┬─────────────────────┬─────────────────────┐
│ Aspect     │ Peering DNS         │ VPC Peering         │
├────────────┼─────────────────────┼─────────────────────┤
│ Fonction   │ Résolution de noms  │ Connectivité réseau │
│ Trafic     │ DNS uniquement      │ Tout le trafic      │
│ Transitif  │ Non                 │ Non                 │
│ Config     │ Par zone DNS        │ Par VPC             │
└────────────┴─────────────────────┴─────────────────────┘

Pour une connectivité complète Hub-Spoke :
1. Peering DNS : Pour la résolution des noms
2. VPC Peering : Pour la connectivité réseau
   OU
   Shared VPC : Pour tout centraliser

=== Vérification des configurations ===
LIMITS

echo ""
echo "Liste des zones DNS :"
gcloud dns managed-zones list --format="table(name,dnsName,visibility,peeringConfig.targetNetwork)"
echo ""

echo "Liste des VPCs :"
gcloud compute networks list --format="table(name,autoCreateSubnetworks,routingConfig.routingMode)"
echo ""

echo "Note : Pour tester la connectivité réseau complète, il faudrait :"
echo "1. Créer un VPC Peering entre vpc-hub et vpc-spoke"
echo "2. OU utiliser une architecture Shared VPC"
