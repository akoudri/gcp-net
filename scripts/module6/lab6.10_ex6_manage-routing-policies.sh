#!/bin/bash
# Lab 6.10 - Exercice 6.10.6 : Lister et gérer les routing policies
# Objectif : Gérer les enregistrements avec routing policies

set -e

echo "=== Lab 6.10 - Exercice 6 : Lister et gérer les routing policies ==="
echo ""

# Lister tous les enregistrements avec routing policy
echo "=== Enregistrements avec routing policies ==="
gcloud dns record-sets list --zone=zone-public-lab \
    --filter="routingPolicy.geo OR routingPolicy.wrr" \
    --format="table(name,type,routingPolicy)"
echo ""

echo "=== Tous les enregistrements (vue détaillée) ==="
gcloud dns record-sets list --zone=zone-public-lab
echo ""

cat << 'MANAGEMENT'
=== Gestion des routing policies ===

Pour modifier un enregistrement avec routing policy:
1. Supprimer l'enregistrement existant
2. Recréer avec la nouvelle configuration

Exemple pour supprimer:
    gcloud dns record-sets delete "geo.example.com." \
        --zone=zone-public-lab \
        --type=A

Pour changer les poids WRR:
    gcloud dns record-sets delete "wrr.example.com." --zone=ZONE --type=A
    gcloud dns record-sets create "wrr.example.com." \
        --zone=ZONE --type=A --ttl=60 \
        --routing-policy-type=WRR \
        --routing-policy-data="0.9=10.0.0.101;0.1=10.0.0.102"

Monitoring:
- Utiliser Cloud Monitoring pour suivre la distribution du trafic
- Analyser les logs DNS pour vérifier le comportement
- Tester depuis différentes localisations géographiques
MANAGEMENT
