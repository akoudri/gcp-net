#!/bin/bash
# Lab 5.2 - Exercice 5.2.3 : Ajouter les enregistrements DNS pour private.googleapis.com
# Objectif : Configurer les enregistrements DNS pour utiliser les IPs VIP privées

set -e

echo "=== Lab 5.2 - Exercice 3 : Ajouter les enregistrements DNS ==="
echo ""

# Enregistrement A pour private.googleapis.com
echo "Création de l'enregistrement A pour private.googleapis.com..."
gcloud dns record-sets create "private.googleapis.com." \
    --zone=googleapis-private \
    --type=A \
    --ttl=300 \
    --rrdatas="199.36.153.8,199.36.153.9,199.36.153.10,199.36.153.11"

echo ""
echo "Enregistrement A créé !"
echo ""

# CNAME wildcard pour rediriger *.googleapis.com
echo "Création du CNAME wildcard pour *.googleapis.com..."
gcloud dns record-sets create "*.googleapis.com." \
    --zone=googleapis-private \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="private.googleapis.com."

echo ""
echo "CNAME wildcard créé !"
echo ""

# Lister les enregistrements
echo "=== Enregistrements DNS dans la zone ==="
gcloud dns record-sets list --zone=googleapis-private

echo ""
echo "=== Enregistrements DNS configurés ! ==="
echo ""
echo "Configuration :"
echo "- private.googleapis.com → 199.36.153.8/30 (IPs VIP privées)"
echo "- *.googleapis.com → private.googleapis.com (CNAME wildcard)"
echo ""
echo "Tous les sous-domaines googleapis.com se résoudront maintenant"
echo "vers les IPs VIP privées de Google."
