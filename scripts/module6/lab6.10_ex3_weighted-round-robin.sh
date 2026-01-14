#!/bin/bash
# Lab 6.10 - Exercice 6.10.3 : Weighted Round Robin
# Objectif : Configurer le routage pondéré

set -e

echo "=== Lab 6.10 - Exercice 3 : Weighted Round Robin ==="
echo ""

# Créer un health check pour Cloud DNS (optionnel pour WRR)
echo "Création d'un health check..."
gcloud compute health-checks create http hc-dns-wrr \
    --port=80 \
    --request-path=/health 2>/dev/null || echo "Health check déjà existant"
echo ""

# Créer des enregistrements avec politique WRR
# 80% du trafic vers primary, 20% vers canary
echo "Création d'un enregistrement avec Weighted Round Robin..."
echo "80% du trafic → primary, 20% → canary"
echo ""

gcloud dns record-sets create "wrr.example-lab.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=60 \
    --routing-policy-type=WRR \
    --routing-policy-data="0.8=10.0.0.101;0.2=10.0.0.102"
echo ""

echo "Enregistrement WRR créé avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration de l'enregistrement ==="
gcloud dns record-sets describe "wrr.example-lab.com." \
    --zone=zone-public-lab \
    --type=A
echo ""

echo "Distribution :"
echo "- 80% → 10.0.0.101 (version stable)"
echo "- 20% → 10.0.0.102 (version canary)"
