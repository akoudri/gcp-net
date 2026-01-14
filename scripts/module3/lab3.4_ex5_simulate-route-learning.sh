#!/bin/bash
# Lab 3.4 - Exercice 3.4.5 : Simuler l'apprentissage de routes (conceptuel)
# Objectif : Comprendre comment les routes BGP sont apprises

set -e

echo "=== Lab 3.4 - Exercice 5 : Simuler l'apprentissage de routes ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "Dans un scénario réel avec Cloud VPN :"
echo ""
echo "1. Le Cloud Router établit une session BGP avec votre routeur on-premise"
echo "2. Votre routeur annonce ses routes (ex: 192.168.0.0/16)"
echo "3. Cloud Router injecte ces routes dans la table de routage du VPC"
echo "4. Les VMs peuvent atteindre 192.168.0.0/16 via le tunnel VPN"
echo ""

# Visualiser les routes apprises (vide sans VPN actif)
echo "=== Routes apprises via VPN (vide sans VPN actif) ==="
gcloud compute routes list \
    --filter="network=$VPC_NAME" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"
echo ""

echo "Note : Les routes dynamiques apparaîtront ici une fois Cloud VPN configuré."
echo ""
echo "Référence : Voir Module 7 pour la configuration complète de Cloud VPN."
echo ""
