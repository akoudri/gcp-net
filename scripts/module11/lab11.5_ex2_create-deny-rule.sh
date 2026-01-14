#!/bin/bash
# Lab 11.5 - Exercice 11.5.2 : Créer une règle DENY avec logging
# Objectif : Créer une règle de blocage avec logging pour les tests

set -e

echo "=== Lab 11.5 - Exercice 2 : Créer une règle DENY avec logging ==="
echo ""

echo "Création d'une règle pour bloquer Telnet (port 23)..."
echo ""

# Créer une règle pour bloquer un port spécifique (pour test)
gcloud compute firewall-rules create vpc-obs-deny-telnet \
    --network=vpc-observability \
    --action=DENY \
    --direction=INGRESS \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA \
    --description="Bloquer Telnet avec logging"

echo ""
echo "Règle DENY créée avec succès !"
echo ""

# Afficher la règle
echo "=== Détails de la règle ==="
gcloud compute firewall-rules describe vpc-obs-deny-telnet

echo ""
echo "Cette règle bloquera toutes les tentatives de connexion Telnet."
echo "Les tentatives seront loguées dans Cloud Logging."
