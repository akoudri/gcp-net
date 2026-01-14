#!/bin/bash
# Lab 9.9 - Exercice 9.9.3 : Bloquer les nœuds Tor
# Objectif : Bloquer le trafic depuis les nœuds de sortie Tor

set -e

echo "=== Lab 9.9 - Exercice 3 : Bloquer les nœuds Tor ==="
echo ""

# Bloquer le trafic depuis les nœuds de sortie Tor
echo "Création d'une règle pour bloquer les nœuds Tor..."
gcloud compute security-policies rules create 150 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-tor-exit-nodes')" \
    --action=deny-403 \
    --description="Bloquer Tor exit nodes"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 150 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle bloque automatiquement les IPs des nœuds de sortie Tor."
echo "La liste est maintenue par Google et mise à jour automatiquement."
