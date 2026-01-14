#!/bin/bash
# Lab 6.8 - Exercice 6.8.3 : Obtenir les informations DNSSEC
# Objectif : Récupérer les clés DNSSEC et DS records

set -e

echo "=== Lab 6.8 - Exercice 3 : Obtenir les informations DNSSEC ==="
echo ""

# Lister les clés DNSSEC
echo "=== Clés DNSSEC ==="
gcloud dns dns-keys list --zone=zone-public-lab
echo ""

# Obtenir le DS record pour le registrar (KSK uniquement)
echo "=== DS Record pour le registrar (KSK uniquement) ==="
gcloud dns dns-keys list --zone=zone-public-lab \
    --filter="type=keySigning" \
    --format="table(keyTag,algorithm,digestType,ds_record())"
echo ""

# Format détaillé
echo "=== Détails de la clé KSK ==="
KSK_ID=$(gcloud dns dns-keys list \
    --zone=zone-public-lab \
    --filter="type=keySigning" \
    --format="get(id)" | head -1)

if [ -n "$KSK_ID" ]; then
    gcloud dns dns-keys describe "$KSK_ID" \
        --zone=zone-public-lab
else
    echo "Aucune clé KSK trouvée. DNSSEC peut encore être en cours d'activation."
fi
echo ""

echo "Ces informations (DS record) doivent être configurées chez votre registrar"
echo "pour compléter la chaîne de confiance DNSSEC."
