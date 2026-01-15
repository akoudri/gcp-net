#!/bin/bash
# Lab 9.9 - Exercice 9.9.3 : Bloquer les nœuds Tor
# Objectif : Bloquer le trafic depuis les nœuds de sortie Tor

set -e

echo "=== Lab 9.9 - Exercice 3 : Bloquer les nœuds Tor ==="
echo ""

echo "⚠️  AVERTISSEMENT : Cette fonctionnalité nécessite Cloud Armor Plus (tier payant)."
echo "Threat Intelligence n'est pas disponible dans le tier standard."
echo ""
echo "Pour activer Cloud Armor Plus:"
echo "gcloud compute security-policies update policy-web-app --tier=PLUS"
echo ""
echo "Tentative de création de la règle..."

# Bloquer le trafic depuis les nœuds de sortie Tor
echo "Création d'une règle pour bloquer les nœuds Tor..."
gcloud compute security-policies rules create 150 \
    --security-policy=policy-web-app \
    --expression="evaluateThreatIntelligence('iplist-tor-exit-nodes')" \
    --action=deny-403 \
    --description="Bloquer Tor exit nodes" 2>&1 || {
    echo ""
    echo "❌ ERREUR : Threat Intelligence nécessite Cloud Armor Plus tier."
    echo "Cette fonctionnalité n'est pas disponible avec le tier standard."
    echo ""
    echo "Alternative: Maintenir manuellement une liste d'IPs Tor connues"
    echo "ou utiliser un service tiers pour obtenir les IPs des nœuds Tor."
    exit 0
}

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
